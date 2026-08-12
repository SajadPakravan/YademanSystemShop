import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/products_list_model.dart';

class ProductsLocalStore {
  ProductsLocalStore._();

  static final ProductsLocalStore instance = ProductsLocalStore._();

  static const int _fullCatalogPageSize = 100;
  static const int _parallelRequests = 4;

  List<ProductsListItemModel> _products = const <ProductsListItemModel>[];
  ProductsFiltersModel _filters = ProductsFiltersModel.empty();
  ProductsFilterByModel _filterBy = ProductsFilterByModel.empty();

  bool get isReady => _products.isNotEmpty || _lastTotalSiteProducts == 0 && _loadedOnce;
  bool get loadedOnce => _loadedOnce;
  int get totalProducts => _products.length;
  ProductsFiltersModel get filters => _filters;
  ProductsFilterByModel get filterBy => _filterBy;
  List<ProductsListItemModel> get products => List<ProductsListItemModel>.unmodifiable(_products);

  bool _loadedOnce = false;
  int _lastTotalSiteProducts = -1;

  Future<void> refreshFullCatalog(HttpRequest httpRequest) async {
    final first = await _fetchPage(httpRequest, 1);

    final byId = <int, ProductsListItemModel>{
      for (final product in first.data) product.id: product,
    };

    var targetPages = first.pagination.totalPages;
    var nextPage = 2;

    while (nextPage <= targetPages) {
      final endPage = (nextPage + _parallelRequests - 1).clamp(nextPage, targetPages).toInt();
      final pages = <int>[for (var page = nextPage; page <= endPage; page++) page];
      final responses = await Future.wait<ProductsListModel>(
        pages.map((page) => _fetchPage(httpRequest, page)),
      );

      for (final response in responses) {
        if (response.pagination.totalPages > targetPages) {
          targetPages = response.pagination.totalPages;
        }
        for (final product in response.data) {
          byId[product.id] = product;
        }
      }
      nextPage = endPage + 1;
    }

    // Map ترتیب درج را حفظ می‌کند؛ چون صفحات را به ترتیب API اضافه کردیم،
    // ترتیب پیش‌فرض date/desc سرور نیز حفظ می‌شود.
    final orderedProducts = byId.values.toList(growable: false);

    // Atomic replacement: the old cache remains untouched until every page succeeds.
    _products = List<ProductsListItemModel>.unmodifiable(orderedProducts);
    _filters = first.filters;
    _filterBy = first.filterBy;
    _lastTotalSiteProducts = first.pagination.totalSiteProducts;
    _loadedOnce = true;
  }

  Future<ProductsListModel> _fetchPage(HttpRequest httpRequest, int page) async {
    final json = await httpRequest.getProducts(page: page, perPage: _fullCatalogPageSize);
    if (json is! Map) {
      throw const FormatException('Invalid products response');
    }
    final model = ProductsListModel.fromJson(Map<String, dynamic>.from(json));
    if (!model.success) {
      throw const FormatException('Products API returned success=false');
    }
    return model;
  }

  List<ProductsListItemModel> page({required int page, required int perPage}) {
    if (page < 1 || perPage < 1 || _products.isEmpty) return const <ProductsListItemModel>[];
    final start = (page - 1) * perPage;
    if (start >= _products.length) return const <ProductsListItemModel>[];
    final end = (start + perPage).clamp(start, _products.length).toInt();
    return _products.sublist(start, end);
  }

  int totalPagesFor(int perPage) {
    if (perPage <= 0 || _products.isEmpty) return 1;
    return (_products.length / perPage).ceil();
  }

  int maxPrice() {
    var result = 0;
    for (final product in _products) {
      final candidate = product.regularPrice > product.price ? product.regularPrice : product.price;
      if (candidate > result) result = candidate;
    }
    return result;
  }

