class CustomerResponseModel {
  const CustomerResponseModel({required this.success, required this.data});

  final bool success;
  final CustomerModel data;

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerResponseModel(success: json['success'] == true, data: CustomerModel.fromJson(_asMap(json['data'])));
  }
}

class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.dateCreated,
    required this.billing,
    required this.shipping,
    required this.ordersCount,
    required this.orders,
    required this.cartCount,
    required this.cart,
    required this.wishlistCount,
    required this.wishlist,
    required this.downloadsCount,
    required this.downloads,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String displayName;
  final String email;
  final String phone;
  final String avatar;
  final String dateCreated;
  final Billing billing;
  final Shipping shipping;
  final int ordersCount;
  final List<CustomerOrderModel> orders;
  final int cartCount;
  final List<CustomerProductItemModel> cart;
  final int wishlistCount;
  final List<CustomerProductItemModel> wishlist;
  final int downloadsCount;
  final List<CustomerDownloadModel> downloads;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final source = json['data'] is Map ? _asMap(json['data']) : json;

    return CustomerModel(
      id: _asInt(source['id']),
      username: _asString(source['username']),
      firstName: _asString(source['first_name']),
      lastName: _asString(source['last_name']),
      displayName: _asString(source['display_name']),
      email: _asString(source['email']),
      phone: _asString(source['phone']),
      avatar: _asString(source['avatar']),
      dateCreated: _asString(source['date_created']),
      billing: Billing.fromJson(_asMap(source['billing'])),
      shipping: Shipping.fromJson(_asMap(source['shipping'])),
      ordersCount: _asInt(source['orders_count']),
      orders: _asList(source['orders']).map((item) => CustomerOrderModel.fromJson(_asMap(item))).toList(growable: false),
      cartCount: _asInt(source['cart_count']),
      cart: _asList(source['cart']).map((item) => CustomerProductItemModel.fromJson(_asMap(item))).toList(growable: false),
      wishlistCount: _asInt(source['wishlist_count']),
      wishlist: _asList(source['wishlist']).map((item) => CustomerProductItemModel.fromJson(_asMap(item))).toList(growable: false),
      downloadsCount: _asInt(source['downloads_count']),
      downloads: _asList(source['downloads']).map((item) => CustomerDownloadModel.fromJson(_asMap(item))).toList(growable: false),
    );
  }

  String get fullName {
    final value = '$firstName $lastName'.trim();
    if (value.isNotEmpty) return value;
    if (displayName.isNotEmpty) return displayName;
    return username;
  }

  bool get personalInfoIncomplete => firstName.trim().isEmpty || lastName.trim().isEmpty || phone.trim().isEmpty;

  bool get addressIncomplete => billing.address1.trim().isEmpty && shipping.address1.trim().isEmpty;

  int get incompleteOrdersCount => orders.where((order) => order.status != 'completed' && order.status != 'cancelled').length;
}

class Billing {
  const Billing({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.company,
    required this.country,
    required this.state,
    required this.city,
    required this.address1,
    required this.address2,
    required this.postcode,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String company;
  final String country;
  final String state;
  final String city;
  final String address1;
  final String address2;
  final String postcode;

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      firstName: _asString(json['first_name']),
      lastName: _asString(json['last_name']),
      email: _asString(json['email']),
      phone: _asString(json['phone']),
      company: _asString(json['company']),
      country: _asString(json['country']),
      state: _asString(json['state']),
      city: _asString(json['city']),
      address1: _asString(json['address_1']),
      address2: _asString(json['address_2']),
      postcode: _asString(json['postcode']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'company': company,
    'country': country,
    'state': state,
    'city': city,
    'address_1': address1,
    'address_2': address2,
    'postcode': postcode,
  };
}

class Shipping {
  const Shipping({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.company,
    required this.country,
    required this.state,
    required this.city,
    required this.address1,
    required this.address2,
    required this.postcode,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String company;
  final String country;
  final String state;
  final String city;
  final String address1;
  final String address2;
  final String postcode;

  factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      firstName: _asString(json['first_name']),
      lastName: _asString(json['last_name']),
      phone: _asString(json['phone']),
      company: _asString(json['company']),
      country: _asString(json['country']),
      state: _asString(json['state']),
      city: _asString(json['city']),
      address1: _asString(json['address_1']),
      address2: _asString(json['address_2']),
      postcode: _asString(json['postcode']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    'company': company,
    'country': country,
    'state': state,
    'city': city,
    'address_1': address1,
    'address_2': address2,
    'postcode': postcode,
  };
}

class CustomerOrderModel {
  const CustomerOrderModel({
    required this.id,
    required this.status,
    required this.date,
    required this.total,
    required this.paymentMethod,
    required this.itemCount,
    required this.items,
  });

  final int id;
  final String status;
  final String date;
  final int total;
  final String paymentMethod;
  final int itemCount;
  final List<CustomerProductItemModel> items;

  factory CustomerOrderModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderModel(
      id: _asInt(json['id']),
      status: _asString(json['status']),
      date: _asString(json['date']),
      total: _asInt(json['total']),
      paymentMethod: _asString(json['payment_method']),
      itemCount: _asInt(json['item_count']),
      items: _asList(json['items']).map((item) => CustomerProductItemModel.fromJson(_asMap(item))).toList(growable: false),
    );
  }
}

class CustomerProductItemModel {
  const CustomerProductItemModel({
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

  factory CustomerProductItemModel.fromJson(Map<String, dynamic> json) {
    return CustomerProductItemModel(
      id: _asInt(json['id'] ?? json['product_id']),
      name: _asString(json['name']),
      quantity: _asInt(json['quantity'], fallback: 1),
      price: _asInt(json['price']),
      image: _imageString(json['image']),
      variation: _variationMap(json['variation']),
    );
  }

  String get variationText => variation.values.where((value) => value.trim().isNotEmpty).join('، ');
}

class CustomerDownloadModel {
  const CustomerDownloadModel({required this.id, required this.name, required this.url});

  final String id;
  final String name;
  final String url;

  factory CustomerDownloadModel.fromJson(Map<String, dynamic> json) {
    return CustomerDownloadModel(
      id: _asString(json['id'] ?? json['download_id'] ?? json['product_id']),
      name: _asString(json['name'] ?? json['product_name'] ?? json['file_name']),
      url: _asString(json['url'] ?? json['download_url'] ?? json['file']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) => value is List ? value : const <dynamic>[];

String _asString(dynamic value) => value?.toString() ?? '';

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String _imageString(dynamic value) {
  if (value is String) return value;
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    return _asString(map['src'] ?? map['url']);
  }
  return '';
}

Map<String, String> _variationMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value).map((key, item) => MapEntry(key, _asString(item)));
  }
  return const <String, String>{};
}
