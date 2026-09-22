class SectionItemActionModel {
  const SectionItemActionModel({
    required this.title,
    required this.type,
    required this.productId,
    required this.categoryId,
    required this.brandId,
    required this.onSale,
    required this.url,
    required this.orderby,
    required this.order,
  });

  final String title;
  final String? type;
  final int? productId;
  final List<int> categoryId;
  final List<int> brandId;
  final bool? onSale;
  final String? url;
  final String orderby;
  final String order;

  factory SectionItemActionModel.fromJson(Map<String, dynamic> json) {
    return SectionItemActionModel(
      title: json['title'],
      type: json['type'],
      productId: json['product_id'],
      categoryId: List<int>.from(json['category_id']),
      brandId: List<int>.from(json['brand_id']),
      onSale: json['on_sale'],
      url: json['url'],
      orderby: json['orderby'],
      order: json['order'],
    );
  }
}
