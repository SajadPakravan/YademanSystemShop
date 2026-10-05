import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/app_cache.dart';
import 'package:yad_sys/widgets/crop_image_view.dart';

class PersonalInfoViewModel extends ChangeNotifier {
  PersonalInfoViewModel({
    required this.customer,
    required this.token,
    HttpRequest? httpRequest,
    ImagePicker? imagePicker,
  })  : httpRequest = httpRequest ?? HttpRequest(),
        imagePicker = imagePicker ?? ImagePicker(),
        usernameController = TextEditingController(text: customer.username),
        firstNameController = TextEditingController(text: customer.firstName),
        lastNameController = TextEditingController(text: customer.lastName),
        phoneController = TextEditingController(text: customer.phone),
        emailController = TextEditingController(text: customer.email),
        displayNameController = TextEditingController(text: customer.displayName);

  final CustomerModel customer;
  final String token;
  final HttpRequest httpRequest;
  final ImagePicker imagePicker;
  final TextEditingController usernameController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController displayNameController;
  String? usernameError;
  String? firstNameError;
  String? lastNameError;
  String? phoneError;
  String? emailError;
  String? avatarFilePath;
  bool saving = false;
  bool pickingAvatar = false;
  String errorMessage = '';

  bool get hasAvatarChange => avatarFilePath != null && avatarFilePath!.isNotEmpty;

  bool get dirty =>
      usernameController.text.trim() != customer.username ||
      firstNameController.text.trim() != customer.firstName ||
      lastNameController.text.trim() != customer.lastName ||
      displayNameController.text.trim() != customer.displayName ||
      phoneController.text.trim() != customer.phone ||
      emailController.text.trim() != customer.email ||
      hasAvatarChange;

  void fieldChanged() {
    if (errorMessage.isNotEmpty) errorMessage = '';
    notifyListeners();
  }

  bool validate() {
    final username = usernameController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    usernameError = username.length < 4 ? 'نام کاربری باید حداقل ۴ کاراکتر باشد.' : null;
    firstNameError = firstName.isEmpty ? 'نام را وارد کنید.' : null;
    lastNameError = lastName.isEmpty ? 'نام خانوادگی را وارد کنید.' : null;
    phoneError = phone.isEmpty
        ? 'شماره همراه را وارد کنید.'
        : !RegExp(r'^(?:\+98|0098|98|0)?9\d{9}$').hasMatch(phone)
            ? 'شماره همراه معتبر نیست.'
            : null;
    emailError = email.isNotEmpty && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) ? 'ایمیل معتبر نیست.' : null;

    notifyListeners();
    return usernameError == null && firstNameError == null && lastNameError == null && phoneError == null && emailError == null;
  }

  Future<void> pickAvatar(BuildContext context, ImageSource source) async {
    if (pickingAvatar || saving) return;
    pickingAvatar = true;
    errorMessage = '';
    notifyListeners();

    try {
      final picked = await imagePicker.pickImage(
        source: source,
        imageQuality: 95,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (picked == null) return;

      if (!context.mounted) return;
      final cropped = await cropImageView(context: context, imageFile: picked.path);
      if (cropped == null) return;

      avatarFilePath = cropped.path;
    } catch (e) {
      if (kDebugMode) print('AVATAR PICK/CROP ERROR >>> $e');
      errorMessage = 'انتخاب یا برش تصویر انجام نشد.';
    } finally {
      pickingAvatar = false;
      notifyListeners();
    }
  }

  Future<bool> submit() async {
    if (saving || !dirty) return false;
    if (!validate()) return false;

    saving = true;
    errorMessage = '';
    notifyListeners();

    try {
      final changes = <String, dynamic>{};

      void addChanged(String key, String current, String original) {
        if (current != original) changes[key] = current;
      }

      addChanged('username', usernameController.text.trim(), customer.username);
      addChanged('first_name', firstNameController.text.trim(), customer.firstName);
      addChanged('last_name', lastNameController.text.trim(), customer.lastName);
      addChanged('display_name', displayNameController.text.trim(), customer.displayName);
      addChanged('email', emailController.text.trim(), customer.email);
      addChanged('phone', phoneController.text.trim(), customer.phone);

      if (hasAvatarChange) {
        final bytes = await File(avatarFilePath!).readAsBytes();
        changes['avatar'] = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      if (changes.isEmpty) return false;

      final response = await httpRequest.updateCustomer(token: token, changes: changes);
      if (response is! Map || response['success'] != true) {
        errorMessage = response is Map && response['message']?.toString().trim().isNotEmpty == true
            ? response['message'].toString().trim()
            : 'ویرایش مشخصات فردی انجام نشد.';
        return false;
      }

      CustomerModel? updatedCustomer;
      if (response['data'] is Map) {
        updatedCustomer = CustomerModel.fromJson(Map<String, dynamic>.from(response['data'] as Map));
      }
      await _updateCache(updatedCustomer);
      return true;
    } catch (e) {
      if (kDebugMode) print('CUSTOMER UPDATE ERROR >>> $e');
      errorMessage = 'ویرایش مشخصات فردی انجام نشد. اتصال اینترنت را بررسی کنید.';
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> _updateCache(CustomerModel? updated) async {
    final username = updated?.username ?? usernameController.text.trim();
    final firstName = updated?.firstName ?? firstNameController.text.trim();
    final lastName = updated?.lastName ?? lastNameController.text.trim();
    final displayName = updated?.displayName ?? displayNameController.text.trim();
    final email = updated?.email ?? emailController.text.trim();
    final phone = updated?.phone ?? phoneController.text.trim();

    await AppCache.setString('username', username);
    await AppCache.setString('first_name', firstName);
    await AppCache.setString('last_name', lastName);
    await AppCache.setString('display_name', displayName);
    await AppCache.setString('email', email);
    await AppCache.setString('phone', phone);
    if (updated != null && updated.avatar.trim().isNotEmpty) {
      await AppCache.setString('avatar', updated.avatar);
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    displayNameController.dispose();
    super.dispose();
  }
}
