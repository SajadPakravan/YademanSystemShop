import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/auth/auth_model.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/account_session_cache.dart';
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

  bool get loggedIn => user?.token.isNotEmpty == true;

  CustomerModel? get customer => user?.customer;

  String get token => user?.token ?? '';

  Future<void> initialize() async {
    initializing = true;
    final token = await AppCache.getString('token');

    if (token.isNotEmpty) {
      final customer = CustomerModel(
        id: await AppCache.getInt('id'),
        username: await AppCache.getString('username'),
        firstName: await AppCache.getString('first_name'),
        lastName: await AppCache.getString('last_name'),
        displayName: await AppCache.getString('display_name'),
        email: await AppCache.getString('email'),
        phone: await AppCache.getString('phone'),
        avatar: await AppCache.getString('avatar'),
        dateCreated: await AppCache.getString('date_created'),
        addressCount: await AppCache.getInt('address_count'),
        ordersCount: await AppCache.getInt('orders_count'),
        cartCount: await AppCache.getInt('cart_count'),
        commentsCount: await AppCache.getInt('comments_count'),
      );
      user = AuthModel(token: token, customer: customer);
    } else {
      user = null;
    }

    initializing = false;
    notifyListeners();
  }

  Future<bool> login({required String identifier, required String password}) => authenticate(
    request: () => httpRequest.login(identifier: identifier, password: password),
  );

  Future<bool> register({required String identifier, required String password}) => authenticate(
    request: () => httpRequest.register(identifier: identifier, password: password),
  );

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
        errorMessage = map['message']?.toString().trim().isNotEmpty == true ? map['message'].toString().trim() : 'عملیات احراز هویت انجام نشد.';
        return false;
      }

      final authenticated = AuthModel.fromJson(map);
      if (authenticated.token.isEmpty) {
        errorMessage = 'توکن ورود از سرور دریافت نشد.';
        return false;
      }

      AccountSessionCache.clear();
      await setAuthenticatedUser(authenticated);
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

  Future<void> setAuthenticatedUser(AuthModel authenticated) async {
    user = authenticated;
    await _saveSession(authenticated);
    errorMessage = '';
    notifyListeners();
  }

  Future<void> applyCustomer(CustomerModel customer) async {
    final current = user;
    if (current == null) return;
    user = current.copyWith(customer: customer);
    await _cacheCustomer(customer);
    notifyListeners();
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

  Future<void> _saveSession(AuthModel value) async {
    await AppCache.setString('token', value.token);
    await _cacheCustomer(value.customer);
  }

  Future<void> _cacheCustomer(CustomerModel value) async {
    await AppCache.setInt('id', value.id);
    await AppCache.setString('username', value.username);
    await AppCache.setString('first_name', value.firstName);
    await AppCache.setString('last_name', value.lastName);
    await AppCache.setString('display_name', value.displayName);
    await AppCache.setString('email', value.email);
    await AppCache.setString('phone', value.phone);
    await AppCache.setString('avatar', value.avatar);
    await AppCache.setInt('address_count', value.addressCount);
    await AppCache.setInt('orders_count', value.ordersCount);
    await AppCache.setInt('cart_count', value.cartCount);
    await AppCache.setInt('comments_count', value.commentsCount);
  }

  Future<void> logout() async {
    const keys = <String>[
      'id',
      'username',
      'first_name',
      'last_name',
      'display_name',
      'email',
      'phone',
      'avatar',
      'address_count',
      'orders_count',
      'cart_count',
      'comments_count',
      'token',
    ];
    for (final key in keys) {
      await AppCache.remove(key);
    }
    AccountSessionCache.clear();
    user = null;
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
}
