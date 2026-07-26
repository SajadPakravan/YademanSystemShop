class ProductCardModel {
  const ProductCardModel({
    required this.id,
    required this.name,
    required this.price,
    required this.regularPrice,
    required this.discountPercent,
    required this.stockQuantity,
    required this.image,
    this.variationName,
  });

  final int id;
  final String name;
  final int price;
  final int regularPrice;
  final int discountPercent;
  final int stockQuantity;
  final String image;
  final String? variationName;

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
    );
  }

  bool get inquiry => price == 0 || stockQuantity == 0;
}
