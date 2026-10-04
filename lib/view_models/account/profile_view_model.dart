import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/models/order/order_model.dart';
import 'package:yad_sys/tools/app_cache.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required this.customerId,
    required this.token,
    HttpRequest? httpRequest,
  }) : _httpRequest = httpRequest ?? HttpRequest();

  final int customerId;
  final String token;
  final HttpRequest _httpRequest;

  CustomerModel? customer;
  bool isLoading = false;
  bool isRefreshing = false;
  String errorMessage = '';
  int activeOrdersCount = 0;
  bool _disposed = false;

  Future<void> loadCustomer({bool forceRefresh = false}) async {
    if (isLoading || isRefreshing) return;

    if (customer == null) {
      isLoading = true;
    } else {
      isRefreshing = true;
    }
    errorMessage = '';
    notifyListeners();

    try {
      final response = await _httpRequest.getCustomer(token: token);
      if (response is! Map) {
        errorMessage = 'دریافت اطلاعات حساب کاربری انجام نشد.';
        return;
      }

      final map = Map<String, dynamic>.from(response);
      if (map['success'] != true || map['data'] is! Map) {
        errorMessage = map['message']?.toString().trim().isNotEmpty == true
            ? map['message'].toString().trim()
            : 'دریافت اطلاعات حساب کاربری انجام نشد.';
        return;
      }

      final model = CustomerResponseModel.fromJson(map);
      customer = model.data;
      await _cacheCustomerHeader(customer!);
      unawaited(_loadActiveOrdersCount());
    } catch (e) {
      if (kDebugMode) print('CUSTOMER ERROR >>>> $e');
      errorMessage = 'دریافت اطلاعات حساب کاربری انجام نشد. اتصال اینترنت را بررسی کنید.';
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> refreshCustomer() => loadCustomer(forceRefresh: true);


  Future<void> _loadActiveOrdersCount() async {
    try {
      final response = await _httpRequest.getOrders(token: token);
      if (response is! Map) return;

      final model = OrdersResponseModel.fromJson(Map<String, dynamic>.from(response));
      if (!model.success) return;

      activeOrdersCount = model.data.where((order) => order.isOpen).length;
      if (!_disposed) notifyListeners();
    } catch (e) {
      if (kDebugMode) print('PROFILE ORDERS COUNT ERROR >>>> $e');
    }
  }


  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _cacheCustomerHeader(CustomerModel value) async {
    await AppCache.setString('customer_first_name', value.firstName);
    await AppCache.setString('customer_last_name', value.lastName);
    await AppCache.setString('customer_display_name', value.displayName);
    await AppCache.setString('customer_avatar', value.avatar);
    await AppCache.setString('customer_phone', value.phone);
  }
}
