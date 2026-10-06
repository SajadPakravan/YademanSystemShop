import 'package:yad_sys/models/product/product_item_model.dart';
import 'package:yad_sys/models/product/product_items_response_model.dart';
import 'package:yad_sys/view_models/account/profile/account_list_view_model.dart';
import 'package:yad_sys/tools/account_session_cache.dart';

class FavoritesViewModel extends AccountListViewModel<ProductItemModel> {
  FavoritesViewModel({required super.token, super.httpRequest});

  @override
  String get loadErrorMessage => 'دریافت علاقه‌مندی‌ها انجام نشد.';

  @override
  Future<dynamic> request() => httpRequest.getFavorites(token: token);

  @override
  AccountListLoadResult<ProductItemModel> parse(Map<String, dynamic> json) {
    final model = ProductItemsResponseModel.fromJson(json);
    return AccountListLoadResult(success: model.success, count: model.count, items: model.data);
  }

  @override
  bool restoreSessionCache() {
    final cached = AccountSessionCache.favorites;
    if (cached == null) return false;
    items = List<ProductItemModel>.from(cached);
    count = AccountSessionCache.favoritesCount;
    return true;
  }

  @override
  void writeSessionCache() {
    AccountSessionCache.favorites = List<ProductItemModel>.unmodifiable(items);
    AccountSessionCache.favoritesCount = count;
  }
}
