import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/products_list_model.dart';

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
    ShopSortOption(title: 'پرفروش‌ترین', orderby: 'count_sales', order: 'desc'),
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
    Map<int, Set<int>>? attributeOptionIds,
    this.minPrice,
    this.maxPrice,
    this.orderby = 'date',
    this.order = 'desc',
    this.onSale,
  }) : categoryIds = categoryIds ?? <int>{},
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
      attributeOptionIds: <int, Set<int>>{for (final attribute in filterBy.attributes) attribute.id: attribute.options.toSet()},
      minPrice: filterBy.minPrice,
      maxPrice: filterBy.maxPrice,
      orderby: filterBy.orderby,
      order: filterBy.order,
      onSale: filterBy.onSale,
    );
  }

  ShopFilterState copy() {
    return ShopFilterState(
      search: search,
      categoryIds: Set<int>.from(categoryIds),
      brandIds: Set<int>.from(brandIds),
      attributeOptionIds: attributeOptionIds.map((key, value) => MapEntry<int, Set<int>>(key, Set<int>.from(value))),
      minPrice: minPrice,
      maxPrice: maxPrice,
      orderby: orderby,
      order: order,
      onSale: onSale,
    );
  }

  Set<int> selectedOptionsFor(int attributeId) => attributeOptionIds[attributeId] ?? <int>{};

  int get selectedAttributeOptionsCount => attributeOptionIds.values.fold<int>(0, (sum, values) => sum + values.length);

  bool get hasPriceFilter => minPrice != null || maxPrice != null;

  bool get hasNonDefaultSort => onSale == true || orderby != 'date' || order != 'desc';

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
  static const Duration _previewDebounceDuration = Duration(milliseconds: 280);
  final HttpRequest _httpRequest = HttpRequest();
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
  String? previewErrorMessage;
  int previewCount = 0;
  int priceFloor = 0;
  int priceCeiling = 500000000;
  Timer? _previewDebounce;
  int _previewRequestSerial = 0;
  ProductsListModel? _previewResponse;
  String _previewFilterKey = '';
  bool _previewReady = false;

  int get productCount => pagination.totalItems;

  bool get hasNextPage => pagination.hasNext;

  bool get canApplyPreview => _previewReady && !isPreviewLoading && previewErrorMessage == null;

  ShopSortOption get selectedSort => ShopSortOption.resolve(orderby: appliedFilters.orderby, order: appliedFilters.order, onSale: appliedFilters.onSale);

  Future<void> loadInitial() async {
    if (initialized || isInitialLoading) return;

    isInitialLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _fetchProducts(filters: ShopFilterState(), page: 1, perPage: _pageSize);
      appliedFilters = ShopFilterState.fromFilterBy(response.filterBy);
      _acceptFirstPage(response);
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
      final response = await _fetchProducts(filters: appliedFilters, page: 1, perPage: _pageSize);
      _acceptFirstPage(response);
    } catch (e) {
      errorMessage = _friendlyError(e);
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters(ShopFilterState filtersToApply) async {
    errorMessage = null;
    isInitialLoading = productsLst.isEmpty;
    notifyListeners();

    try {
      final response = await _fetchProducts(filters: filtersToApply, page: 1, perPage: _pageSize);
      appliedFilters = filtersToApply.copy();
      _acceptFirstPage(response);
    } catch (e) {
      errorMessage = _friendlyError(e);
    } finally {
      isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applySearch(String query) async {
    final value = query.trim();
    if (value.isEmpty) return false;
    final draft = ShopFilterState()..search = value;
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
      final response = await _fetchProducts(filters: appliedFilters, page: pagination.currentPage + 1, perPage: _pageSize);

      final existingIds = productsLst.map((item) => item.id).toSet();
      for (final item in response.data) {
        if (existingIds.add(item.id)) productsLst.add(_toProductCard(item));
      }
      pagination = response.pagination;
    } catch (e) {
      errorMessage = _friendlyError(e);
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void beginPreview() {
    _previewDebounce?.cancel();
    _previewRequestSerial++;
    _previewResponse = null;
    _previewFilterKey = _filterKey(appliedFilters);
    _previewReady = true;
    isPreviewLoading = false;
    previewErrorMessage = null;
    previewCount = pagination.totalItems;
    notifyListeners();
  }

  void previewFilters(ShopFilterState draft) {
    _previewDebounce?.cancel();

    final key = _filterKey(draft);
    final currentKey = _filterKey(appliedFilters);

    if (key == currentKey) {
      _previewRequestSerial++;
      _previewResponse = null;
      _previewFilterKey = key;
      _previewReady = true;
      isPreviewLoading = false;
      previewErrorMessage = null;
      previewCount = pagination.totalItems;
      notifyListeners();
      return;
    }

    _previewReady = false;
    isPreviewLoading = true;
    previewErrorMessage = null;
    final serial = ++_previewRequestSerial;
    notifyListeners();

    final snapshot = draft.copy();
    _previewDebounce = Timer(_previewDebounceDuration, () {
      _loadPreview(snapshot, serial);
    });
  }

  Future<bool> previewFiltersNow(ShopFilterState draft) async {
    _previewDebounce?.cancel();
    final key = _filterKey(draft);

    if (key == _filterKey(appliedFilters)) {
      _previewRequestSerial++;
      _previewResponse = null;
      _previewFilterKey = key;
      _previewReady = true;
      isPreviewLoading = false;
      previewErrorMessage = null;
      previewCount = pagination.totalItems;
      notifyListeners();
      return true;
    }

    final serial = ++_previewRequestSerial;
    _previewReady = false;
    isPreviewLoading = true;
    previewErrorMessage = null;
    notifyListeners();

    return _loadPreview(draft.copy(), serial);
  }

  Future<bool> _loadPreview(ShopFilterState draft, int serial) async {
    try {
      final response = await _fetchProducts(filters: draft, page: 1, perPage: _pageSize);
      if (serial != _previewRequestSerial) return false;

      _previewResponse = response;
      _previewFilterKey = _filterKey(draft);
      previewCount = response.pagination.totalItems;
      _previewReady = true;
      previewErrorMessage = null;
      return true;
    } catch (e) {
      if (serial != _previewRequestSerial) return false;
      _previewResponse = null;
      _previewReady = false;
      previewErrorMessage = _friendlyError(e);
      return false;
    } finally {
      if (serial == _previewRequestSerial) {
        isPreviewLoading = false;
        notifyListeners();
      }
    }
  }

  bool applyPreview(ShopFilterState draft) {
    if (!canApplyPreview || _previewFilterKey != _filterKey(draft)) return false;

    final response = _previewResponse;
    appliedFilters = draft.copy();

    if (response != null) {
      _acceptFirstPage(response);
    } else {
      previewCount = pagination.totalItems;
    }

    cancelPreview(notify: false);
    notifyListeners();
    return true;
  }

  void cancelPreview({bool notify = true}) {
    _previewDebounce?.cancel();
    _previewRequestSerial++;
    _previewResponse = null;
    _previewFilterKey = _filterKey(appliedFilters);
    _previewReady = true;
    isPreviewLoading = false;
    previewErrorMessage = null;
    previewCount = pagination.totalItems;
    if (notify) notifyListeners();
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

  void _acceptFirstPage(ProductsListModel response) {
    if (!response.success) throw const FormatException('API success=false');

    filters = response.filters;
    pagination = response.pagination;
    productsLst = response.data.map(_toProductCard).toList(growable: true);
    previewCount = response.pagination.totalItems;
    initialized = true;
    _updatePriceCeiling(response.data);
  }

  void _updatePriceCeiling(List<ProductCardModel> items) {
    var maxPrice = 0;
    for (final item in items) {
      if (item.price > maxPrice) maxPrice = item.price;
      if (item.regularPrice > maxPrice) maxPrice = item.regularPrice;
    }
    if (maxPrice <= 0) return;

    final rounded = ((maxPrice * 1.25) / 1000000).ceil() * 1000000;
    if (rounded > priceCeiling) priceCeiling = rounded;
  }

  Future<ProductsListModel> _fetchProducts({required ShopFilterState filters, required int page, required int perPage}) async {
    final json = await _httpRequest.getProducts(
      page: page,
      perPage: perPage,
      search: filters.search,
      categories: filters.categoryIds.toList(growable: false),
      brands: filters.brandIds.toList(growable: false),
      attributes: filters.attributeOptionIds.map((key, value) => MapEntry<int, List<int>>(key, value.toList(growable: false))),
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      onSale: filters.onSale,
      orderby: filters.orderby,
      order: filters.order,
    );

    if (kDebugMode) {
      debugPrint('SHOP API page=$page filters=${filters.activeFilterGroupsCount} search=${filters.search}');
    }

    if (json is! Map) throw const FormatException('Invalid products response');
    final model = ProductsListModel.fromJson(Map<String, dynamic>.from(json));
    if (!model.success) throw const FormatException('Products API returned success=false');
    return model;
  }

  String _filterKey(ShopFilterState state) {
    final categories = state.categoryIds.toList()..sort();
    final brands = state.brandIds.toList()..sort();
    final attributeIds = state.attributeOptionIds.entries.where((entry) => entry.value.isNotEmpty).map((entry) => entry.key).toList()..sort();
    final attributes = attributeIds
        .map((id) {
          final options = state.attributeOptionIds[id]!.toList()..sort();
          return '$id:${options.join(',')}';
        })
        .join('|');

    return <String>[
      state.search.trim(),
      categories.join(','),
      brands.join(','),
      attributes,
      '${state.minPrice ?? ''}',
      '${state.maxPrice ?? ''}',
      '${state.onSale ?? ''}',
      state.orderby,
      state.order,
    ].join('~');
  }

  ProductCardModel _toProductCard(ProductCardModel item) {
    return ProductCardModel(
      id: item.id,
      name: item.name,
      price: item.price,
      regularPrice: item.regularPrice,
      discountPercent: item.discountPercent,
      stockQuantity: item.stockQuantity,
      image: item.image,
      variationName: item.variationName,
      totalSales: item.totalSales,
      averageRating: item.averageRating,
      categories: item.categories,
      brand: item.brand,
      colors: item.colors,
    );
  }

  String _friendlyError(Object error) {
    if (error is TimeoutException) return 'زمان دریافت اطلاعات فروشگاه تمام شد. دوباره تلاش کنید.';
    if (error is FormatException) return 'پاسخ دریافتی از فروشگاه قابل پردازش نیست.';
    return 'دریافت محصولات با مشکل روبه‌رو شد. اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.';
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    super.dispose();
  }
}
