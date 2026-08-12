import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/products_local_store.dart';

class ShopSortOption {
  const ShopSortOption({required this.title, required this.orderby, required this.order, this.onSale});

  final String title;
  final String orderby;
  final String order;
  final bool? onSale;

  static const List<ShopSortOption> values = <ShopSortOption>[
    ShopSortOption(title: 'جدیدترین', orderby: 'date', order: 'desc'),
    ShopSortOption(title: 'قدیمی‌ترین', orderby: 'date', order: 'asc'),
    ShopSortOption(title: 'گران‌ترین', orderby: 'price', order: 'desc'),
    ShopSortOption(title: 'ارزان‌ترین', orderby: 'price', order: 'asc'),
    ShopSortOption(title: 'تخفیف‌دار', orderby: 'date', order: 'desc', onSale: true),
    ShopSortOption(title: 'پرفروش‌ترین', orderby: 'cout_sales', order: 'desc'),
    ShopSortOption(title: 'محبوب‌ترین', orderby: 'popularity', order: 'desc'),
  ];

  static ShopSortOption resolve({required String orderby, required String order, required bool? onSale}) {
    if (onSale == true) return values[4];
    for (final option in values) {
      if (option.onSale == null && option.orderby == orderby && option.order == order) return option;
    }
    return values.first;
  }
}

class ShopFilterState {
  ShopFilterState({
    this.search = '',
    Set<int>? categoryIds,
    Set<int>? brandIds,
    this.minPrice,
    this.maxPrice,
    this.orderby = 'date',
    this.order = 'desc',
    this.onSale,
    Map<int, Set<int>>? attributeOptionIds,
  })  : categoryIds = categoryIds ?? <int>{},
        brandIds = brandIds ?? <int>{},
        attributeOptionIds = attributeOptionIds ?? <int, Set<int>>{};

  String search;
  Set<int> categoryIds;
  Set<int> brandIds;
  Map<int, Set<int>> attributeOptionIds;
  int? minPrice;
  int? maxPrice;
  String orderby;
  String order;
  bool? onSale;

  factory ShopFilterState.fromFilterBy(ProductsFilterByModel filterBy) {
    return ShopFilterState(
      search: filterBy.search ?? '',
      categoryIds: filterBy.categories.toSet(),
      brandIds: filterBy.brands.toSet(),
      minPrice: filterBy.minPrice,
      maxPrice: filterBy.maxPrice,
      orderby: filterBy.orderby,
      order: filterBy.order,
      onSale: filterBy.onSale,
      attributeOptionIds: <int, Set<int>>{
        for (final attribute in filterBy.attributes) attribute.id: attribute.options.toSet(),
      },
    );
  }

  ShopFilterState copy() {
    return ShopFilterState(
      search: search,
      categoryIds: Set<int>.from(categoryIds),
      brandIds: Set<int>.from(brandIds),
      minPrice: minPrice,
      maxPrice: maxPrice,
      orderby: orderby,
      order: order,
      onSale: onSale,
      attributeOptionIds: attributeOptionIds.map((key, value) => MapEntry<int, Set<int>>(key, Set<int>.from(value))),
    );
  }

  Set<int> selectedOptionsFor(int attributeId) => attributeOptionIds[attributeId] ?? <int>{};

  int get selectedAttributeOptionsCount => attributeOptionIds.values.fold<int>(0, (sum, values) => sum + values.length);
  bool get hasPriceFilter => minPrice != null || maxPrice != null;
  bool get hasNonDefaultSort => onSale == true || orderby != 'date' || order != 'desc';

  bool get isDefaultUnfiltered {
    return search.trim().isEmpty &&
        categoryIds.isEmpty &&
        brandIds.isEmpty &&
        attributeOptionIds.values.every((values) => values.isEmpty) &&
        !hasPriceFilter &&
        onSale == null &&
        orderby == 'date' &&
        order == 'desc';
  }

  int get activeFilterGroupsCount {
    var count = 0;
    if (categoryIds.isNotEmpty) count++;
    if (brandIds.isNotEmpty) count++;
    if (hasPriceFilter) count++;
    if (hasNonDefaultSort) count++;
    count += attributeOptionIds.values.where((values) => values.isNotEmpty).length;
    return count;
  }

  void clearAll({bool keepSearch = true}) {
    final currentSearch = search;
    categoryIds.clear();
    brandIds.clear();
    minPrice = null;
    maxPrice = null;
    orderby = 'date';
    order = 'desc';
    onSale = null;
    attributeOptionIds.clear();
    search = keepSearch ? currentSearch : '';
  }
}

class ShopViewModel with ChangeNotifier {
  static const int _pageSize = 20;

