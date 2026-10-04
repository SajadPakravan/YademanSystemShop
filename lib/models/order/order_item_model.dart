class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
    required this.variation,
  });

  final int id;
  final String name;
  final int quantity;
  final int price;
  final String image;
  final Map<String, String> variation;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      quantity: _asInt(json['quantity'], fallback: 1),
      price: _asInt(json['price']),
      image: _asString(json['image']),
      variation: _asStringMap(json['variation']),
    );
  }

  String get variationText => variation.entries.map((entry) => '${entry.key}: ${entry.value}').join(' • ');
}

String _asString(dynamic value) => value?.toString() ?? '';

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

Map<String, String> _asStringMap(dynamic value) {
  if (value is! Map) return const <String, String>{};
  return value.map<String, String>((key, item) => MapEntry(key.toString(), item?.toString() ?? ''));
}
