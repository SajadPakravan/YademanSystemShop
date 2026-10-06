class CartResponseModel {
  const CartResponseModel({required this.success, required this.count, required this.data});

  final bool success;
  final int count;
  final List<CartItemModel> data;

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      success: json['success'] == true,
      count: _asInt(json['count']),
      data: _asList(json['data'])
          .whereType<Map>()
          .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }
}

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.productId,
    required this.variationId,
    required this.key,
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
    required this.variation,
  });

  /// The current API exposes `id`. Older/newer plugin builds may also expose
  /// `product_id`; both are normalized here so cart actions keep working.
  final int id;
  final int productId;
  final int variationId;
  final String key;
  final String name;
  final int quantity;
  final int price;
  final String image;
  final Map<String, String> variation;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id'] ?? json['product_id']);
    return CartItemModel(
      id: id,
      productId: _asInt(json['product_id'], fallback: id),
      variationId: _asInt(json['variation_id']),
      key: _asString(json['key'] ?? json['cart_item_key']),
      name: _asString(json['name']),
      quantity: _asInt(json['quantity'], fallback: 1),
      price: _asInt(json['price']),
      image: _asString(json['image']),
      variation: _asStringMap(json['variation']),
    );
  }

  CartItemModel copyWith({int? quantity}) => CartItemModel(
        id: id,
        productId: productId,
        variationId: variationId,
        key: key,
        name: name,
        quantity: quantity ?? this.quantity,
        price: price,
        image: image,
        variation: variation,
      );

  int get lineTotal => price * quantity;

  String get variationText => variation.entries
      .map((entry) => '${_humanizeVariationKey(entry.key)}: ${entry.value}')
      .join(' • ');
}

String _humanizeVariationKey(String value) {
  return value
      .replaceFirst(RegExp(r'^attribute_'), '')
      .replaceFirst(RegExp(r'^pa_'), '')
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .trim();
}

List<dynamic> _asList(dynamic value) => value is List ? value : const <dynamic>[];
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
