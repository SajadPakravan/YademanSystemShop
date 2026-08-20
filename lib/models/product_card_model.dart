class ProductCardModel {
  const ProductCardModel({
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
    required this.colors,
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
  final String averageRating;
  final List<ProductCardCategoryModel> categories;
  final ProductCardBrandModel brand;
  final List<String> colors;

  factory ProductCardModel.fromJson(Map<String, dynamic> json) {
    return ProductCardModel(
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
      categories: List.castFrom(json['categories']).map((item) => ProductCardCategoryModel.fromJson(item)).toList(),
      brand: ProductCardBrandModel.fromJson(json['brand']),
      colors: List<String>.from(json['colors']),
    );
  }

  bool get inquiry => price == 0 || stockQuantity == 0;
}

class ProductCardCategoryModel {
  const ProductCardCategoryModel({required this.id, required this.name, required this.image});

  final int id;
  final String name;
  final String image;

  factory ProductCardCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCardCategoryModel(id: json['id'], name: json['name'], image: json['image']);
  }
}

class ProductCardBrandModel {
  const ProductCardBrandModel({required this.id, required this.name, required this.image});

  final int id;
  final String name;
  final String image;

  factory ProductCardBrandModel.fromJson(Map<String, dynamic> json) {
    return ProductCardBrandModel(id: json['id'], name: json['name'], image: json['image']);
  }
}
