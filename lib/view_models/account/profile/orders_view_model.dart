import 'package:yad_sys/models/order/order_model.dart';
import 'package:yad_sys/view_models/account/profile/account_list_view_model.dart';

/// مدل فهرست با دریافت تازه داده در هر بار ورود و بدون کش لیست.
class OrdersViewModel extends AccountListViewModel<OrderModel> {
  OrdersViewModel({required super.token, super.httpRequest});

  @override
  String get loadErrorMessage => 'دریافت سفارشات انجام نشد.';

  @override
  Future<dynamic> request({int page = 1}) => httpRequest.getOrders(token: token, page: page, perPage: perPage);

  /// برای نمایش تمام سبد/تب‌های سفارش‌ها، همه صفحه‌ها دریافت می‌شوند.
  @override
  bool get loadAllPages => true;

  @override
  AccountListLoadResult<OrderModel> parse(Map<String, dynamic> json) {
    final model = OrdersResponseModel.fromJson(json);
    return AccountListLoadResult(success: model.success, count: model.count, items: model.data, pagination: model.pagination);
  }

}