  final HttpRequest _httpRequest = HttpRequest();
  final ProductsLocalStore _localStore = ProductsLocalStore.instance;

  List<ProductCardModel> productsLst = <ProductCardModel>[];
  ProductsFiltersModel filters = ProductsFiltersModel.empty();
  ProductsPaginationModel pagination = ProductsPaginationModel.empty();
  ShopFilterState appliedFilters = ShopFilterState();

  bool initialized = false;
  bool isInitialLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isPreviewLoading = false;
  String? errorMessage;
  int previewCount = 0;
  int priceFloor = 0;
  int priceCeiling = 100000000;

  bool _usingLocalCatalog = true;
  int _listRequestSerial = 0;

  int get productCount => pagination.totalItems;
  bool get hasNextPage => pagination.hasNext;
  ShopSortOption get selectedSort => ShopSortOption.resolve(orderby: appliedFilters.orderby, order: appliedFilters.order, onSale: appliedFilters.onSale);

  Future<void> loadInitial() async {
    if (isInitialLoading || initialized) return;

    isInitialLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (!_localStore.loadedOnce) {
        await _localStore.refreshFullCatalog(_httpRequest);
      }
      _hydrateFromLocalCatalog(resetFilters: true);
    } catch (e) {
      errorMessage = _friendlyError(e);
    } finally {
      isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    initialized = false;
    await loadInitial();
  }

