import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/account_cache.dart';
import 'package:yad_sys/tools/personal_info_session.dart';
import 'package:yad_sys/widgets/crop_image_view.dart';

/// مدل فرم مشخصات فردی با کش صرفاً حافظه‌ای پس از اولین دریافت موفق.
class PersonalInfoViewModel extends ChangeNotifier {
  /// ایجاد کنترلرهای قابل ویرایش بدون کنترلر نام نمایشی.
  PersonalInfoViewModel({required CustomerModel customer, required this.token, HttpRequest? httpRequest, ImagePicker? imagePicker})
      : _customer = PersonalInfoSession.get(customer.id) ?? customer,
        httpRequest = httpRequest ?? HttpRequest(), imagePicker = imagePicker ?? ImagePicker(),
        usernameController = TextEditingController(text: (PersonalInfoSession.get(customer.id) ?? customer).username),
        firstNameController = TextEditingController(text: (PersonalInfoSession.get(customer.id) ?? customer).firstName),
        lastNameController = TextEditingController(text: (PersonalInfoSession.get(customer.id) ?? customer).lastName),
        phoneController = TextEditingController(text: (PersonalInfoSession.get(customer.id) ?? customer).phone),
        emailController = TextEditingController(text: (PersonalInfoSession.get(customer.id) ?? customer).email);

  CustomerModel _customer;
  /// نسخه معتبر فعلی فرم برای نمایش آواتار و کنترل تغییرات.
  CustomerModel get customer => _customer;
  final String token;
  final HttpRequest httpRequest;
  final ImagePicker imagePicker;
  final TextEditingController usernameController, firstNameController, lastNameController, phoneController, emailController;
  String? usernameError, firstNameError, lastNameError, phoneError, emailError, avatarFilePath;
  bool saving = false, pickingAvatar = false, isLoading = false;
  String errorMessage = '';
  CustomerModel? updatedCustomer;
  bool _disposed = false;

