import 'package:yad_sys/models/product/product_item_model.dart';
import 'package:yad_sys/models/viewed_products_model.dart';
import 'package:yad_sys/view_models/account/profile/account_list_view_model.dart';

/// مدل فهرست با دریافت تازه داده در هر بار ورود و بدون کش لیست.
class ViewedProductsViewModel extends AccountListViewModel<ProductItemModel> {
  ViewedProductsViewModel({required super.token, super.httpRequest});
  List<ProductItemModel> get productsLst => items;
  @override
  String get loadErrorMessage => 'دریافت محصولات مشاهده‌شده انجام نشد.';
  @override
  Future<dynamic> request({int page = 1}) => httpRequest.getViewedProducts(token: token, page: page, perPage: perPage);
  @override
  AccountListLoadResult<ProductItemModel> parse(Map<String, dynamic> json) {
    final model = ViewedProductsModel.fromJson(json);
    return AccountListLoadResult(success: model.success, count: model.count, items: model.data, pagination: model.pagination);
  }
}
