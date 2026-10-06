class AddressesResponseModel {
  const AddressesResponseModel({required this.success, required this.data, this.message = ''});

  final bool success;
  final AddressBookModel data;
  final String message;

  factory AddressesResponseModel.fromJson(Map<String, dynamic> json) {
    final root = _asMap(json);
    final nestedData = _asMap(root['data']);
    final nestedAddresses = _asMap(nestedData['addresses']);
    final source = nestedAddresses.containsKey('billing') || nestedAddresses.containsKey('shipping')
        ? nestedAddresses
        : nestedData.containsKey('billing') || nestedData.containsKey('shipping')
            ? nestedData
            : root;

    return AddressesResponseModel(
      success: root.containsKey('success') ? root['success'] == true : true,
      data: AddressBookModel.fromJson(source),
      message: _asString(root['message']),
    );
  }
}

class AddressBookModel {
  const AddressBookModel({required this.billing, required this.shipping});

  final CustomerAddressModel billing;
  final CustomerAddressModel shipping;

  factory AddressBookModel.empty() => const AddressBookModel(
    billing: CustomerAddressModel.empty(),
    shipping: CustomerAddressModel.empty(),
  );

  factory AddressBookModel.fromJson(Map<String, dynamic> json) {
    return AddressBookModel(
      billing: CustomerAddressModel.fromJson(_asMap(json['billing'])),
      shipping: CustomerAddressModel.fromJson(_asMap(json['shipping'])),
    );
  }

  bool get hasAnyAddress => billing.hasAddress || shipping.hasAddress;

  bool get isIncomplete {
    final hasEnabledFields = billing.availableFields.isNotEmpty || shipping.availableFields.isNotEmpty;
    return hasEnabledFields && !hasAnyAddress;
  }

  AddressBookModel copyWith({CustomerAddressModel? billing, CustomerAddressModel? shipping}) {
    return AddressBookModel(
      billing: billing ?? this.billing,
      shipping: shipping ?? this.shipping,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'billing': billing.toJson(),
    'shipping': shipping.toJson(),
  };
}

class CustomerAddressModel {
  const CustomerAddressModel({required this.values, required this.availableFields});

  const CustomerAddressModel.empty()
      : values = const <String, String>{},
        availableFields = const <String>{};

  static const List<String> standardFields = <String>[
    'first_name',
    'last_name',
    'company',
    'country',
    'state',
    'city',
    'address_1',
    'address_2',
    'postcode',
    'email',
    'phone',
  ];

  final Map<String, String> values;
  final Set<String> availableFields;

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) {
    final values = <String, String>{};
    final available = <String>{};

    for (final field in standardFields) {
      if (!json.containsKey(field)) continue;
      available.add(field);
      values[field] = _asString(json[field]);
    }

    // اگر پلاگین در نسخه‌های بعدی فیلد استاندارد دیگری اضافه کرد،
    // آن را هم بدون شکستن مدل حفظ می‌کنیم.
    for (final entry in json.entries) {
      if (entry.value is Map || entry.value is List) continue;
      available.add(entry.key);
      values.putIfAbsent(entry.key, () => _asString(entry.value));
    }

    return CustomerAddressModel(
      values: Map<String, String>.unmodifiable(values),
      availableFields: Set<String>.unmodifiable(available),
    );
  }

  String value(String key) => values[key] ?? '';

  bool hasField(String key) => availableFields.contains(key);

  bool get hasAddress {
    const locationFields = <String>['address_1', 'address_2', 'city', 'state', 'postcode', 'country'];
    return locationFields.any((field) => value(field).trim().isNotEmpty);
  }

  bool get isEmpty => values.values.every((value) => value.trim().isEmpty);

  CustomerAddressModel merge(Map<String, dynamic> changes) {
    final nextValues = Map<String, String>.from(values);
    final nextAvailable = Set<String>.from(availableFields);

    for (final entry in changes.entries) {
      nextAvailable.add(entry.key);
      nextValues[entry.key] = _asString(entry.value);
    }

    return CustomerAddressModel(
      values: Map<String, String>.unmodifiable(nextValues),
      availableFields: Set<String>.unmodifiable(nextAvailable),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    for (final field in availableFields) field: value(field),
  };
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String _asString(dynamic value) => value?.toString() ?? '';
