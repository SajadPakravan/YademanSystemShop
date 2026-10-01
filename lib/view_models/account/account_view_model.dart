import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/auth/auth_model.dart';
import 'package:yad_sys/tools/app_cache.dart';

class AccountViewModel extends ChangeNotifier {
  AccountViewModel({HttpRequest? httpRequest}) : httpRequest = httpRequest ?? HttpRequest();

  final HttpRequest httpRequest;
  AuthModel? user;
  bool initializing = true;
  bool loading = false;
  String errorMessage = '';

  bool get loggedIn => user?.token.isNotEmpty == true;

  Future<void> initialize() async {
    initializing = true;

    final token = (await AppCache.getString('token'));

    if (token.isNotEmpty) {
      user = AuthModel(
        id: (await AppCache.getInt('id')),
        username: (await AppCache.getString('username')),
        email: (await AppCache.getString('email')),
        mobile: (await AppCache.getString('mobile')),
        token: token,
      );
    }

    initializing = false;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage.isEmpty) return;
    errorMessage = '';
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

  Future<void> saveSession(AuthModel user) async {
    await AppCache.setInt('id', user.id);
    await AppCache.setString('username', user.username);
    await AppCache.setString('email', user.email);
    await AppCache.setString('mobile', user.mobile);
    await AppCache.setString('token', user.token);
  }

  Future<void> logout() async {
    const keys = <String>[
      'id',
      'username',
      'email',
      'mobile',
      'token',
      'customer_first_name',
      'customer_last_name',
      'customer_display_name',
      'customer_avatar',
      'customer_phone',
    ];
    for (final key in keys) {
      await AppCache.remove(key);
    }

    user = null;
    errorMessage = '';
    notifyListeners();
  }
}
