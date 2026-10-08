import 'package:yad_sys/models/product/product_item_model.dart';

class ProductsListModel {
  const ProductsListModel({required this.success, required this.pagination, required this.filters, required this.filterBy, required this.data});

  final bool success;
  final ProductsPaginationModel pagination;
  final ProductsFiltersModel filters;
  final ProductsFilterByModel filterBy;
  final List<ProductItemModel> data;

  factory ProductsListModel.fromJson(Map<String, dynamic> json) {
    return ProductsListModel(
      success: json['success'],
      pagination: ProductsPaginationModel.fromJson(json['pagination']),
      filters: ProductsFiltersModel.fromJson(json['filters']),
      filterBy: ProductsFilterByModel.fromJson(json['filter_by']),
      data: List.castFrom(json['data']).map((item) => ProductItemModel.fromJson(item)).toList(growable: false),
    );
  }
}

/// مدل مشترک صفحه‌بندی فروشگاه و تمام فهرست‌های حساب کاربری.
/// برای APIهای دیگر، کلید total_* از طریق totalKey در totalProducts نگاشت می‌شود.
class ProductsPaginationModel {
  /// ساخت مدل صفحه‌بندی با همان فیلدهای اصلی API محصولات.
  const ProductsPaginationModel({required this.currentPage, required this.perPage, required this.totalItems, required this.totalPages, required this.totalProducts, required this.hasNext, required this.hasPrevious});

  final int currentPage;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final int totalProducts;
  final bool hasNext;
  final bool hasPrevious;

  /// مقدار کل موارد هر نوع فهرست را با یک نام خوانا در دسترس می‌گذارد.
  int get total => totalProducts;

  /// ایجاد حالت اولیه پیش از دریافت اولین پاسخ سرور.
  factory ProductsPaginationModel.empty() => const ProductsPaginationModel(currentPage: 1, perPage: 20, totalItems: 0, totalPages: 1, totalProducts: 0, hasNext: false, hasPrevious: false);

  /// خواندن صفحه‌بندی با پشتیبانی از نام اختصاصی مجموع هر API.
  factory ProductsPaginationModel.fromJson(dynamic value, {String totalKey = 'total_products', int fallbackCount = 0}) {
    final json = value is Map ? value : const <String, dynamic>{};
    int number(String key, int fallback) => int.tryParse(json[key]?.toString() ?? '') ?? fallback;
    final page = number('current_page', 1);
    final pages = number('total_pages', 1);
    final totalItems = number('total_items', fallbackCount);
    return ProductsPaginationModel(
      currentPage: page,
      perPage: number('per_page', 20),
      totalItems: totalItems,
      totalPages: pages,
      totalProducts: number(totalKey, number('total_products', number('total_site_products', totalItems))),
      hasNext: json['has_next'] is bool ? json['has_next'] == true : page < pages,
      hasPrevious: json['has_previous'] is bool ? json['has_previous'] == true : page > 1,
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
      categories: List.castFrom(json['categories']).map((item) => ProductCategoryFilterModel.fromJson(item)).toList(growable: false),
      brands: List.castFrom(json['brands']).map((item) => ProductBrandFilterModel.fromJson(item)).toList(growable: false),
      attributes: List.castFrom(json['attributes']).map((item) => ProductAttributeFilterModel.fromJson(item)).toList(growable: false),
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
  const ProductCategoryFilterModel({required this.id, required this.name, required this.count, required this.image, required this.children});

  final int id;
  final String name;
  final int count;
  final String image;
  final List<ProductCategoryFilterModel> children;

  factory ProductCategoryFilterModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryFilterModel(
      id: json['id'],
      name: json['name'],
      count: json['count'],
      image: json['image'],
      children: List.castFrom(json['children']).map((item) => ProductCategoryFilterModel.fromJson(item)).toList(growable: false),
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
    return ProductBrandFilterModel(id: json['id'], name: json['name'], count: json['count'], image: json['image']);
  }
}

class ProductAttributeFilterModel {
  const ProductAttributeFilterModel({required this.id, required this.name, required this.options});

  final int id;
  final String name;
  final List<ProductAttributeOptionModel> options;

  factory ProductAttributeFilterModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeFilterModel(
      id: json['id'],
      name: json['name'],
      options: List.castFrom(json['options']).map((item) => ProductAttributeOptionModel.fromJson(item)).toList(growable: false),
    );
  }
}

class ProductAttributeOptionModel {
  const ProductAttributeOptionModel({required this.id, required this.name, required this.color, required this.image});

  final int id;
  final String name;
  final String color;
  final String image;

  factory ProductAttributeOptionModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeOptionModel(id: json['id'], name: json['name'], color: json['color'], image: json['image']);
  }
}

class ProductsFilterByModel {
  const ProductsFilterByModel({
    required this.search,
    required this.categories,
    required this.brands,
    required this.attributes,
    required this.minPrice,
    required this.maxPrice,
    required this.onSale,
    required this.orderby,
    required this.order,
  });

  final String? search;
  final List<int> categories;
  final List<int> brands;
  final List<ProductAttributeFilterByModel> attributes;
  final int? minPrice;
  final int? maxPrice;
  final bool? onSale;
  final String orderby;
  final String order;

  factory ProductsFilterByModel.empty() {
    return const ProductsFilterByModel(
      search: null,
      categories: [],
      brands: [],
      attributes: [],
      minPrice: null,
      maxPrice: null,
      onSale: null,
      orderby: 'date',
      order: 'desc',
    );
  }

  factory ProductsFilterByModel.fromJson(Map<String, dynamic> json) {
    return ProductsFilterByModel(
      search: json['search'],
      categories: List<int>.from(json['categories']),
      brands: List<int>.from(json['brands']),
      attributes: List.castFrom(json['attributes']).map((item) => ProductAttributeFilterByModel.fromJson(item)).toList(),
      minPrice: json['min_price'],
      maxPrice: json['max_price'],
      onSale: json['on_sale'],
      orderby: json['orderby'],
      order: json['order'],
    );
  }
}

class ProductAttributeFilterByModel {
  const ProductAttributeFilterByModel({required this.id, required this.options});

  final int id;
  final List<int> options;

  factory ProductAttributeFilterByModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeFilterByModel(id: json['id'], options: List<int>.from(json['options']));
  }
}
