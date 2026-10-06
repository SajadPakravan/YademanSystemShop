class CustomerResponseModel {
  const CustomerResponseModel({required this.success, required this.data, this.message = ''});

  final bool success;
  final CustomerModel data;
  final String message;

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    final source = json['user'] is Map
        ? _asMap(json['user'])
        : json['data'] is Map
        ? _asMap(json['data'])
        : json;

    return CustomerResponseModel(
      success: json.containsKey('success') ? json['success'] == true : true,
      data: CustomerModel.fromJson(source),
      message: _asString(json['message']),
    );
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
    required this.addressCount,
    required this.ordersCount,
    required this.cartCount,
    required this.commentsCount,
  });

  const CustomerModel.empty()
    : id = 0,
      username = '',
      firstName = '',
      lastName = '',
      displayName = '',
      email = '',
      phone = '',
      avatar = '',
      dateCreated = '',
      addressCount = 0,
      ordersCount = 0,
      cartCount = 0,
      commentsCount = 0;

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String displayName;
  final String email;
  final String phone;
  final String avatar;
  final String dateCreated;
  final int addressCount;
  final int ordersCount;
  final int cartCount;
  final int commentsCount;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final source = json['user'] is Map
        ? _asMap(json['user'])
        : json['data'] is Map
        ? _asMap(json['data'])
        : json;

    return CustomerModel(
      id: _asInt(source['id']),
      username: _asString(source['username']),
      firstName: _asString(source['first_name']),
      lastName: _asString(source['last_name']),
      displayName: _asString(source['display_name']),
      email: _asString(source['email']),
      phone: _asString(source['phone'] ?? source['mobile']),
      avatar: _asString(source['avatar']),
      dateCreated: _asString(source['date_created']),
      addressCount: _asInt(source['address_count']),
      ordersCount: _asInt(source['orders_count']),
      cartCount: _asInt(source['cart_count']),
      commentsCount: _asInt(source['comments_count']),
    );
  }

  CustomerModel mergeJson(Map<String, dynamic> json) {
    final source = json['user'] is Map
        ? _asMap(json['user'])
        : json['data'] is Map
        ? _asMap(json['data'])
        : json;

    return copyWith(
      id: source.containsKey('id') ? _asInt(source['id'], fallback: id) : id,
      username: source.containsKey('username') ? _asString(source['username']) : username,
      firstName: source.containsKey('first_name') ? _asString(source['first_name']) : firstName,
      lastName: source.containsKey('last_name') ? _asString(source['last_name']) : lastName,
      displayName: source.containsKey('display_name') ? _asString(source['display_name']) : displayName,
      email: source.containsKey('email') ? _asString(source['email']) : email,
      phone: source.containsKey('phone') || source.containsKey('mobile') ? _asString(source['phone'] ?? source['mobile']) : phone,
      avatar: source.containsKey('avatar') ? _asString(source['avatar']) : avatar,
      dateCreated: source.containsKey('date_created') ? _asString(source['date_created']) : dateCreated,
      addressCount: source.containsKey('address_count') ? _asInt(source['address_count'], fallback: addressCount) : addressCount,
      ordersCount: source.containsKey('orders_count') ? _asInt(source['orders_count'], fallback: ordersCount) : ordersCount,
      cartCount: source.containsKey('cart_count') ? _asInt(source['cart_count'], fallback: cartCount) : cartCount,
      commentsCount: source.containsKey('comments_count') ? _asInt(source['comments_count'], fallback: commentsCount) : commentsCount,
    );
  }

  CustomerModel copyWith({
    int? id,
    String? username,
    String? firstName,
    String? lastName,
    String? displayName,
    String? email,
    String? phone,
    String? avatar,
    String? dateCreated,
    int? addressCount,
    int? ordersCount,
    int? cartCount,
    int? commentsCount,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      dateCreated: dateCreated ?? this.dateCreated,
      addressCount: addressCount ?? this.addressCount,
      ordersCount: ordersCount ?? this.ordersCount,
      cartCount: cartCount ?? this.cartCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'username': username,
    'first_name': firstName,
    'last_name': lastName,
    'display_name': displayName,
    'email': email,
    'phone': phone,
    'avatar': avatar,
    'date_created': dateCreated,
    'address_count': addressCount,
    'orders_count': ordersCount,
    'cart_count': cartCount,
    'comments_count': commentsCount,
  };

  bool get personalInfoIncomplete => firstName.trim().isEmpty || lastName.trim().isEmpty || phone.trim().isEmpty;
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
