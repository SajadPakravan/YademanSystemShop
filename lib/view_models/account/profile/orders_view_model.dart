import 'package:yad_sys/models/order/order_model.dart';
import 'package:yad_sys/view_models/account/profile/account_list_view_model.dart';

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
}
