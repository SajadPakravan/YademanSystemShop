class CustomerResponseModel {
  const CustomerResponseModel({required this.success, required this.data});

  final bool success;
  final CustomerModel data;

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerResponseModel(success: json['success'], data: CustomerModel.fromJson(_asMap(json['data'])));
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
    required this.cartCount,
    required this.commentsCount,
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
  final int cartCount;
  final int commentsCount;

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
      cartCount: _asInt(source['cart_count']),
      commentsCount: _asInt(source['comments_count']),
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

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String _asString(dynamic value) => value?.toString() ?? '';

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
