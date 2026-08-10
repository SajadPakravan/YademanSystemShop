import 'package:yad_sys/models/product_card_model.dart';

class ProductsListModel {
  const ProductsListModel({required this.success, required this.pagination, required this.filters, required this.filterBy, required this.data});

  final bool success;
  final ProductsPaginationModel pagination;
  final ProductsFiltersModel filters;
  final ProductsFilterByModel filterBy;
  final List<ProductsListItemModel> data;

  factory ProductsListModel.fromJson(Map<String, dynamic> json) {
    return ProductsListModel(
      success: _asBool(json['success']),
      pagination: ProductsPaginationModel.fromJson(_asMap(json['pagination'])),
      filters: ProductsFiltersModel.fromJson(_asMap(json['filters'])),
      filterBy: ProductsFilterByModel.fromJson(_asMap(json['filter_by'])),
      data: _asList(json['data']).whereType<Map>().map((item) => ProductsListItemModel.fromJson(Map<String, dynamic>.from(item))).toList(growable: false),
    );
  }
}

class ProductsPaginationModel {
  const ProductsPaginationModel({
    required this.currentPage,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.totalSiteProducts,
    required this.hasNext,
    required this.hasPrevious,
  });

  final int currentPage;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final int totalSiteProducts;
  final bool hasNext;
  final bool hasPrevious;

  factory ProductsPaginationModel.empty() {
    return const ProductsPaginationModel(currentPage: 1, perPage: 20, totalItems: 0, totalPages: 1, totalSiteProducts: 0, hasNext: false, hasPrevious: false);
  }

  factory ProductsPaginationModel.fromJson(Map<String, dynamic> json) {
    return ProductsPaginationModel(
      currentPage: _asInt(json['current_page'], fallback: 1),
      perPage: _asInt(json['per_page'], fallback: 20),
      totalItems: _asInt(json['total_items']),
      totalPages: _asInt(json['total_pages'], fallback: 1),
      totalSiteProducts: _asInt(json['total_site_products']),
      hasNext: _asBool(json['has_next']),
      hasPrevious: _asBool(json['has_previous']),
    );
  }
}

class ProductsFiltersModel {
  const ProductsFiltersModel({required this.categories, required this.brands, required this.attributes});

  final List<ProductCategoryFilterModel> categories;
  final List<ProductBrandFilterModel> brands;
  final List<ProductAttributeFilterModel> attributes;

  factory ProductsFiltersModel.empty() {
    return const ProductsFiltersModel(categories: [], brands: [], attributes: []);
  }

  factory ProductsFiltersModel.fromJson(Map<String, dynamic> json) {
    return ProductsFiltersModel(
      categories: _asList(
        json['category'],
      ).whereType<Map>().map((item) => ProductCategoryFilterModel.fromJson(Map<String, dynamic>.from(item))).toList(growable: false),
      brands: _asList(json['brand']).whereType<Map>().map((item) => ProductBrandFilterModel.fromJson(Map<String, dynamic>.from(item))).toList(growable: false),
      attributes: _asList(
        json['attribute'],
      ).whereType<Map>().map((item) => ProductAttributeFilterModel.fromJson(Map<String, dynamic>.from(item))).toList(growable: false),
    );
  }

  List<ProductCategoryFilterModel> get flatCategories {
    final result = <ProductCategoryFilterModel>[];

    void addTree(ProductCategoryFilterModel item) {
      result.add(item);
      for (final child in item.children) {
        addTree(child);
      }
    }

    for (final category in categories) {
      addTree(category);
    }
    return result;
  }

  ProductCategoryFilterModel? categoryById(int id) {
    for (final item in flatCategories) {
      if (item.id == id) return item;
    }
    return null;
  }

  ProductBrandFilterModel? brandById(int id) {
    for (final item in brands) {
      if (item.id == id) return item;
    }
    return null;
  }

  ProductAttributeFilterModel? attributeById(int id) {
    for (final item in attributes) {
      if (item.id == id) return item;
    }
    return null;
  }
}

class ProductCategoryFilterModel {
  const ProductCategoryFilterModel({required this.id, required this.name, required this.image, required this.children});

  final int id;
  final String name;
  final String image;
  final List<ProductCategoryFilterModel> children;

  factory ProductCategoryFilterModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryFilterModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      image: _asString(json['image']),
      children: _asList(
        json['children'],
      ).whereType<Map>().map((item) => ProductCategoryFilterModel.fromJson(Map<String, dynamic>.from(item))).toList(growable: false),
    );
  }
}

