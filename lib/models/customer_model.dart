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

  /// ادغام پاسخ ناقص ویرایش با اطلاعات فعلی، بدون پاک‌کردن فیلدهای بازنگشته.
  CustomerModel mergeJson(Map<String, dynamic> changes) => CustomerModel.fromJson({
    ...toJson(),
    'id': id,
    'address_count': addressCount,
    'orders_count': ordersCount,
    'cart_count': cartCount,
    'comments_count': commentsCount,
    ...Map<String, dynamic>.fromEntries(changes.entries.where((entry) => entry.value != null)),
  });

  /// ایجاد نسخه جدید مدل، بدون تغییر بقیه اطلاعات مشتری.
  CustomerModel copyWith({
    int? id,
    String? username,
    String? firstName,
    String? lastName,
    String? displayName,
    String? email,
    String? phone,
    String? avatar,
    int? addressCount,
    int? ordersCount,
    int? cartCount,
    int? commentsCount,
    int? favoritesCount,
    int? viewedProductsCount,
  }) => CustomerModel(
    id: id ?? this.id,
    username: username ?? this.username,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    avatar: avatar ?? this.avatar,
    addressCount: addressCount ?? this.addressCount,
    ordersCount: ordersCount ?? this.ordersCount,
    cartCount: cartCount ?? this.cartCount,
    commentsCount: commentsCount ?? this.commentsCount,
  );

  /// ساخت داده‌های قابل ادغام در حافظه؛ display_name قابل ویرایش نیست و در payload ویرایش ارسال نمی‌شود.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'username': username,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'avatar': avatar,
  };

  bool get personalInfoIncomplete => firstName.isEmpty || lastName.isEmpty || phone.isEmpty;
}
