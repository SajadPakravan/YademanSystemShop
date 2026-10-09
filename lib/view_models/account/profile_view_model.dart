import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/account_cache.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required this.token, HttpRequest? httpRequest}) : _httpRequest = httpRequest ?? HttpRequest();

  final HttpRequest _httpRequest;
  final String token;
  CustomerModel? customer;
  bool isRefreshing = false;
  String errorMessage = '';
  bool _disposed = false;

  bool get addressIncomplete => customer!.addressCount <= 0;

  Future<void> load() async {
    if (isRefreshing) return;
    isRefreshing = true;
    notifyListeners();

    customer = await AccountCache.getCustomer();
    isRefreshing = false;
    notifyListeners();
  }

  Future<void> refreshCustomer() async {
    if (isRefreshing) return;
    isRefreshing = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await _httpRequest.getCustomer(token: token);
      if (_disposed) return;
      if (response is! Map) {
        errorMessage = 'دریافت اطلاعات حساب کاربری انجام نشد.';
        return;
      }
      final model = CustomerResponseModel.fromJson(Map<String, dynamic>.from(response));
      if (!model.success) {
        errorMessage = response['message']?.toString() ?? 'دریافت اطلاعات حساب کاربری انجام نشد.';
        return;
      }

      applyCustomer(model.data);
    } catch (e) {
      if (kDebugMode) print('CUSTOMER REFRESH ERROR >>>> $e');
      errorMessage = 'دریافت اطلاعات حساب کاربری انجام نشد. اتصال اینترنت را بررسی کنید.';
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  /// جلوگیری از اعلان تغییرات پس از خروج از پروفایل.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> applyCustomer(CustomerModel customer) async {
    await AccountCache.save(customer: customer);
    this.customer = customer;
    notifyListeners();
  }

  Future<void> getCustomer() async {
    final customer = await AccountCache.getCustomer();
    this.customer = customer;
    print(55555555555555555);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