  int countMatching({
    String search = '',
    Set<int> categoryIds = const <int>{},
    Set<int> brandIds = const <int>{},
    Map<int, Set<int>> attributeOptionIds = const <int, Set<int>>{},
    int? minPrice,
    int? maxPrice,
    bool? onSale,
  }) {
    return filterProducts(
      search: search,
      categoryIds: categoryIds,
      brandIds: brandIds,
      attributeOptionIds: attributeOptionIds,
      minPrice: minPrice,
      maxPrice: maxPrice,
      onSale: onSale,
    ).length;
  }

  List<ProductsListItemModel> filterProducts({
    String search = '',
    Set<int> categoryIds = const <int>{},
    Set<int> brandIds = const <int>{},
    Map<int, Set<int>> attributeOptionIds = const <int, Set<int>>{},
    int? minPrice,
    int? maxPrice,
    bool? onSale,
  }) {
    if (_products.isEmpty) return const <ProductsListItemModel>[];

    final normalizedSearch = _normalize(search);
    final expandedCategories = _expandCategoryIds(categoryIds);

    return _products.where((product) {
      if (normalizedSearch.length >= 3 && !_productContains(product, normalizedSearch)) {
        return false;
      }

      if (expandedCategories.isNotEmpty && !product.categories.any((category) => expandedCategories.contains(category.id))) {
        return false;
      }

      if (brandIds.isNotEmpty && !product.brand.any((brand) => brandIds.contains(brand.id))) {
        return false;
      }

      for (final entry in attributeOptionIds.entries) {
        if (entry.value.isEmpty) continue;
        ProductsListItemAttributes? attribute;
        for (final item in product.attributes) {
          if (item.id == entry.key) {
            attribute = item;
            break;
          }
        }
        if (attribute == null || !attribute.options.any((option) => entry.value.contains(option.id))) {
          return false;
        }
      }

      if (minPrice != null && product.price < minPrice) return false;
      if (maxPrice != null && product.price > maxPrice) return false;
      if (onSale == true && product.discountPercent <= 0) return false;
      if (onSale == false && product.discountPercent > 0) return false;

      return true;
    }).toList(growable: false);
  }

  List<ProductCategoryFilterModel> searchCategories(String query, {int limit = 6}) {
    final normalized = _normalize(query);
    if (normalized.length < 3) return const <ProductCategoryFilterModel>[];
    return _filters.flatCategories
        .where((item) => _normalize(item.name).contains(normalized))
        .take(limit)
        .toList(growable: false);
  }

  List<ProductBrandFilterModel> searchBrands(String query, {int limit = 6}) {
    final normalized = _normalize(query);
    if (normalized.length < 3) return const <ProductBrandFilterModel>[];
    return _filters.brands
        .where((item) => _normalize(item.name).contains(normalized))
        .take(limit)
        .toList(growable: false);
  }

  List<ProductsListItemModel> searchProducts(String query, {int limit = 12}) {
    final normalized = _normalize(query);
    if (normalized.length < 3) return const <ProductsListItemModel>[];
    return _products.where((product) => _productContains(product, normalized)).take(limit).toList(growable: false);
  }

  Set<int> _expandCategoryIds(Set<int> selected) {
    if (selected.isEmpty) return const <int>{};
    final result = <int>{};

    void addTree(ProductCategoryFilterModel item) {
      result.add(item.id);
      for (final child in item.children) {
        addTree(child);
      }
    }

    for (final id in selected) {
      final item = _filters.categoryById(id);
      if (item == null) {
        result.add(id);
      } else {
        addTree(item);
      }
    }
    return result;
  }

  bool _productContains(ProductsListItemModel product, String normalizedQuery) {
    if (_normalize(product.name).contains(normalizedQuery)) return true;
    if (_normalize(product.variationName).contains(normalizedQuery)) return true;
    if (product.categories.any((item) => _normalize(item.name).contains(normalizedQuery))) return true;
    if (product.brand.any((item) => _normalize(item.name).contains(normalizedQuery))) return true;
    for (final attribute in product.attributes) {
      if (_normalize(attribute.name).contains(normalizedQuery)) return true;
      if (attribute.options.any((option) => _normalize(option.name).contains(normalizedQuery))) return true;
    }
    return false;
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ي', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll('\u200c', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
