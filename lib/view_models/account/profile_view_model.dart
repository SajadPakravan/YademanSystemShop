import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/account_cache.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required this.token, HttpRequest? httpRequest, required this.customer}) : _httpRequest = httpRequest ?? HttpRequest();

  final HttpRequest _httpRequest;
  final String token;
  CustomerModel? customer;
  bool isRefreshing = false;
  String errorMessage = '';
  bool _disposed = false;

  bool get addressIncomplete => customer!.addressCount <= 0;

  Future<void> initialize() async {
    final currentCustomer = customer;
    final personalInfoMissingFromOldCache =
        currentCustomer != null && currentCustomer.firstName.isEmpty && currentCustomer.lastName.isEmpty && currentCustomer.phone.isEmpty;

    if (currentCustomer == null || personalInfoMissingFromOldCache) {
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

        await applyCustomer(model.data);
      } catch (e) {
        if (kDebugMode) print('CUSTOMER REFRESH ERROR >>>> $e');
        errorMessage = 'دریافت اطلاعات حساب کاربری انجام نشد. اتصال اینترنت را بررسی کنید.';
      } finally {
        notifyListeners();
      }
    }
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

      await applyCustomer(model.data);
    } catch (e) {
      if (kDebugMode) print('CUSTOMER REFRESH ERROR >>>> $e');
      errorMessage = 'دریافت اطلاعات حساب کاربری انجام نشد. اتصال اینترنت را بررسی کنید.';
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> applyCustomer(CustomerModel customer) async {
    await AccountCache.save(customer: customer);
    if (_disposed) return;

    this.customer = customer;
    notifyListeners();
  }

  Future<void> getCustomer() async {
    final currentCustomer = customer;

    if (currentCustomer == null) {
      customer = await AccountCache.getCustomer();
    } else {
      await AccountCache.refreshCounts(customer: currentCustomer);
    }

    if (!_disposed) notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
