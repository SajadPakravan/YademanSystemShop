class SectionItemActionModel {
  const SectionItemActionModel({
    required this.title,
    required this.type,
    required this.destinationId,
    required this.onSale,
    required this.url,
    required this.orderby,
    required this.order,
  });

  final String title;
  final String? type;
  final int? destinationId;
  final bool? onSale;
  final String? url;
  final String orderby;
  final String order;

  factory SectionItemActionModel.fromJson(Map<String, dynamic> json) {
    return SectionItemActionModel(
      title: json['title'],
      type: json['type'],
      destinationId: json['destination_id'],
      onSale: json['on_sale'],
      url: json['url'],
      orderby: json['orderby'],
      order: json['order'],
    );
  }
}