  /// اطلاعات اولین بازدید از API دریافت و برای بازدیدهای بعدی در حافظه نگهداری می‌شود.
  Future<void> initialize() async {
    if (PersonalInfoSession.get(_customer.id) != null || isLoading) return;
    isLoading = true;
    errorMessage = '';
    notifyListeners();
    try {
      final response = await httpRequest.getCustomer(token: token);
      if (_disposed) return;
      if (response is! Map || response['success'] != true) throw StateError('دریافت مشخصات فردی انجام نشد.');
      final result = CustomerResponseModel.fromJson(Map<String, dynamic>.from(response));
      // شناسه سرور باید با همان حساب در حال ویرایش برابر باشد.
      if (result.data.id != _customer.id) throw StateError('شناسه پاسخ مشتری نامعتبر است.');
      _customer = result.data;
      PersonalInfoSession.save(_customer);
      _syncFields();
      await AccountCache.save(customer: _customer);
    } catch (e) {
      errorMessage = 'دریافت مشخصات فردی انجام نشد. برای تلاش مجدد صفحه را باز کنید.';
      if (kDebugMode) print('PERSONAL INFO LOAD ERROR >>> $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// تنظیم کنترلرها از آخرین مدل تأییدشده، بدون ذخیره هیچ فیلدی روی دیسک.
  void _syncFields() {
    usernameController.text = _customer.username;
    firstNameController.text = _customer.firstName;
    lastNameController.text = _customer.lastName;
    phoneController.text = _customer.phone;
    emailController.text = _customer.email;
  }

  /// مشخص می‌کند تصویر جدیدی برای ارسال انتخاب شده است.
  bool get hasAvatarChange => avatarFilePath != null && avatarFilePath!.isNotEmpty;

  /// بررسی تفاوت فیلدهای قابل ویرایش نسبت به مدل فعلی.
  bool get formChanged => usernameController.text.trim() != _customer.username ||
    firstNameController.text.trim() != _customer.firstName ||
    lastNameController.text.trim() != _customer.lastName ||
    phoneController.text.trim() != _customer.phone ||
    emailController.text.trim() != _customer.email || hasAvatarChange;

  /// بازسازی فرم بعد از هر تغییر کاربر.
  void fieldChanged() { if (errorMessage.isNotEmpty) errorMessage = ''; notifyListeners(); }

  /// کنترل اعتبار نام، نام کاربری، تلفن و ایمیل پیش از درخواست ویرایش.
  bool validate() {
    final username = usernameController.text.trim(), firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim(), phone = phoneController.text.trim(), email = emailController.text.trim();
    usernameError = username.length < 4 ? 'نام کاربری باید حداقل ۴ کاراکتر باشد.' : null;
    firstNameError = firstName.isEmpty ? 'نام را وارد کنید.' : null;
    lastNameError = lastName.isEmpty ? 'نام خانوادگی را وارد کنید.' : null;
    phoneError = phone.isEmpty ? 'شماره همراه را وارد کنید.' : !RegExp(r'^(?:\+98|0098|98|0)?9\d{9}$').hasMatch(phone) ? 'شماره همراه معتبر نیست.' : null;
    emailError = email.isNotEmpty && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) ? 'ایمیل معتبر نیست.' : null;
    notifyListeners();
    return usernameError == null && firstNameError == null && lastNameError == null && phoneError == null && emailError == null;
  }

  /// انتخاب و برش آواتار بدون تغییر اطلاعات اصلی تا قبل از ذخیره موفق.
  Future<void> pickAvatar(BuildContext context, ImageSource source) async {
    if (pickingAvatar || saving || isLoading) return;
    pickingAvatar = true; errorMessage = ''; notifyListeners();
    try {
      final picked = await imagePicker.pickImage(source: source, imageQuality: 95, maxWidth: 2400, maxHeight: 2400);
      if (picked == null || !context.mounted) return;
      final cropped = await cropImageView(context: context, imageFile: picked.path);
      if (cropped != null) avatarFilePath = cropped.path;
    } catch (e) {
      if (kDebugMode) print('AVATAR PICK ERROR >>> $e');
      errorMessage = 'انتخاب یا برش تصویر انجام نشد.';
    } finally { pickingAvatar = false; notifyListeners(); }
  }

  /// ارسال فقط فیلدهای تغییرکرده؛ display_name هرگز به PUT ارسال نمی‌شود.
  Future<bool> submit() async {
    if (saving || isLoading || PersonalInfoSession.get(_customer.id) == null || !formChanged || !validate()) return false;
    saving = true; errorMessage = ''; notifyListeners();
    try {
      final changes = <String, dynamic>{};
      // افزودن فقط فیلدهایی که کاربر تغییر داده است.
      void addChanged(String key, String value, String original) { if (value != original) changes[key] = value; }
      addChanged('username', usernameController.text.trim(), _customer.username);
      addChanged('first_name', firstNameController.text.trim(), _customer.firstName);
      addChanged('last_name', lastNameController.text.trim(), _customer.lastName);
      addChanged('email', emailController.text.trim(), _customer.email);
      addChanged('phone', phoneController.text.trim(), _customer.phone);
      if (hasAvatarChange) {
        final bytes = await File(avatarFilePath!).readAsBytes();
        changes['avatar'] = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }
      if (changes.isEmpty) return false;
      final response = await httpRequest.updateCustomer(token: token, changes: changes);
      if (response is! Map || response['success'] != true) {
        errorMessage = response is Map && response['message']?.toString().isNotEmpty == true ? response['message'].toString() : 'ویرایش مشخصات فردی انجام نشد.';
        return false;
      }
      final responseMap = Map<String, dynamic>.from(response);
      final raw = responseMap['user'] is Map ? responseMap['user'] : responseMap['data'] is Map ? responseMap['data'] : null;
      final payload = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      // اگر پاسخ ناقص باشد، مقدار فیلدهای تغییرکرده نیز با مدل ادغام می‌شود.
      final fields = Map<String, dynamic>.from(changes)..remove('avatar');
      var merged = _customer.mergeJson({...fields, ...payload});
      // وقتی PUT نام نمایشی یا آواتار نهایی را برنگرداند، فقط یک GET تکمیلی انجام می‌شود.
      if (!payload.containsKey('display_name') || (hasAvatarChange && !payload.containsKey('avatar'))) {
        final fresh = await httpRequest.getCustomer(token: token);
        if (fresh is Map && fresh['success'] == true) {
          final parsed = CustomerResponseModel.fromJson(Map<String, dynamic>.from(fresh));
          if (parsed.data.id == _customer.id) merged = parsed.data;
        }
      }
      _customer = merged;
      updatedCustomer = merged;
      avatarFilePath = null;
      _syncFields();
      PersonalInfoSession.save(merged);
      await AccountCache.save(customer: merged);
      return true;
    } catch (e) {
      if (kDebugMode) print('CUSTOMER UPDATE ERROR >>> $e');
      errorMessage = 'ویرایش مشخصات فردی انجام نشد. اتصال اینترنت را بررسی کنید.';
      return false;
    } finally { saving = false; notifyListeners(); }
  }

  /// جلوگیری از بازسازی صفحه پس از dispose.
  @override
  void notifyListeners() { if (!_disposed) super.notifyListeners(); }

  /// آزادسازی کنترلرهای فرم.
  @override
  void dispose() {
    _disposed = true;
    usernameController.dispose(); firstNameController.dispose(); lastNameController.dispose();
    phoneController.dispose(); emailController.dispose(); super.dispose();
  }
}
