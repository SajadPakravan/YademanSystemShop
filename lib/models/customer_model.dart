/// پاسخ خواندن اطلاعات مشتری از سرور.
class CustomerResponseModel {
  /// نتیجه درخواست و مدل داده‌های مشتری.
  const CustomerResponseModel({required this.success, required this.data});
  final bool success;
  final CustomerModel data;

  /// تبدیل پاسخ JSON به مدل مشتری.
  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    // برخی پاسخ‌ها اطلاعات را در data و برخی در user برمی‌گردانند.
    final raw = json['data'] is Map ? json['data'] : json['user'];
    return CustomerResponseModel(
      success: json['success'] == true,
      data: CustomerModel.fromJson(Map<String, dynamic>.from(raw is Map ? raw : const {})),
    );
  }
}

/// اطلاعات مشتری؛ فقط شناسه، نام نمایشی و شمارنده‌ها روی دیسک ذخیره می‌شوند.
class CustomerModel {
  /// فیلدهای غیرضروری برای کش دیسکی مقدار اولیه خالی دارند.
  const CustomerModel({
    required this.id, required this.username, required this.displayName,
    this.firstName = '', this.lastName = '', this.email = '', this.phone = '', this.avatar = '',
    this.addressCount = 0, this.ordersCount = 0, this.cartCount = 0,
    this.commentsCount = 0, this.favoritesCount = 0, this.viewedProductsCount = 0,
  });
  final int id;
  final String username, firstName, lastName, displayName, email, phone, avatar;
  final int addressCount, ordersCount, cartCount, commentsCount, favoritesCount, viewedProductsCount;

  /// تبدیل اعداد و رشته‌های پاسخ API با مقادیر پیش‌فرض امن.
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    int number(String key) => int.tryParse(json[key]?.toString() ?? '') ?? 0;
    String string(String key) => json[key]?.toString() ?? '';
    return CustomerModel(
      id: number('id'), username: string('username'), displayName: string('display_name'),
      firstName: string('first_name'), lastName: string('last_name'), email: string('email'),
      phone: string('phone'), avatar: string('avatar'),
      addressCount: number('address_count'), ordersCount: number('orders_count'),
      cartCount: number('cart_count'), commentsCount: number('comments_count'),
      favoritesCount: number('favorites_count'), viewedProductsCount: number('viewed_products_count'),
    );
  }

  /// ادغام پاسخ ناقص ویرایش با اطلاعات فعلی، بدون پاک‌کردن فیلدهای بازنگشته.
  CustomerModel mergeJson(Map<String, dynamic> changes) => CustomerModel.fromJson({
    ...toJson(),
    'id': id, 'address_count': addressCount, 'orders_count': ordersCount,
    'cart_count': cartCount, 'comments_count': commentsCount,
    'favorites_count': favoritesCount, 'viewed_products_count': viewedProductsCount,
    ...Map<String, dynamic>.fromEntries(changes.entries.where((entry) => entry.value != null)),
  });

  /// ایجاد نسخه جدید مدل، بدون تغییر بقیه اطلاعات مشتری.
  CustomerModel copyWith({int? id, String? username, String? firstName, String? lastName,
    String? displayName, String? email, String? phone, String? avatar,
    int? addressCount, int? ordersCount, int? cartCount, int? commentsCount,
    int? favoritesCount, int? viewedProductsCount}) => CustomerModel(
      id: id ?? this.id, username: username ?? this.username,
      firstName: firstName ?? this.firstName, lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName, email: email ?? this.email,
      phone: phone ?? this.phone, avatar: avatar ?? this.avatar,
      addressCount: addressCount ?? this.addressCount, ordersCount: ordersCount ?? this.ordersCount,
      cartCount: cartCount ?? this.cartCount, commentsCount: commentsCount ?? this.commentsCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      viewedProductsCount: viewedProductsCount ?? this.viewedProductsCount,
    );

  /// ساخت داده‌های قابل ادغام در حافظه؛ display_name قابل ویرایش نیست و در payload ویرایش ارسال نمی‌شود.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'username': username, 'first_name': firstName, 'last_name': lastName,
    'display_name': displayName, 'email': email, 'phone': phone, 'avatar': avatar,
  };

  /// نمایش وضعیت تکمیل فرم فقط براساس داده‌های بارگذاری‌شده در حافظه.
  bool get personalInfoIncomplete => firstName.isEmpty || lastName.isEmpty || phone.isEmpty;
}
