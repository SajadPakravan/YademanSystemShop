import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/tools/app_log.dart';
import 'package:yad_sys/view_models/account/profile/address/addresses_view_model.dart';

class ShippingViewModel extends ChangeNotifier {
  ShippingViewModel({HttpRequest? httpRequest, required this.token, required this.shipping, required this.provinces, required this.addressesViewModel})
    : httpRequest = httpRequest ?? HttpRequest() {
    initializeControllers();
  }

  final HttpRequest httpRequest;
  final AddressesViewModel addressesViewModel;
  final String token;
  final AddressFieldsModel shipping;
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

  /// ایجاد کنترلر فقط برای فیلدهای فعال فرم ارسال.
  void initializeControllers() {
    final model = shipping;
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

      // استان در API با کد و در فیلد با نام نمایش داده می‌شود.
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
  }

  /// انتخاب استان، پاک‌کردن شهر قبلی و بازکردن فهرست شهرهای استان جدید.
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

  /// شهرهای مربوط به استان انتخاب‌شده.
  List<String> get cities {
    for (final province in provinces) {
      if (province.code == selectedProvinceCode) return province.cities;
    }
    return [];
  }

  /// ثبت نام شهر فقط در صورت وجود در استان انتخاب‌شده.
  void selectCity(String city) {
    if (!cities.contains(city)) return;
    selectedCity = city;
    fieldCtrl['city']?.text = city;
    fieldErrors.remove('city');
    saveMessage = '';
    notifyListeners();
  }

  /// پاک‌کردن خطای همان فیلد هنگام ویرایش.
  void fieldEdited(String key) {
    final changed = fieldErrors.remove(key) != null || saveMessage.isNotEmpty;
    saveMessage = '';
    if (changed) notifyListeners();
  }

  /// بررسی مقدارهای فرم ارسال پیش از ارسال درخواست PUT.
  bool fieldValidate() {
    fieldErrors.clear();
    final persian = RegExp(r'^[اآأإءؤئبپتثجچحخدذرزژسشصضطظعغفقکگلمنوهیيك \u200C]+$');
    final postcode = RegExp(r'^[0-9]{10}$');
    final phone = RegExp(r'^(?:\+98|0098|98|0)?9\d{9}$');
    final email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    for (final field in fields) {
      final key = field.keyName;
      final value = fieldCtrl[key]?.text.trim() ?? '';

      if (key == 'first_name' || key == 'last_name') {
        if (value.isEmpty) {
          fieldErrors[key] = '${field.label} را وارد کنید.';
        } else if (!persian.hasMatch(value)) {
          fieldErrors[key] = '${field.label} باید فقط شامل حروف فارسی باشد.';
        }
      } else if (key == 'state') {
        if (!provinces.any((p) => p.code == selectedProvinceCode && p.name == value)) {
          fieldErrors[key] = 'استان را از فهرست انتخاب کنید.';
        }
      } else if (key == 'city') {
        if (value.isEmpty || selectedCity != value || !cities.contains(value)) {
          fieldErrors[key] = 'شهر معتبر را از فهرست استان انتخاب کنید.';
        }
      } else if (key == 'address_1') {
        if (value.isEmpty) fieldErrors[key] = 'منطقه و خیابان را وارد کنید.';
      } else if (key == 'postcode') {
        if (value.isEmpty) {
          fieldErrors[key] = 'کدپستی را وارد کنید.';
        } else if (!postcode.hasMatch(value)) {
          fieldErrors[key] = 'کدپستی باید ۱۰ رقم باشد.';
        }
      } else if (key == 'phone') {
        if (value.isEmpty) {
          fieldErrors[key] = 'شماره همراه را وارد کنید.';
        } else if (!phone.hasMatch(value)) {
          fieldErrors[key] = 'شماره همراه معتبر نیست.';
        }
      } else if (key == 'email' && value.isNotEmpty && !email.hasMatch(value)) {
        fieldErrors[key] = 'ایمیل معتبر نیست.';
      }
    }

    notifyListeners();
    return fieldErrors.isEmpty;
  }

  /// ارسال تمام فیلدهای صورتحساب و ارسال با AddressModel.toJson در یک درخواست.
  Future<void> confirm() async {
    if (isSaving || !fieldValidate()) return;
    isSaving = true;
    saved = false;
    saveMessage = '';
    notifyListeners();

    try {
      // آخرین اطلاعات مشترک را نگه می‌داریم تا فرم دیگر بازنویسی نشود.
      final current = addressesViewModel.addresses;
      if (current == null) {
        saveMessage = 'اطلاعات آدرس موجود نیست. دوباره تلاش کنید.';
        return;
      }

      // تمام پارامترهای مدل قبلی حفظ و مقادیر فرم جایگزین می‌شوند.
      final values = Map<String, String>.from(current.shipping.addressValues);
      for (final field in fields) {
        values[field.keyName] = fieldCtrl[field.keyName]!.text.trim();
      }
      values['state'] = selectedProvinceCode!;
      values['city'] = selectedCity!;

      final updated = current.copyWith(
        shipping: AddressFieldsModel(addressValues: Map<String, String>.unmodifiable(values)),
      );
      final response = await httpRequest.updateAddresses(token: token, changes: updated.toJson());
      if (_disposed) return;

      if (response is! Map || response['success'] != true ||
          (response['status_code'] is int && (response['status_code'] < 200 || response['status_code'] >= 300))) {
        saveMessage = response is Map && response['message'] != null
            ? response['message'].toString()
            : 'ثبت آدرس ارسال انجام نشد.';
        return;
      }

      // اگر پاسخ شامل اطلاعات کامل باشد، نسخه تأییدشده سرور استفاده می‌شود.
      final responseData = response['data'];
      final savedAddresses = responseData is Map && responseData['billing'] is Map && responseData['shipping'] is Map
          ? current.copyWith(
              billing: AddressFieldsModel.fromJson(Map<String, dynamic>.from(responseData['billing'])),
              shipping: AddressFieldsModel.fromJson(Map<String, dynamic>.from(responseData['shipping'])),
            )
          : updated;

      // همگام‌سازی پیش‌نمایش آدرس‌ها و Session در حافظه.
      addressesViewModel.applyAddresses(savedAddresses);
      saved = true;
      saveMessage = 'آدرس ارسال با موفقیت ثبت شد.';
    } catch (e, stack) {
      AppLog.error('SHIPPING ADDRESS UPDATE ERROR >>> $e\n$stack');
      if (!_disposed) saveMessage = 'ثبت آدرس انجام نشد. ارتباط اینترنت را بررسی کنید.';
    } finally {
      isSaving = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// آزادسازی منابع مستقل فرم ارسال.
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
