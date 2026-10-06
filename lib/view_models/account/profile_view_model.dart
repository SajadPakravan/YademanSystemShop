import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/customer_model.dart';

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

  bool get addressIncomplete => customer.addressCount <= 0;

  Future<void> refreshCustomer() async {
    if (isRefreshing) return;
    isRefreshing = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await _httpRequest.getCustomer(token: token);
      if (response is! Map) {
        errorMessage = 'دریافت اطلاعات حساب کاربری انجام نشد.';
        return;
      }
      final model = CustomerResponseModel.fromJson(Map<String, dynamic>.from(response));
      if (!model.success) {
        errorMessage = model.message.isNotEmpty ? model.message : 'دریافت اطلاعات حساب کاربری انجام نشد.';
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

  void applyCustomer(CustomerModel value) {
    customer = value;
    onCustomerUpdated?.call(value);
    notifyListeners();
  }
}
