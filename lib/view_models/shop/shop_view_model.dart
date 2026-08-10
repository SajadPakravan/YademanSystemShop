import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
    ShopSortOption(title: 'پرفروش‌ترین', orderby: 'cout_sales', order: 'desc'),
    ShopSortOption(title: 'محبوب‌ترین', orderby: 'popularity', order: 'desc'),
  ];

  static ShopSortOption resolve({required String orderby, required String order, required bool? onSale}) {
    if (onSale == true) return values[4];

    for (final option in values) {
      if (option.onSale == null && option.orderby == orderby && option.order == order) {
        return option;
      }
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
  }) : categoryIds = categoryIds ?? <int>{},
       brandIds = brandIds ?? <int>{},
       attributeOptionIds = attributeOptionIds ?? <int, Set<int>>{};

  String search;
  Set<int> categoryIds;
  Set<int> brandIds;
  int? minPrice;
  int? maxPrice;
  String orderby;
  String order;
  bool? onSale;
  Map<int, Set<int>> attributeOptionIds;

  factory ShopFilterState.fromFilterBy(ProductsFilterByModel filterBy) {
    return ShopFilterState(
      search: filterBy.search ?? '',
      categoryIds: filterBy.category.toSet(),
      brandIds: filterBy.brand.toSet(),
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
      minPrice: minPrice,
      maxPrice: maxPrice,
      orderby: orderby,
      order: order,
      onSale: onSale,
      attributeOptionIds: attributeOptionIds.map((key, value) => MapEntry<int, Set<int>>(key, Set<int>.from(value))),
    );
  }

  Set<int> selectedOptionsFor(int attributeId) {
    return attributeOptionIds[attributeId] ?? <int>{};
  }

  int get selectedAttributeOptionsCount {
    return attributeOptionIds.values.fold<int>(0, (sum, values) => sum + values.length);
  }

  bool get hasPriceFilter => minPrice != null || maxPrice != null;

  bool get hasNonDefaultSort {
    return onSale == true || orderby != 'date' || order != 'desc';
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
  static const String _endpoint = 'https://yademansystem.ir/wp-json/app-api/v1/products';
  static const int _pageSize = 20;

  final http.Client _client = http.Client();

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

  Timer? _searchDebounce;
  Timer? _previewDebounce;
  int _listRequestSerial = 0;
  int _previewRequestSerial = 0;

  int get productCount => pagination.totalItems;

  bool get hasNextPage => pagination.hasNext;

  ShopSortOption get selectedSort => ShopSortOption.resolve(orderby: appliedFilters.orderby, order: appliedFilters.order, onSale: appliedFilters.onSale);

  Future<void> loadInitial() async {
    if (isInitialLoading || initialized) return;

    isInitialLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _fetchProducts(filters: ShopFilterState(), page: 1, perPage: _pageSize);

      filters = response.filters;
      pagination = response.pagination;
      appliedFilters = ShopFilterState.fromFilterBy(response.filterBy);
      productsLst = response.data.map((item) => item.toProductCardModel()).toList(growable: true);
      previewCount = response.pagination.totalItems;
      initialized = true;

      unawaited(_loadPriceCeiling());
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

  Future<void> applyFilters(ShopFilterState draft) async {
    appliedFilters = draft.copy();
    errorMessage = null;
    isInitialLoading = productsLst.isEmpty;
    notifyListeners();

    final serial = ++_listRequestSerial;
    try {
      final response = await _fetchProducts(filters: appliedFilters, page: 1, perPage: _pageSize);
      if (serial != _listRequestSerial) return;
      _acceptFirstPage(response);
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

  void onSearchChanged(String value) {
    final normalized = value.trim();
    if (normalized == appliedFilters.search) return;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final draft = appliedFilters.copy()..search = normalized;
      applyFilters(draft);
    });
  }

  Future<void> clearSearch() async {
    if (appliedFilters.search.isEmpty) return;
    final draft = appliedFilters.copy()..search = '';
    await applyFilters(draft);
  }

  Future<void> loadMore() async {
    if (!initialized || isLoadingMore || isInitialLoading || !pagination.hasNext) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _fetchProducts(filters: appliedFilters, page: pagination.currentPage + 1, perPage: _pageSize);

      final existingIds = productsLst.map((item) => item.id).toSet();
      for (final item in response.data) {
        if (existingIds.add(item.id)) productsLst.add(item.toProductCardModel());
      }
      pagination = response.pagination;
    } catch (e) {
      errorMessage = _friendlyError(e);
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void previewFilters(ShopFilterState draft) {
    _previewDebounce?.cancel();
    final serial = ++_previewRequestSerial;
    isPreviewLoading = true;
    notifyListeners();

    _previewDebounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final response = await _fetchProducts(filters: draft, page: 1, perPage: 1);
        if (serial != _previewRequestSerial) return;
        previewCount = response.pagination.totalItems;
      } catch (_) {
        if (serial != _previewRequestSerial) return;
        previewCount = pagination.totalItems;
      } finally {
        if (serial == _previewRequestSerial) {
          isPreviewLoading = false;
          notifyListeners();
        }
      }
    });
  }

  void cancelPreview() {
    _previewDebounce?.cancel();
    _previewRequestSerial++;
    isPreviewLoading = false;
    previewCount = pagination.totalItems;
    notifyListeners();
  }

  String categoryChipTitle(ShopFilterState state) {
    if (state.categoryIds.isEmpty) return 'دسته‌بندی';
    if (state.categoryIds.length > 1) return 'دسته‌بندی';
    return filters.categoryById(state.categoryIds.first)?.name ?? 'دسته‌بندی';
  }

  String brandChipTitle(ShopFilterState state) {
    if (state.brandIds.isEmpty) return 'برند';
    if (state.brandIds.length > 1) return 'برند';
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

  Future<void> _loadPriceCeiling() async {
    try {
      final response = await _fetchProducts(
        filters: ShopFilterState(orderby: 'price', order: 'desc'),
        page: 1,
        perPage: 1,
      );
      if (response.data.isEmpty) return;

      final product = response.data.first;
      final rawMax = product.regularPrice > product.price ? product.regularPrice : product.price;
      if (rawMax <= 0) return;

      final rounded = ((rawMax * 1.1) / 1000000).ceil() * 1000000;
      priceCeiling = rounded < 10000000 ? 10000000 : rounded;
      notifyListeners();
    } catch (_) {
      // The fallback ceiling is intentionally kept when this optional request fails.
    }
  }

  void _acceptFirstPage(ProductsListModel response) {
    if (!response.success) throw const FormatException('API success=false');
    filters = response.filters;
    pagination = response.pagination;
    productsLst = response.data.map((item) => item.toProductCardModel()).toList(growable: true);
    previewCount = response.pagination.totalItems;
    initialized = true;
  }

  Future<ProductsListModel> _fetchProducts({required ShopFilterState filters, required int page, required int perPage}) async {
    final uri = Uri.parse(_endpoint).replace(
      queryParameters: _buildQuery(filters, page: page, perPage: perPage),
    );

    if (kDebugMode) debugPrint('SHOP API >>> $uri');

    final response = await _client
        .get(uri, headers: const <String, String>{'accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'})
        .timeout(const Duration(seconds: 25));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException('HTTP ${response.statusCode}', uri);
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map) throw const FormatException('Invalid products response');

    final model = ProductsListModel.fromJson(Map<String, dynamic>.from(decoded));
    if (!model.success) throw const FormatException('Products API returned success=false');
    return model;
  }

  Map<String, String> _buildQuery(ShopFilterState state, {required int page, required int perPage}) {
    final query = <String, String>{'page': '$page', 'per_page': '$perPage', 'orderby': state.orderby, 'order': state.order};

    if (state.search.trim().isNotEmpty) query['search'] = state.search.trim();
    if (state.categoryIds.isNotEmpty) query['category'] = state.categoryIds.join(',');
    if (state.brandIds.isNotEmpty) query['brand'] = state.brandIds.join(',');
    if (state.minPrice != null) query['min_price'] = '${state.minPrice}';
    if (state.maxPrice != null) query['max_price'] = '${state.maxPrice}';
    if (state.onSale != null) query['on_sale'] = state.onSale! ? 'true' : 'false';

    _writeAttributeQuery(query, state.attributeOptionIds);
    return query;
  }

  void _writeAttributeQuery(Map<String, String> query, Map<int, Set<int>> selectedAttributes) {
    // The supplied API response exposes dynamic attributes as id/name/options,
    // but its provided filter_by contract does not publish the URL key used for
    // applying attribute values. Keeping the serialization in this single method
    // makes the Flutter side ready for the API contract without spreading guessed
    // parameter names throughout the app.
    //
    // Convention used here: attribute[ATTRIBUTE_ID]=OPTION_ID,OPTION_ID
    // If the backend uses another key, only this method needs to be adjusted.
    for (final entry in selectedAttributes.entries) {
      if (entry.value.isEmpty) continue;
      query['attribute[${entry.key}]'] = entry.value.join(',');
    }
  }

  String _friendlyError(Object error) {
    if (error is TimeoutException) return 'زمان دریافت اطلاعات فروشگاه تمام شد. دوباره تلاش کنید.';
    if (error is FormatException) return 'پاسخ دریافتی از فروشگاه قابل پردازش نیست.';
    return 'دریافت محصولات با مشکل روبه‌رو شد. اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.';
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _previewDebounce?.cancel();
    _client.close();
    super.dispose();
  }
}
