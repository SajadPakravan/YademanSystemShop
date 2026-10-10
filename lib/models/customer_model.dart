class CustomerResponseModel {
  const CustomerResponseModel({required this.success, required this.data});

  final bool success;
  final CustomerModel data;

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerResponseModel(success: json['success'], data: CustomerModel.fromJson(json['data']));
  }
}

class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatar,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.addressCount = 0,
    this.ordersCount = 0,
    this.cartCount = 0,
    this.commentsCount = 0,
  });

  final int id;
  final String username, firstName, lastName, displayName, email, phone, avatar;
  final int addressCount, ordersCount, cartCount, commentsCount;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      displayName: json['display_name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      addressCount: json['address_count'],
      ordersCount: json['orders_count'],
      cartCount: json['cart_count'],
      commentsCount: json['comments_count'],
    );
  }

  bool get personalInfoIncomplete => firstName.isEmpty || lastName.isEmpty || phone.isEmpty;
}
