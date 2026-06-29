class ProductVariableModel {
  int? id;
  String? name;
  String? type;
  int? parentId;
  String? description;
  String? price;
  String? regularPrice;
  bool? onSale;
  int? quantity;
  String? shippingClass;
  Map<String, dynamic>? image;

  ProductVariableModel({
    this.id,
    this.name,
    this.type,
    this.description,
    this.price,
    this.regularPrice,
    this.onSale,
    this.quantity,
    this.shippingClass,
    this.image,
  });

  ProductVariableModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    parentId = json['parent_id'];
    description = json['description'];
    price = json['price'];
    regularPrice = json['regular_price'];
    onSale = json['on_sale'];
    quantity = json['stock_quantity'];
    shippingClass = json['shipping_class'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['parent_id'] = parentId;
    data['description'] = description;
    data['price'] = price;
    data['regular_price'] = regularPrice;
    data['on_sale'] = onSale;
    data['on_sale'] = quantity;
    data['on_sale'] = shippingClass;
    return data;
  }
}