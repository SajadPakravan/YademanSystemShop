import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/tools/app_log.dart';
import 'package:yad_sys/view_models/account/profile/address/addresses_view_model.dart';

class AddressFormViewModel extends ChangeNotifier {
  AddressFormViewModel({
    HttpRequest? httpRequest,
    required this.token,
    required this.address,
    required this.addressKey,
    required this.provinces,
    required this.addressesViewModel,
  }) : assert(addressKey == 'billing' || addressKey == 'shipping'),
       httpRequest = httpRequest ?? HttpRequest(),
       _savedAddress = address {
    initializeControllers();
  }

  final HttpRequest httpRequest;
  final AddressesViewModel addressesViewModel;
  final String token;
  final String addressKey;
  final AddressFieldsModel address;
  final List<Province> provinces;

  /// مقادیر مرجع برای تشخیص تغییر فرم؛ پس از ذخیره موفق به‌روزرسانی می‌شود.
  AddressFieldsModel _savedAddress;

  /// کنترلر، فوکوس و خطاهای این نمونه از فرم، مستقل از فرم دیگر هستند.
  final Map<String, TextEditingController> fieldCtrl = {};
  final Map<String, FocusNode> fieldFocus = {};
  final Map<String, String> fieldErrors = {};
  late final List<FieldMeta> fields;
  String? selectedProvinceCode;
  String? selectedCity;
  bool isSaving = false;
  bool saved = false;
  String saveMessage = '';
  bool enabledBtn = false;
  bool _disposed = false;

  bool get isBilling => addressKey == 'billing';

  String get title => isBilling ? 'آدرس صورتحساب' : 'آدرس ارسال';

  String get description => isBilling
      ? 'این آدرس برای ثبت مشخصات خریدار و صدور صورتحساب سفارش استفاده می‌شود. اگر کالا را در محل دیگری دریافت می‌کنید، آدرس ارسال را جداگانه ثبت کنید.'
      : 'کالاهای سفارش شما به این نشانی فرستاده می‌شوند. نام گیرنده، شماره همراه و جزئیات محل تحویل را دقیق وارد کنید تا ارسال بدون مشکل انجام شود.';

  /// ساخت کنترلرها فقط برای فیلدهای فعال API، و تبدیل کد استان به نام نمایشی.
  void initializeControllers() {
    final model = address;
    fields = AddressesViewModel.fieldDefinitions.where((field) => model.hasField(field.keyName) && (isBilling || field.keyName != 'email')).toList();

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
      fieldFocus[key] = FocusNode();
    }
  }

  /// ثبت استان و پاک‌کردن شهر قبلی در صورت تغییر استان.
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
    activeConfirm();
    notifyListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) fieldFocus['city']?.requestFocus();
    });
  }

  /// دریافت شهرهای استان انتخاب‌شده از فهرست API.
  List<String> get cities {
    for (final province in provinces) {
      if (province.code == selectedProvinceCode) return province.cities;
    }
    return [];
  }

  /// انتخاب شهر فقط از میان شهرهای استان فعلی.
  void selectCity(String city) {
    if (!cities.contains(city)) return;
    selectedCity = city;
    fieldCtrl['city']?.text = city;
    fieldErrors.remove('city');
    saveMessage = '';
    activeConfirm();
    notifyListeners();
  }

  /// حذف خطای فیلد پس از ویرایش و بررسی فعال‌شدن دکمه ثبت.
  void fieldEdited(String key) {
    final changed = fieldErrors.remove(key) != null || saveMessage.isNotEmpty;
    saveMessage = '';
    activeConfirm();
    if (changed) notifyListeners();
  }

  /// اعتبارسنجی همان فیلدهای فرم‌های قبلی؛ ایمیل تنها در صورت ورود بررسی می‌شود.
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

  /// فعال‌کردن دکمه فقط زمانی که فرم با اطلاعات آخرین ثبت تفاوت دارد.
  void activeConfirm() {
    final values = <String, String>{for (final entry in fieldCtrl.entries) entry.key: entry.value.text.trim()};
    values['state'] = selectedProvinceCode ?? '';

    final isEmpty = values.values.every((value) => value.isEmpty);
    final isChanged = fields.any((field) => values[field.keyName] != (_savedAddress.addressValues[field.keyName] ?? '').trim());
    final enabled = !isEmpty && isChanged && !isSaving;

    if (enabledBtn != enabled) {
      enabledBtn = enabled;
      notifyListeners();
    }
  }

  /// ارسال تمامی فیلدهای همین فرم با toJson و همگام‌سازی پاسخ API با Session.
  Future<void> confirm() async {
    if (isSaving || !enabledBtn || !fieldValidate()) return;
    isSaving = true;
    enabledBtn = false;
    saved = false;
    saveMessage = '';
    notifyListeners();

    final values = <String, String>{for (final entry in fieldCtrl.entries) entry.key: entry.value.text.trim()};
    values['state'] = selectedProvinceCode ?? '';

    final updatedAddress = AddressFieldsModel(addressValues: values);
    final Map<String, dynamic> addressData = {addressKey: updatedAddress.toJson()};

    try {
      final response = await httpRequest.updateAddresses(token: token, address: addressData);
      if (_disposed) return;

      if (response['success'] != true) {
        saveMessage = response['message']?.toString() ?? 'ثبت آدرس انجام نشد';
        return;
      }

      final savedAddresses = AddressesResponseModel.fromJson(Map<String, dynamic>.from(response as Map)).data;
      addressesViewModel.applyAddresses(savedAddresses);
      _savedAddress = isBilling ? savedAddresses.billing : savedAddresses.shipping;
      saved = true;
      saveMessage = '$title با موفقیت ثبت شد';
    } catch (e, stack) {
      AppLog.error('${addressKey.toUpperCase()} ADDRESS UPDATE ERROR >>> $e\n$stack');
      if (!_disposed) saveMessage = 'ثبت آدرس انجام نشد. ارتباط اینترنت را بررسی کنید.';
    } finally {
      isSaving = false;
      if (!_disposed) {
        activeConfirm();
        notifyListeners();
      }
    }
  }

  /// آزادسازی منابع همان صفحه پس از بسته‌شدن آن.
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
