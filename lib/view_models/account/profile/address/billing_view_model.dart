import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/view_models/account/profile/address/addresses_view_model.dart';

class BillingViewModel extends ChangeNotifier {
  BillingViewModel({HttpRequest? httpRequest, required this.token, required this.billing, required this.provinces})
    : httpRequest = httpRequest ?? HttpRequest() {
    initializeControllers();
  }

  final HttpRequest httpRequest;
  final String token;
  final AddressFieldsModel billing;
  final List<Province> provinces;
  final Map<String, TextEditingController> fieldCtrl = {};
  final Map<String, FocusNode> fieldFocus = {};
  final Map<String, String> fieldErrors = {};
  late final List<FieldMeta> fields;
  String? selectedProvinceCode;
  String? selectedCity;
  bool _disposed = false;

  void initializeControllers() {
    final model = billing;

    fields = AddressesViewModel.fieldDefinitions.where((field) => model.hasField(field.keyName)).toList();

    final savedState = model.addressValues['state'] ?? '';

    for (final province in provinces) {
      if (province.code == savedState) {
        selectedProvinceCode = province.code;
        break;
      }
    }

    selectedCity = model.addressValues['city'];

    for (final field in fields) {
      final key = field.keyName;
      final value = model.addressValues[key] ?? '';

      String text = value;

      if (key == 'state' && selectedProvinceCode != null) {
        for (final province in provinces) {
          if (province.code == selectedProvinceCode) {
            text = province.name;
            break;
          }
        }
      }

      fieldCtrl[key] = TextEditingController(text: text);

      if (key == 'state' || key == 'city') {
        fieldFocus[key] = FocusNode();
      }
    }
  }

  void selectProvince(Province province) {
    final changed = selectedProvinceCode != province.code;

    selectedProvinceCode = province.code;
    fieldCtrl['state']?.text = province.name;

    if (changed) {
      selectedCity = null;
      fieldCtrl['city']?.clear();
    }

    notifyListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) fieldFocus['city']?.requestFocus();
    });
  }

  List<String> get cities {
    for (final province in provinces) {
      if (province.code == selectedProvinceCode) {
        return province.cities;
      }
    }
    return [];
  }

  void selectCity(String city) {
    selectedCity = city;
    fieldCtrl['city']?.text = city;
    notifyListeners();
  }

  /// حذف خطای یک فیلد پس از ویرایش آن.
  void fieldEdited(String key) {
    if (fieldErrors.remove(key) != null) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;

    for (final controller in fieldCtrl.values) {
      controller.dispose();
    }

    for (final focusNode in fieldFocus.values) {
      focusNode.dispose();
    }

    super.dispose();
  }

  bool fieldValidate(){

    return false;
  }
}
