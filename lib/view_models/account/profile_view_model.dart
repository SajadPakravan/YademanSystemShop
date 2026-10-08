import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/account_cache.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required this.token, required CustomerModel initialCustomer, this.onCustomerUpdated, HttpRequest? httpRequest})
    : customer = initialCustomer,
      _httpRequest = httpRequest ?? HttpRequest();

  final String token;
  final HttpRequest _httpRequest;
  final ValueChanged<CustomerModel>? onCustomerUpdated;
  CustomerModel customer;
  bool isRefreshing = false;
  String errorMessage = '';
  bool _disposed = false;

  bool get addressIncomplete => customer.addressCount <= 0;

  /// درخواست تازه اطلاعات و شمارنده‌های مشتری برای بروزرسانی منوی پروفایل.
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
      // هر بار سرور شمارنده‌ها و نام نمایشی را به‌روز می‌کند؛ سایر اطلاعات خصوصی فقط در مدل حافظه‌ای باقی می‌مانند.
      customer = model.data;
      await AccountCache.save(customer: customer);
      onCustomerUpdated?.call(customer);
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

  void applyCustomer(CustomerModel customer) {
    AccountCache.save(customer: customer);
    this.customer = customer;
    notifyListeners();
  }

  /// پایان عمر مدل و قطع بروزرسانی‌های دیرهنگام.
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