class ProductBrandFilterModel {
  const ProductBrandFilterModel({required this.id, required this.name, required this.count, required this.image});

  final int id;
  final String name;
  final int count;
  final String image;

  factory ProductBrandFilterModel.fromJson(Map<String, dynamic> json) {
    return ProductBrandFilterModel(id: _asInt(json['id']), name: _asString(json['name']), count: _asInt(json['count']), image: _asString(json['image']));
  }
}

class ProductAttributeFilterModel {
  const ProductAttributeFilterModel({required this.id, required this.name, required this.options});

  final int id;
  final String name;
  final List<ProductAttributeOptionModel> options;

  factory ProductAttributeFilterModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeFilterModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      options: _asList(
        json['options'],
      ).whereType<Map>().map((item) => ProductAttributeOptionModel.fromJson(Map<String, dynamic>.from(item))).toList(growable: false),
    );
  }
}

class ProductAttributeOptionModel {
  const ProductAttributeOptionModel({required this.id, required this.name});

  final int id;
  final String name;

  factory ProductAttributeOptionModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeOptionModel(id: _asInt(json['id']), name: _asString(json['name']));
  }
}

class ProductsFilterByModel {
  const ProductsFilterByModel({
    required this.search,
    required this.category,
    required this.brand,
    required this.minPrice,
    required this.maxPrice,
    required this.onSale,
    required this.orderby,
    required this.order,
  });

  final String? search;
  final List<int> category;
  final List<int> brand;
  final int? minPrice;
  final int? maxPrice;
  final bool? onSale;
  final String orderby;
  final String order;

  factory ProductsFilterByModel.empty() {
    return const ProductsFilterByModel(search: null, category: [], brand: [], minPrice: null, maxPrice: null, onSale: null, orderby: 'date', order: 'desc');
  }

  factory ProductsFilterByModel.fromJson(Map<String, dynamic> json) {
    return ProductsFilterByModel(
      search: _nullableString(json['search']),
      category: _asIntList(json['category']),
      brand: _asIntList(json['brand']),
      minPrice: _nullableInt(json['min_price']),
      maxPrice: _nullableInt(json['max_price']),
      onSale: _nullableBool(json['on_sale']),
      orderby: _asString(json['orderby'], fallback: 'date'),
      order: _asString(json['order'], fallback: 'desc'),
    );
  }
}

class ProductsListItemModel {
  const ProductsListItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.regularPrice,
    required this.discountPercent,
    required this.stockQuantity,
    required this.image,
    required this.variationName,
  });

  final int id;
  final String name;
  final int price;
  final int regularPrice;
  final int discountPercent;
  final int stockQuantity;
  final String image;
  final String variationName;

  factory ProductsListItemModel.fromJson(Map<String, dynamic> json) {
    return ProductsListItemModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      price: _asInt(json['price']),
      regularPrice: _asInt(json['regular_price']),
      discountPercent: _asInt(json['discount_percent']),
      stockQuantity: _asInt(json['stock_quantity']),
      image: _asString(json['image']),
      variationName: _asString(json['variation_name']),
    );
  }

  ProductCardModel toProductCardModel() {
    return ProductCardModel(
      id: id,
      name: name,
      price: price,
      regularPrice: regularPrice,
      discountPercent: discountPercent,
      stockQuantity: stockQuantity,
      image: image,
      variationName: variationName,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return const <dynamic>[];
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final result = value.toString();
  return result.isEmpty ? fallback : result;
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final result = value.toString().trim();
  return result.isEmpty || result.toLowerCase() == 'null' ? null : result;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _nullableInt(dynamic value) {
  if (value == null || value == '') return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString());
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    if (value.toLowerCase() == 'true' || value == '1') return true;
    if (value.toLowerCase() == 'false' || value == '0') return false;
  }
  return fallback;
}

bool? _nullableBool(dynamic value) {
  if (value == null || value == '') return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    if (value.toLowerCase() == 'true' || value == '1') return true;
    if (value.toLowerCase() == 'false' || value == '0') return false;
  }
  return null;
}

List<int> _asIntList(dynamic value) {
  if (value == null) return const <int>[];

  final raw = value is List ? value : value.toString().split(',');
  final result = <int>[];
  for (final item in raw) {
    final parsed = _nullableInt(item);
    if (parsed != null && !result.contains(parsed)) result.add(parsed);
  }
  return result;
}