  Future<void> refresh() async {
    if (isRefreshing) return;
    isRefreshing = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (appliedFilters.isDefaultUnfiltered) {
        await _localStore.refreshFullCatalog(_httpRequest);
        _hydrateFromLocalCatalog(resetFilters: true);
      } else {
        final response = await _fetchProducts(filters: appliedFilters, page: 1, perPage: _pageSize);
        _acceptServerFirstPage(response);
      }
    } catch (e) {
      errorMessage = _friendlyError(e);
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters(ShopFilterState draft) async {
    appliedFilters = draft.copy();
    errorMessage = null;
    isInitialLoading = productsLst.isEmpty;
    notifyListeners();

    final serial = ++_listRequestSerial;
    try {
      if (appliedFilters.isDefaultUnfiltered) {
        await _localStore.refreshFullCatalog(_httpRequest);
        if (serial != _listRequestSerial) return;
        _hydrateFromLocalCatalog(resetFilters: true);
      } else {
        final response = await _fetchProducts(filters: appliedFilters, page: 1, perPage: _pageSize);
        if (serial != _listRequestSerial) return;
        _acceptServerFirstPage(response);
      }
    } catch (e) {
      if (serial != _listRequestSerial) return;
      errorMessage = _friendlyError(e);
    } finally {
      if (serial == _listRequestSerial) {
        isInitialLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> applySearch(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return false;
    final draft = ShopFilterState()..search = normalized;
    await applyFilters(draft);
    return errorMessage == null;
  }

  Future<bool> applyCategoryFromSearch(int categoryId) async {
    final draft = ShopFilterState()..categoryIds.add(categoryId);
    await applyFilters(draft);
    return errorMessage == null;
  }

  Future<bool> applyBrandFromSearch(int brandId) async {
    final draft = ShopFilterState()..brandIds.add(brandId);
    await applyFilters(draft);
    return errorMessage == null;
  }

  Future<void> loadMore() async {
    if (!initialized || isLoadingMore || isInitialLoading || !pagination.hasNext) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      if (_usingLocalCatalog) {
        final nextPage = pagination.currentPage + 1;
        final localItems = _localStore.page(page: nextPage, perPage: _pageSize);
        final existingIds = productsLst.map((item) => item.id).toSet();
        for (final item in localItems) {
          if (existingIds.add(item.id)) productsLst.add(_toProductCard(item));
        }
        pagination = _localPagination(nextPage);
      } else {
        final response = await _fetchProducts(filters: appliedFilters, page: pagination.currentPage + 1, perPage: _pageSize);
        final existingIds = productsLst.map((item) => item.id).toSet();
        for (final item in response.data) {
          if (existingIds.add(item.id)) productsLst.add(_toProductCard(item));
        }
        pagination = response.pagination;
      }
    } catch (e) {
      errorMessage = _friendlyError(e);
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void previewFilters(ShopFilterState draft) {
    isPreviewLoading = false;
    previewCount = _localStore.countMatching(
      search: draft.search,
      categoryIds: draft.categoryIds,
      brandIds: draft.brandIds,
      attributeOptionIds: draft.attributeOptionIds,
      minPrice: draft.minPrice,
      maxPrice: draft.maxPrice,
      onSale: draft.onSale,
    );
    notifyListeners();
  }

  void cancelPreview() {
    isPreviewLoading = false;
    previewCount = _localStore.countMatching(
      search: appliedFilters.search,
      categoryIds: appliedFilters.categoryIds,
      brandIds: appliedFilters.brandIds,
      attributeOptionIds: appliedFilters.attributeOptionIds,
      minPrice: appliedFilters.minPrice,
      maxPrice: appliedFilters.maxPrice,
      onSale: appliedFilters.onSale,
    );
    notifyListeners();
  }

  String categoryChipTitle(ShopFilterState state) {
    if (state.categoryIds.isEmpty || state.categoryIds.length > 1) return 'دسته‌بندی';
    return filters.categoryById(state.categoryIds.first)?.name ?? 'دسته‌بندی';
  }

  String brandChipTitle(ShopFilterState state) {
    if (state.brandIds.isEmpty || state.brandIds.length > 1) return 'برند';
    return filters.brandById(state.brandIds.first)?.name ?? 'برند';
  }

  String attributeChipTitle(ProductAttributeFilterModel attribute, ShopFilterState state) {
    final selected = state.selectedOptionsFor(attribute.id);
    if (selected.length != 1) return attribute.name;
    final selectedId = selected.first;
    for (final option in attribute.options) {
      if (option.id == selectedId) return option.name;
    }
    return attribute.name;
  }

  String sortChipTitle(ShopFilterState state) {
    return ShopSortOption.resolve(orderby: state.orderby, order: state.order, onSale: state.onSale).title;
  }

  void _hydrateFromLocalCatalog({required bool resetFilters}) {
    filters = _localStore.filters;
    if (resetFilters) {
      appliedFilters = ShopFilterState();
    }
    productsLst = _localStore.page(page: 1, perPage: _pageSize).map(_toProductCard).toList(growable: true);
    pagination = _localPagination(1);
    previewCount = _localStore.totalProducts;
    _usingLocalCatalog = true;
    _setPriceRangeFromLocal();
    initialized = true;
  }

  ProductsPaginationModel _localPagination(int page) {
    final total = _localStore.totalProducts;
    final totalPages = _localStore.totalPagesFor(_pageSize);
    return ProductsPaginationModel(
      currentPage: page,
      perPage: _pageSize,
      totalItems: total,
      totalPages: totalPages,
      totalSiteProducts: total,
      hasNext: page < totalPages,
      hasPrevious: page > 1,
    );
  }

  void _setPriceRangeFromLocal() {
    final rawMax = _localStore.maxPrice();
    if (rawMax <= 0) {
      priceCeiling = 100000000;
      return;
    }
    final rounded = ((rawMax * 1.1) / 1000000).ceil() * 1000000;
    priceCeiling = rounded < 10000000 ? 10000000 : rounded;
  }

  void _acceptServerFirstPage(ProductsListModel response) {
    if (!response.success) throw const FormatException('API success=false');
    filters = _localStore.loadedOnce ? _localStore.filters : response.filters;
    pagination = response.pagination;
    productsLst = response.data.map(_toProductCard).toList(growable: true);
    previewCount = response.pagination.totalItems;
    _usingLocalCatalog = false;
    initialized = true;
  }

  Future<ProductsListModel> _fetchProducts({required ShopFilterState filters, required int page, required int perPage}) async {
    final json = await _httpRequest.getProducts(
      page: page,
      perPage: perPage,
      search: filters.search,
      categories: filters.categoryIds.toList(growable: false),
      brands: filters.brandIds.toList(growable: false),
      attributes: filters.attributeOptionIds.map(
        (key, value) => MapEntry<int, List<int>>(key, value.toList(growable: false)),
      ),
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      onSale: filters.onSale,
      orderby: filters.orderby,
      order: filters.order,
    );

    if (kDebugMode) {
      debugPrint('SHOP API page=$page filterGroups=${filters.activeFilterGroupsCount} search=${filters.search}');
    }

    if (json is! Map) throw const FormatException('Invalid products response');
    final model = ProductsListModel.fromJson(Map<String, dynamic>.from(json));
    if (!model.success) throw const FormatException('Products API returned success=false');
    return model;
  }

  ProductCardModel _toProductCard(ProductsListItemModel item) {
    return ProductCardModel(
      id: item.id,
      name: item.name,
      price: item.price,
      regularPrice: item.regularPrice,
      discountPercent: item.discountPercent,
      stockQuantity: item.stockQuantity,
      image: item.image,
      variationName: item.variationName,
    );
  }

  String _friendlyError(Object error) {
    if (error is TimeoutException) return 'زمان دریافت اطلاعات فروشگاه تمام شد. دوباره تلاش کنید.';
    if (error is FormatException) return 'پاسخ دریافتی از فروشگاه قابل پردازش نیست.';
    return 'دریافت محصولات با مشکل روبه‌رو شد. اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.';
  }
}
