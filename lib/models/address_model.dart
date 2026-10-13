class AddressesResponseModel {
  const AddressesResponseModel({required this.success, required this.data});

  final bool success;
  final AddressModel data;

  factory AddressesResponseModel.fromJson(Map<String, dynamic> json) {
    return AddressesResponseModel(success: json['success'], data: AddressModel.fromJson(json['data']));
  }
}

class AddressModel {
  const AddressModel({required this.billing, required this.shipping, required this.locations});

  final AddressFieldsModel billing;
  final AddressFieldsModel shipping;
  final AddressLocations locations;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      billing: AddressFieldsModel.fromJson(json['billing']),
      shipping: AddressFieldsModel.fromJson(json['shipping']),
      locations: AddressLocations.fromJson(json['locations']),
    );
  }

  bool get hasAnyAddress => billing.hasAddress || shipping.hasAddress;

  AddressModel copyWith({AddressFieldsModel? billing, AddressFieldsModel? shipping, AddressLocations? locations}) =>
      AddressModel(billing: billing ?? this.billing, shipping: shipping ?? this.shipping, locations: locations ?? this.locations);

  Map<String, dynamic> toJson() => <String, dynamic>{'billing': billing.toJson(), 'shipping': shipping.toJson()};
}

class AddressFieldsModel {
  const AddressFieldsModel({required this.addressValues});

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

  final Map<String, String> addressValues;

  factory AddressFieldsModel.fromJson(Map<String, dynamic> json) {
    final values = <String, String>{};

    for (final field in standardFields) {
      if (!json.containsKey(field)) continue;

      final value = json[field];
      values[field] = value;
    }
    return AddressFieldsModel(addressValues: Map<String, String>.unmodifiable(values));
  }

  String value(String key) => addressValues[key] ?? '';

  bool hasField(String key) => addressValues.containsKey(key);

  bool get hasAddress =>
      const <String>['first_name', 'last_name', 'state', 'city', 'address_1', 'address_2', 'postcode', 'phone'].any((field) => value(field).trim().isNotEmpty);

  bool get isEmpty => addressValues.values.every((value) => value.trim().isEmpty);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(addressValues);
}

class AddressLocations {
  const AddressLocations({required this.provinces});

  final List<Province> provinces;

  factory AddressLocations.fromJson(Map<String, dynamic> json) {
    return AddressLocations(provinces: List.castFrom(json['provinces']).map((item) => Province.fromJson(item)).toList());
  }
}

class Province {
  const Province({required this.code, required this.name, required this.cities});

  final String code;
  final String name;
  final List<String> cities;

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(code: json['code'], name: json['name'], cities: List<String>.from(json['cities']));
  }
}
