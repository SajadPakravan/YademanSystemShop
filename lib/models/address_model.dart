/// The address response contains two independent sets of fields and location options.
class AddressesResponseModel {
  const AddressesResponseModel({required this.success, required this.data});

  final bool success;
  final AddressModel data;

  factory AddressesResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['success'] != true || json['data'] is! Map) {
      throw const FormatException('Invalid addresses response: data');
    }
    return AddressesResponseModel(
      success: true,
      data: AddressModel.fromJson(Map<String, dynamic>.from(json['data'] as Map)),
    );
  }
}

class AddressModel {
  const AddressModel({required this.billing, required this.shipping, required this.locations});

  final AddressFieldsModel billing;
  final AddressFieldsModel shipping;
  final AddressLocations locations;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    if (json['billing'] is! Map || json['shipping'] is! Map || json['locations'] is! Map) {
      throw const FormatException('Invalid addresses response: billing/shipping/locations');
    }
    return AddressModel(
      billing: AddressFieldsModel.fromJson(Map<String, dynamic>.from(json['billing'] as Map)),
      shipping: AddressFieldsModel.fromJson(Map<String, dynamic>.from(json['shipping'] as Map)),
      locations: AddressLocations.fromJson(Map<String, dynamic>.from(json['locations'] as Map)),
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
    'first_name', 'last_name', 'company', 'country', 'state', 'city',
    'address_1', 'address_2', 'postcode', 'email', 'phone',
  ];

  final Map<String, String> addressValues;

  /// Only keys returned by the API are editable/visible. Missing keys stay missing.
  factory AddressFieldsModel.fromJson(Map<String, dynamic> json) {
    final values = <String, String>{};
    for (final field in standardFields) {
      if (!json.containsKey(field)) continue;
      final value = json[field];
      if (value is! String) {
        throw FormatException('Invalid address value for "$field"');
      }
      values[field] = value;
    }
    return AddressFieldsModel(addressValues: Map<String, String>.unmodifiable(values));
  }

  String value(String key) => addressValues[key] ?? '';
  bool hasField(String key) => addressValues.containsKey(key);
  bool get hasAddress => const <String>['first_name', 'last_name', 'state', 'city', 'address_1', 'postcode', 'phone']
      .any((field) => value(field).trim().isNotEmpty);
  bool get isEmpty => addressValues.values.every((value) => value.trim().isEmpty);
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(addressValues);
}

class AddressLocations {
  const AddressLocations({required this.country, required this.provinces});

  final LocationOptions country;
  final List<LocationOptions> provinces;

  factory AddressLocations.fromJson(Map<String, dynamic> json) {
    if (json['country'] is! Map || json['provinces'] is! List) {
      throw const FormatException('Invalid locations response');
    }
    return AddressLocations(
      country: LocationOptions.fromJson(Map<String, dynamic>.from(json['country'] as Map)),
      provinces: List<LocationOptions>.unmodifiable((json['provinces'] as List).map((item) {
        if (item is! Map) throw const FormatException('Invalid province entry');
        return LocationOptions.fromJson(Map<String, dynamic>.from(item));
      })),
    );
  }

  List<LocationOptions> citiesFor(String provinceCode) {
    for (final item in provinces) {
      if (item.code == provinceCode) return item.cities;
    }
    return const <LocationOptions>[];
  }
}

/// Shared code/name representation for countries, provinces and cities.
class LocationOptions {
  const LocationOptions({required this.code, required this.name, this.cities = const <LocationOptions>[]});

  final String code;
  final String name;
  final List<LocationOptions> cities;

  factory LocationOptions.fromJson(Map<String, dynamic> json) {
    final rawCode = json['code'];
    final rawName = json['name'];
    final rawCities = json['cities'];
    if ((rawCode is! String && rawCode is! int) || rawName is! String || (rawCities != null && rawCities is! List)) {
      throw const FormatException('Invalid location option');
    }
    return LocationOptions(
      code: rawCode.toString(),
      name: rawName,
      cities: rawCities == null
          ? const <LocationOptions>[]
          : List<LocationOptions>.unmodifiable((rawCities as List).map((item) {
              if (item is! Map) throw const FormatException('Invalid city entry');
              return LocationOptions.fromJson(Map<String, dynamic>.from(item));
            })),
    );
  }
}
