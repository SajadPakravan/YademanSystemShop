import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/auth/auth_model.dart';
import 'package:yad_sys/tools/app_cache.dart';

class AccountViewModel extends ChangeNotifier {
  AccountViewModel({HttpRequest? httpRequest}) : httpRequest = httpRequest ?? HttpRequest();

  final HttpRequest httpRequest;
  AuthModel? user;
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
  late final PageController pageController;
  bool initializing = true;
  bool loading = false;
  String errorMessage = '';

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

  bool get loggedIn => user?.token.isNotEmpty == true;

  Future<void> initialize() async {
    initializing = true;

    final token = (await AppCache.getString('token'));

    if (token.isNotEmpty) {
      user = AuthModel(
        id: (await AppCache.getInt('id')),
        username: (await AppCache.getString('username')),
        email: (await AppCache.getString('email')),
        phone: (await AppCache.getString('phone')),
        token: token,
      );
    }

    initializing = false;
    notifyListeners();
  }

  Future<bool> login({required String identifier, required String password}) async {
    return authenticate(
      request: () => httpRequest.login(identifier: identifier, password: password),
    );
  }

  Future<bool> register({required String identifier, required String password}) async {
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
      final dynamic response = await request();

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        final success = map['success'] == true;
        final rawData = map['data'];

        if (success && rawData is Map) {
          final user = AuthModel.fromJson(Map<String, dynamic>.from(rawData));
          if (user.token.isEmpty) {
            errorMessage = 'توکن ورود از سرور دریافت نشد.';
            return false;
          }

          await saveSession(user);
          this.user = user;
          errorMessage = '';

          notifyListeners();
          return true;
        }

        errorMessage = map['message']?.toString().trim().isNotEmpty == true ? map['message'].toString().trim() : 'عملیات احراز هویت انجام نشد.';
        return false;
      }

      errorMessage = 'ارتباط با سرور برقرار نشد. اتصال اینترنت را بررسی کنید.';
      return false;
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
    final identifier = loginIdentifierController.text.trim();
    if (identifier.isEmpty) return 'شناسه کاربری را وارد کنید.';
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

  String? loginPasswordValidator(String? value) {
    final password = loginPasswordController.text.trim();
    if (password.isEmpty) return 'کلمه عبور را وارد کنید.';
    return null;
  }

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
    if (loading) return;
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    FocusManager.instance.primaryFocus?.unfocus();
    await login(identifier: loginIdentifierController.text.trim(), password: loginPasswordController.text);
  }

  Future<void> submitRegister() async {
    if (loading) return;
    if (!(registerFormKey.currentState?.validate() ?? false)) return;

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

  Future<void> saveSession(AuthModel user) async {
    await AppCache.setInt('id', user.id);
    await AppCache.setString('username', user.username);
    await AppCache.setString('email', user.email);
    await AppCache.setString('phone', user.phone);
    await AppCache.setString('token', user.token);
  }

  Future<void> logout() async {
    const keys = <String>['id', 'username', 'email', 'phone', 'token', 'first_name', 'last_name', 'display_name', 'avatar'];
    for (final key in keys) {
      await AppCache.remove(key);
    }

    user = null;
    errorMessage = '';
    notifyListeners();
  }
}
