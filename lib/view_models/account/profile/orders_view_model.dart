import 'package:yad_sys/models/order/order_model.dart';
import 'package:yad_sys/view_models/account/profile/account_list_view_model.dart';
import 'package:yad_sys/tools/account_session_cache.dart';

class OrdersViewModel extends AccountListViewModel<OrderModel> {
  OrdersViewModel({required super.token, super.httpRequest});

  @override
  String get loadErrorMessage => 'دریافت سفارشات انجام نشد.';

  @override
  Future<dynamic> request() => httpRequest.getOrders(token: token);

  @override
  AccountListLoadResult<OrderModel> parse(Map<String, dynamic> json) {
    final model = OrdersResponseModel.fromJson(json);
    return AccountListLoadResult(success: model.success, count: model.count, items: model.data);
  }

  @override
  bool restoreSessionCache() {
    final cached = AccountSessionCache.orders;
    if (cached == null) return false;
    items = List<OrderModel>.from(cached);
    count = AccountSessionCache.ordersCount;
    return true;
  }

  @override
  void writeSessionCache() {
    AccountSessionCache.orders = List<OrderModel>.unmodifiable(items);
    AccountSessionCache.ordersCount = count;
  }
}
