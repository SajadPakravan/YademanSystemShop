import 'package:yad_sys/models/product/product_item_model.dart';
import 'package:yad_sys/models/favorites_model.dart';
import 'package:yad_sys/view_models/account/profile/account_list_view_model.dart';

/// مدل فهرست با دریافت تازه داده در هر بار ورود و بدون کش لیست.
class FavoritesViewModel extends AccountListViewModel<ProductItemModel> {
  FavoritesViewModel({required super.token, super.httpRequest});

  @override
  String get loadErrorMessage => 'دریافت علاقه‌مندی‌ها انجام نشد.';

  @override
  Future<dynamic> request({int page = 1}) => httpRequest.getFavorites(token: token, page: page, perPage: perPage);

  @override
  AccountListLoadResult<ProductItemModel> parse(Map<String, dynamic> json) {
    final model = FavoritesModel.fromJson(json);
    return AccountListLoadResult(success: model.success, count: model.count, items: model.data, pagination: model.pagination);
  }

}
