/// پاسخ API آدرس همراه با فهرست استان‌ها و شهرهای احتمالی.
class AddressesResponseModel {
  /// مدل موفقیت و اطلاعات دریافت‌شده.
  const AddressesResponseModel({required this.success, required this.data});
  final bool success;
  final AddressBookModel data;

  /// پشتیبانی از پاسخ data.billing و نیز data.addresses.billing.
  factory AddressesResponseModel.fromJson(Map<String, dynamic> json) {
    // اگر locations کنار data آمده باشد، پیش از تبدیل به مدل به داده‌ها اضافه می‌شود.
    final data = Map<String, dynamic>.from(json['data'] is Map ? json['data'] as Map : json);
    if (data['locations'] is! Map && json['locations'] is Map) data['locations'] = json['locations'];
    return AddressesResponseModel(
      success: json['success'] == true,
      data: AddressBookModel.fromJson(data),
    );
  }
}

/// دفترچه شامل هر دو آدرس و اطلاعات مکانی دریافت‌شده از API.
class AddressBookModel {
  /// ایجاد مدل دفترچه آدرس با فهرست استان‌های یکسان برای هر دو تب.
  const AddressBookModel({required this.billing, required this.shipping, required this.locations});
  final CustomerAddressModel billing;
  final CustomerAddressModel shipping;
  final AddressLocations locations;

  /// ساخت مدل مستقل از اینکه آدرس‌ها در کلید addresses باشند یا مستقیم در data.
  factory AddressBookModel.fromJson(Map<String, dynamic> json) {
    final source = json['addresses'] is Map ? Map<String, dynamic>.from(json['addresses']) : json;
    final locations = json['locations'] is Map ? json['locations'] as Map : source['locations'] is Map ? source['locations'] as Map : const <String, dynamic>{};
    return AddressBookModel(
      billing: CustomerAddressModel.fromJson(Map<String, dynamic>.from(source['billing'] is Map ? source['billing'] as Map : const {})),
      shipping: CustomerAddressModel.fromJson(Map<String, dynamic>.from(source['shipping'] is Map ? source['shipping'] as Map : const {})),
      locations: AddressLocations.fromJson(Map<String, dynamic>.from(locations)),
    );
  }

  /// آیا آدرس صورتحساب یا ارسال پر شده است؟
  bool get hasAnyAddress => billing.hasAddress || shipping.hasAddress;

  /// نگهداری استان‌ها و تغییر فقط آدرس انتخاب‌شده.
  AddressBookModel copyWith({CustomerAddressModel? billing, CustomerAddressModel? shipping, AddressLocations? locations}) => AddressBookModel(
    billing: billing ?? this.billing, shipping: shipping ?? this.shipping, locations: locations ?? this.locations,
  );

  /// ساخت payload دو آدرس در صورت نیاز به عملیات جایگزینی کامل.
  Map<String, dynamic> toJson() => <String, dynamic>{'billing': billing.toJson(), 'shipping': shipping.toJson()};
}

/// فیلدهای آدرس و مجموعه نام فیلدهای فعال سرور.
class CustomerAddressModel {
  /// ایجاد مدل مقادیر و کلیدهای ارسال‌شده توسط API.
  const CustomerAddressModel({required this.values, required this.availableFields});

  /// فیلدهای پشتیبانی‌شده در فرم آدرس فعلی.
  static const List<String> standardFields = <String>[
    'first_name', 'last_name', 'company', 'country', 'state', 'city',
    'address_1', 'address_2', 'postcode', 'email', 'phone',
  ];
  final Map<String, String> values;
  final Set<String> availableFields;

  /// تبدیل امن فیلدهای موجود بدون اجبار به وجود فیلدهای اختیاری.
  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) {
    final values = <String, String>{};
    final available = <String>{};
    for (final field in standardFields) {
      if (!json.containsKey(field)) continue;
      available.add(field);
      values[field] = json[field]?.toString() ?? '';
    }
    return CustomerAddressModel(values: Map<String, String>.unmodifiable(values), availableFields: Set<String>.unmodifiable(available));
  }

  /// خواندن مقدار رشته‌ای فیلد.
  String value(String key) => values[key] ?? '';
  /// تشخیص فعال بودن فیلد طبق پاسخ API.
  bool hasField(String key) => availableFields.contains(key);
  /// بررسی وجود اطلاعات مکانی کافی برای نمایش آدرس ثبت‌شده.
  bool get hasAddress => const <String>['address_1','address_2','city','state','postcode','country'].any((field) => value(field).isNotEmpty);
  /// بررسی خالی بودن تمام فیلدهای آدرس.
  bool get isEmpty => values.values.every((value) => value.trim().isEmpty);

  /// ادغام پاسخ ناقص PUT یا تغییرات تاییدشده با آدرس فعلی.
  CustomerAddressModel merge(Map<String, String> changes) => CustomerAddressModel.fromJson({...toJson(), ...changes});

  /// نگهداری فقط فیلدهای موجود هنگام ارسال API.
  Map<String, dynamic> toJson() => <String, dynamic>{for (final field in availableFields) field: value(field)};
}

/// مجموعه مکان‌های برگردانده‌شده همراه آدرس.
class AddressLocations {
  /// لیست استان‌ها و شهرها؛ شهرها ممکن است فعلاً خالی باشند.
  const AddressLocations({required this.provinces, required this.cities});
  final List<Province> provinces;
  final List<City> cities;

  /// دریافت provinces و cities با سازگاری نسبت به آرایه خالی یا فقدان کلید.
  factory AddressLocations.fromJson(Map<String, dynamic> json) => AddressLocations(
    provinces: (json['provinces'] is List ? json['provinces'] as List : const []).whereType<Map>()
      .map((value) => Province.fromJson(Map<String, dynamic>.from(value))).toList(growable: false),
    cities: (json['cities'] is List ? json['cities'] as List : const []).whereType<Map>()
      .map((value) => City.fromJson(Map<String, dynamic>.from(value))).toList(growable: false),
  );
}

/// استان دارای کد برای API و نام برای نمایش در combobox.
class Province {
  /// مدل گزینه استان.
  const Province({required this.code, required this.name});
  final String code;
  final String name;
  /// تبدیل JSON به گزینه استان حتی اگر کد به‌صورت عددی باشد.
  factory Province.fromJson(Map<String, dynamic> json) => Province(code: json['code']?.toString() ?? '', name: json['name']?.toString() ?? '');
}

/// ساختار آماده شهرها، بدون فعال‌سازی انتخابگر تا زمان تکمیل داده‌های API.
class City {
  /// مدل اطلاعات شهر.
  const City({required this.code, required this.name});
  final String code;
  final String name;
  /// تبدیل JSON شهر، برای استفاده در توسعه بعدی.
  factory City.fromJson(Map<String, dynamic> json) => City(code: json['code']?.toString() ?? '', name: json['name']?.toString() ?? '');
}
