import 'package:yad_sys/models/customer_model.dart';

class OrderModel {
  int? id;
  String? status;
  String? dateCreated;
  String? dateModified;
  String? shippingTotal;
  String? total;
  int? customerId;
  Billing? billing;
  Shipping? shipping;
  String? paymentMethod;
  String? paymentMethodTitle;
  String? dateCompleted;
  String? datePaid;
  List<LineItems>? lineItems;
  List<ShippingLines>? shippingLines;
  bool? needsPayment;
  bool? needsProcessing;

  OrderModel({
    this.id,
    this.status,
    this.dateCreated,
    this.dateModified,
    this.shippingTotal,
    this.total,
    this.customerId,
    this.billing,
    this.shipping,
    this.paymentMethod,
    this.paymentMethodTitle,
    this.dateCompleted,
    this.datePaid,
    this.lineItems,
    this.shippingLines,
    this.needsPayment,
    this.needsProcessing,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    dateCreated = json['date_created'];
    dateModified = json['date_modified'];
    shippingTotal = json['shipping_total'];
    total = json['total'];
    customerId = json['customer_id'];
    billing = json['billing'] != null ? Billing.fromJson(json['billing']) : null;
    shipping = json['shipping'] != null ? Shipping.fromJson(json['shipping']) : null;
    paymentMethod = json['payment_method'];
    paymentMethodTitle = json['payment_method_title'];
    dateCompleted = json['date_completed'];
    datePaid = json['date_paid'];
    if (json['line_items'] != null) {
      lineItems = <LineItems>[];
      json['line_items'].forEach((v) {
        lineItems!.add(LineItems.fromJson(v));
      });
    }
    if (json['shipping_lines'] != null) {
      shippingLines = <ShippingLines>[];
      json['shipping_lines'].forEach((v) {
        shippingLines!.add(ShippingLines.fromJson(v));
      });
    }
    needsPayment = json['needs_payment'];
    needsProcessing = json['needs_processing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['date_created'] = dateCreated;
    data['date_modified'] = dateModified;
    data['shipping_total'] = shippingTotal;
    data['total'] = total;
    data['customer_id'] = customerId;
    if (billing != null) data['billing'] = billing!.toJson();
    if (shipping != null) data['shipping'] = shipping!.toJson();
    data['payment_method'] = paymentMethod;
    data['payment_method_title'] = paymentMethodTitle;
    data['date_completed'] = dateCompleted;
    data['date_paid'] = datePaid;
    if (lineItems != null) data['line_items'] = lineItems!.map((v) => v.toJson()).toList();
    if (shippingLines != null) data['shipping_lines'] = shippingLines!.map((v) => v.toJson()).toList();
    data['needs_payment'] = needsPayment;
    data['needs_processing'] = needsProcessing;
    return data;
  }
}

class LineItems {
  int? id;
  String? name;
  int? productId;
  int? quantity;
  String? subtotal;
  String? total;
  int? price;
  OrderItemsImage? image;

  LineItems({
    this.id,
    this.name,
    this.productId,
    this.quantity,
    this.subtotal,
    this.total,
    this.price,
    this.image,
  });

  LineItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    productId = json['product_id'];
    quantity = json['quantity'];
    subtotal = json['subtotal'];
    total = json['total'];
    price = json['price'];
    image = json['image'] != null ? OrderItemsImage.fromJson(json['image']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['product_id'] = productId;
    data['quantity'] = quantity;
    data['subtotal'] = subtotal;
    data['total'] = total;
    data['price'] = price;
    if (image != null) data['image'] = image!.toJson();
    return data;
  }
}

class OrderItemsImage {
  String? src;

  OrderItemsImage({this.src});

  OrderItemsImage.fromJson(Map<String, dynamic> json) {
    src = json['src'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['src'] = src;
    return data;
  }
}

class ShippingLines {
  String? methodTitle;
  String? methodId;
  String? total;

  ShippingLines({
    this.methodTitle,
    this.methodId,
    this.total,
  });

  ShippingLines.fromJson(Map<String, dynamic> json) {
    methodTitle = json['method_title'];
    methodId = json['method_id'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['method_title'] = methodTitle;
    data['method_id'] = methodId;
    data['total'] = total;
    return data;
  }
}
