class ProductsListModel {
  const ProductsListModel({required this.success, required this.pagination, required this.filters, required this.filterBy, required this.data});

  final bool success;
  final ProductsPaginationModel pagination;
  final ProductsFiltersModel filters;
  final ProductsFilterByModel filterBy;
  final List<ProductsListItemModel> data;

  factory ProductsListModel.fromJson(Map<String, dynamic> json) {
    return ProductsListModel(
      success: json['success'],
      pagination: ProductsPaginationModel.fromJson(json['pagination']),
      filters: ProductsFiltersModel.fromJson(json['filters']),
      filterBy: ProductsFilterByModel.fromJson(json['filter_by']),
      data: List.castFrom(json['data']).map((item) => ProductsListItemModel.fromJson(item)).toList(growable: false),
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
      currentPage: json['current_page'],
      perPage: json['per_page'],
      totalItems: json['total_items'],
      totalPages: json['total_pages'],
      totalSiteProducts: json['total_site_products'],
      hasNext: json['has_next'],
      hasPrevious: json['has_previous'],
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
    required this.totalSales,
    required this.averageRating,
    required this.categories,
    required this.brand,
    required this.attributes,
  });

  final int id;
  final String name;
  final int price;
  final int regularPrice;
  final int discountPercent;
  final int stockQuantity;
  final String image;
  final String variationName;
  final int totalSales;
  final int averageRating;
  final List<ProductsListItemCategories> categories;
  final List<ProductsListItemBrand> brand;
  final List<ProductsListItemAttributes> attributes;

  factory ProductsListItemModel.fromJson(Map<String, dynamic> json) {
    return ProductsListItemModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      regularPrice: json['regular_price'],
      discountPercent: json['discount_percent'],
      stockQuantity: json['stock_quantity'],
      image: json['image'],
      variationName: json['variation_name'],
      totalSales: json['total_sales'],
      averageRating: json['average_rating'],
      categories: List.castFrom(json['categories']).map((item) => ProductsListItemCategories.fromJson(item)).toList(growable: false),
      brand: List.castFrom(json['brand']).map((item) => ProductsListItemBrand.fromJson(item)).toList(growable: false),
      attributes: List.castFrom(json['attributes']).map((item) => ProductsListItemAttributes.fromJson(item)).toList(growable: false),
    );
  }
}

class ProductsListItemCategories {
  const ProductsListItemCategories({required this.id, required this.name});

  final int id;
  final String name;

  factory ProductsListItemCategories.fromJson(Map<String, dynamic> json) {
    return ProductsListItemCategories(id: json['id'], name: json['name']);
  }
}

class ProductsListItemBrand {
  const ProductsListItemBrand({required this.id, required this.name});

  final int id;
  final String name;

  factory ProductsListItemBrand.fromJson(Map<String, dynamic> json) {
    return ProductsListItemBrand(id: json['id'], name: json['name']);
  }
}

class ProductsListItemAttributes {
  const ProductsListItemAttributes({required this.id, required this.name, required this.options});

  final int id;
  final String name;
  final List<ProductsListItemAttributesOptions> options;

  factory ProductsListItemAttributes.fromJson(Map<String, dynamic> json) {
    return ProductsListItemAttributes(
      id: json['id'],
      name: json['name'],
      options: List.castFrom(json['options']).map((item) => ProductsListItemAttributesOptions.fromJson(item)).toList(),
    );
  }
}

class ProductsListItemAttributesOptions {
  const ProductsListItemAttributesOptions({required this.id, required this.name});

  final int id;
  final String name;

  factory ProductsListItemAttributesOptions.fromJson(Map<String, dynamic> json) {
    return ProductsListItemAttributesOptions(id: json['id'], name: json['name']);
  }
}
