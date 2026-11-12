import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/tools/app_log.dart';
import 'package:yad_sys/view_models/account/profile/address/addresses_view_model.dart';

class BillingViewModel extends ChangeNotifier {
  BillingViewModel({HttpRequest? httpRequest, required this.token, required this.billing, required this.provinces, required this.addressesViewModel})
    : httpRequest = httpRequest ?? HttpRequest() {
    initializeControllers();
  }

  final HttpRequest httpRequest;
  final AddressesViewModel addressesViewModel;
  final String token;
  final AddressFieldsModel billing;
  final List<Province> provinces;
  final Map<String, TextEditingController> fieldCtrl = {};
  final Map<String, FocusNode> fieldFocus = {};
  final Map<String, String> fieldErrors = {};
  late final List<FieldMeta> fields;
  String? selectedProvinceCode;
  String? selectedCity;
  bool isSaving = false;
  bool saved = false;
  String saveMessage = '';
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
      if (key == 'state' || key == 'city') fieldFocus[key] = FocusNode();
    }

    for (final field in fields) {
      final key = field.keyName;

      fieldCtrl[key] = TextEditingController(text: billing.value(key));

      fieldFocus[key] = FocusNode();
    }
  }

  void selectProvince(Province province) {
    final changed = selectedProvinceCode != province.code;
    selectedProvinceCode = province.code;
    fieldCtrl['state']?.text = province.name;

    if (changed) {
      selectedCity = null;
      fieldCtrl['city']?.clear();
      fieldErrors.remove('city');
    }
    fieldErrors.remove('state');
    saveMessage = '';
    notifyListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) fieldFocus['city']?.requestFocus();
    });
  }

  List<String> get cities {
    for (final province in provinces) {
      if (province.code == selectedProvinceCode) return province.cities;
    }
    return [];
  }

  void selectCity(String city) {
    if (!cities.contains(city)) return;
    selectedCity = city;
    fieldCtrl['city']?.text = city;
    fieldErrors.remove('city');
    saveMessage = '';
    notifyListeners();
  }

  void fieldEdited(String key) {
    final changed = fieldErrors.remove(key) != null || saveMessage.isNotEmpty;
    saveMessage = '';
    if (changed) notifyListeners();
  }

  bool fieldValidate() {
    fieldErrors.clear();
    final postcode = RegExp(r'^[0-9]{10}$');
    final phone = RegExp(r'^(?:\+98|0098|98|0)?9\d{9}$');
    final email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    for (final field in fields) {
      final key = field.keyName;
      final value = fieldCtrl[key]?.text.trim() ?? '';

      if ((key == 'first_name' || key == 'last_name' || key == 'address_1' || key == 'address_2' || key == 'postcode' || key == 'phone') && value.isEmpty) {
        fieldErrors[key] = '${field.label} را وارد کنید';
      } else if ((key == 'state' || key == 'city') && value.isEmpty) {
        fieldErrors[key] = '${field.label} را انتخاب کنید';
      } else if (key == 'postcode' && !postcode.hasMatch(value)) {
        fieldErrors[key] = 'کدپستی معتبر نیست';
      } else if (key == 'phone' && !phone.hasMatch(value)) {
        fieldErrors[key] = 'شماره همراه معتبر نیست';
      } else if (key == 'email' && value.isNotEmpty && !email.hasMatch(value)) {
        fieldErrors[key] = 'ایمیل معتبر نیست';
      }
    }

    notifyListeners();
    return fieldErrors.isEmpty;
  }

  Future<void> confirm() async {
    if (isSaving || !fieldValidate()) return;
    isSaving = true;
    saved = false;
    saveMessage = '';
    notifyListeners();

    final values = <String, String>{for (final entry in fieldCtrl.entries) entry.key: entry.value.text.trim()};

    values['state'] = selectedProvinceCode!;

    final billing = AddressFieldsModel(addressValues: Map<String, String>.unmodifiable(values));

    final Map<String, dynamic> address = {'billing': billing.toJson()};

    try {
      final response = await httpRequest.updateAddresses(token: token, address: address);

      if (response['success'] != true) {
        saveMessage = response['message'].toString();
        return;
      }

      final current = addressesViewModel.addresses!;

      final newBilling = AddressFieldsModel(addressValues: Map<String, String>.from(address['billing']));

      final savedAddresses = AddressModel(billing: newBilling, shipping: current.shipping, locations: current.locations);

      addressesViewModel.applyAddresses(savedAddresses);
      saved = true;
      saveMessage = 'آدرس صورتحساب با موفقیت ثبت شد';

    } catch (e, stack) {
      AppLog.error('BILLING ADDRESS UPDATE ERROR >>> $e\n$stack');
      if (!_disposed) saveMessage = 'ثبت آدرس انجام نشد. ارتباط اینترنت را بررسی کنید.';
    } finally {
      isSaving = false;
      if (!_disposed) notifyListeners();
    }
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
}
