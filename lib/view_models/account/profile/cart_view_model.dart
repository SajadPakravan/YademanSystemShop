import 'package:yad_sys/models/cart_model.dart';
import 'package:yad_sys/view_models/account/profile/account_list_view_model.dart';

class CartViewModel extends AccountListViewModel<CartItemModel> {
  CartViewModel({required super.token, super.httpRequest});

  @override
  String get loadErrorMessage => 'دریافت سبد خرید انجام نشد.';

  @override
  Future<dynamic> request() => httpRequest.getCart(token: token);

  @override
  AccountListLoadResult<CartItemModel> parse(Map<String, dynamic> json) {
    final model = CartResponseModel.fromJson(json);
    return AccountListLoadResult(success: model.success, count: model.count, items: model.data);
  }
}
