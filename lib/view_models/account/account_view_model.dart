import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/auth/auth_model.dart';
import 'package:yad_sys/tools/account_cache.dart';
import 'package:yad_sys/tools/app_cache.dart';
import 'package:yad_sys/tools/sessions/address_session.dart';
import 'package:yad_sys/tools/sessions/personal_info_session.dart';

class AccountViewModel extends ChangeNotifier {
  AccountViewModel({HttpRequest? httpRequest}) : httpRequest = httpRequest ?? HttpRequest();

  final HttpRequest httpRequest;
  final loginIdentifierController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final registerIdentifierController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final loginIdentifierFocus = FocusNode();
  final loginPasswordFocus = FocusNode();
  final registerIdentifierFocus = FocusNode();
  final registerPasswordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  bool hideLoginPassword = true;
  final PageController pageController = PageController(initialPage: 0);
  bool initializing = true;
  bool loading = false;
  String errorMessage = '';
  String? token;

  bool get loggedIn => token?.isNotEmpty ?? false;

  Future<void> initialize() async {
    initializing = true;

    try {
      token = await AppCache.getString('token');
    } catch (e) {
      token = null;
      errorMessage = 'بازیابی حساب انجام نشد. دوباره وارد شوید.';
    } finally {
      initializing = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String identifier, required String password}) {
    return authenticate(
      request: () => httpRequest.login(identifier: identifier, password: password),
    );
  }

  Future<bool> register({required String identifier, required String password}) {
    return authenticate(
      request: () => httpRequest.register(identifier: identifier, password: password),
    );
  }

  Future<bool> authenticate({required Future<dynamic> Function() request}) async {
    if (loading) return false;
    loading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await request();
      if (response is! Map) {
        errorMessage = 'ارتباط با سرور برقرار نشد. اتصال اینترنت را بررسی کنید.';
        return false;
      }

      final map = Map<String, dynamic>.from(response);
      if (map['success'] != true) {
        errorMessage = map['message']?.toString() ?? 'ورود انجام نشد.';
        return false;
      }

      final authenticated = AuthModel.fromJson(map);
      await AccountCache.save(auth: authenticated);
      token = authenticated.token;

      return true;
    } catch (e) {
      if (kDebugMode) print('AUTH ERROR >>>> $e');
      errorMessage = 'ارتباط با سرور برقرار نشد. اتصال اینترنت را بررسی کنید.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String? loginIdentifierValidator(String? value) {
    if (loginIdentifierController.text.trim().isEmpty) return 'شناسه کاربری را وارد کنید.';
    return null;
  }

  String? registerIdentifierValidator(String? value) {
    final identifier = registerIdentifierController.text.trim();
    if (identifier.isEmpty) return 'شناسه کاربری را وارد کنید.';
    if (identifier.contains('@')) {
      final emailRegex = RegExp(r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$");
      if (!emailRegex.hasMatch(identifier)) return 'ایمیل وارد شده معتبر نیست.';
      return null;
    }
    final normalizedMobile = identifier.replaceAll(RegExp(r'[\s-]'), '');
    final looksLikeIranMobile = normalizedMobile.startsWith('09') || normalizedMobile.startsWith('+989') || normalizedMobile.startsWith('989');
    if (looksLikeIranMobile) {
      final mobileRegex = RegExp(r'^(?:09\d{9}|\+989\d{9}|989\d{9})$');
      if (!mobileRegex.hasMatch(normalizedMobile)) return 'شماره همراه وارد شده معتبر نیست.';
      return null;
    }
    if (identifier.length < 4) return 'نام کاربری باید حداقل ۴ کاراکتر باشد.';
    return null;
  }

  String? loginPasswordValidator(String? value) => loginPasswordController.text.trim().isEmpty ? 'کلمه عبور را وارد کنید.' : null;

  String? registerPasswordValidator(String? value) {
    final password = registerPasswordController.text.trim();
    if (password.isEmpty) return 'کلمه عبور را وارد کنید.';
    if (password.length < 8) return 'کلمه عبور باید حداقل ۸ کاراکتر باشد.';
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    final confirmPassword = confirmPasswordController.text.trim();
    if (confirmPassword.isEmpty) return 'تکرار کلمه عبور را وارد کنید.';
    if (confirmPassword != registerPasswordController.text) return 'تکرار کلمه عبور با کلمه عبور یکسان نیست.';
    return null;
  }

  Future<void> submitLogin() async {
    if (loading || !(loginFormKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await login(identifier: loginIdentifierController.text.trim(), password: loginPasswordController.text);
  }

  Future<void> submitRegister() async {
    if (loading || !(registerFormKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await register(identifier: registerIdentifierController.text.trim(), password: registerPasswordController.text);
  }

  void toggleLoginPassword() {
    hideLoginPassword = !hideLoginPassword;
    notifyListeners();
  }

  Future<void> switchPage(int page) async {
    FocusManager.instance.primaryFocus?.unfocus();
    clearError();
    await pageController.animateToPage(page, duration: const Duration(milliseconds: 420), curve: Curves.easeInOutCubic);
  }

  void clearError() {
    if (errorMessage.isEmpty) return;
    errorMessage = '';
    notifyListeners();
  }

  Future<void> logout() async {
    PersonalInfoSession.clear();
    AddressSession.clear();
    await AccountCache.clear();
    token = null;
    errorMessage = '';
    notifyListeners();
  }

  void disposeFields() {
    loginIdentifierController.dispose();
    loginPasswordController.dispose();
    registerIdentifierController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    loginIdentifierFocus.dispose();
    loginPasswordFocus.dispose();
    registerIdentifierFocus.dispose();
    registerPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
  }

  @override
  void dispose() {
    pageController.dispose();
    disposeFields();
    super.dispose();
  }
}
