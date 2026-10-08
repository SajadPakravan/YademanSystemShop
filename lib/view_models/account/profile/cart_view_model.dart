import 'package:flutter/foundation.dart';
import 'package:yad_sys/models/cart_model.dart';
import 'package:yad_sys/view_models/account/profile/account_list_view_model.dart';

/// مدل فهرست با دریافت تازه داده در هر بار ورود و بدون کش لیست.
class CartViewModel extends AccountListViewModel<CartItemModel> {
  CartViewModel({required super.token, super.httpRequest});

  final Set<String> _busyItems = <String>{};
  String mutationError = '';

  @override
  String get loadErrorMessage => 'دریافت سبد خرید انجام نشد.';

  @override
  Future<dynamic> request({int page = 1}) => httpRequest.getCart(token: token, page: page, perPage: perPage);

  /// برای نمایش تمام سبد/تب‌های سفارش‌ها، همه صفحه‌ها دریافت می‌شوند.
  @override
  bool get loadAllPages => true;

  @override
  AccountListLoadResult<CartItemModel> parse(Map<String, dynamic> json) {
    final model = CartResponseModel.fromJson(json);
    return AccountListLoadResult(success: model.success, count: model.count, items: model.data, pagination: model.pagination);
  }

  String _identity(CartItemModel item) => '${item.key}|${item.productId}|${item.variation.entries.map((e) => '${e.key}:${e.value}').join(',')}';
  bool isBusy(CartItemModel item) => _busyItems.contains(_identity(item));
  int get totalPrice => items.fold<int>(0, (sum, item) => sum + item.lineTotal);
  int get totalQuantity => items.fold<int>(0, (sum, item) => sum + item.quantity);

  Future<bool> increase(CartItemModel item) => _setQuantity(item, item.quantity + 1);

  Future<bool> decrease(CartItemModel item) async {
    if (item.quantity <= 1) return false;
    return _setQuantity(item, item.quantity - 1);
  }

  Future<bool> _setQuantity(CartItemModel item, int quantity) async {
    if (isBusy(item) || quantity < 1) return false;
    final identity = _identity(item);
    _busyItems.add(identity);
    mutationError = '';
    notifyListeners();

    try {
      final response = await httpRequest.updateCartItem(
        token: token,
        productId: item.productId,
        quantity: quantity,
        cartItemKey: item.key,
        variation: item.variation,
      );
      if (response is! Map || response['success'] != true) {
        mutationError = response is Map && response['message']?.toString().trim().isNotEmpty == true
            ? response['message'].toString().trim()
            : 'تغییر تعداد محصول در سبد خرید انجام نشد.';
        return false;
      }

      final index = items.indexWhere((value) => _identity(value) == identity);
      if (index >= 0) items[index] = items[index].copyWith(quantity: quantity);
      count = items.length;
      return true;
    } catch (e) {
      if (kDebugMode) print('CART UPDATE ERROR >>> $e');
      mutationError = 'تغییر تعداد محصول انجام نشد. اتصال اینترنت را بررسی کنید.';
      return false;
    } finally {
      _busyItems.remove(identity);
      notifyListeners();
    }
  }

  Future<bool> remove(CartItemModel item) async {
    if (isBusy(item)) return false;
    final identity = _identity(item);
    _busyItems.add(identity);
    mutationError = '';
    notifyListeners();

    try {
      final response = await httpRequest.deleteCartItem(
        token: token,
        productId: item.productId,
        cartItemKey: item.key,
        variation: item.variation,
      );
      if (response is! Map || response['success'] != true) {
        mutationError = response is Map && response['message']?.toString().trim().isNotEmpty == true
            ? response['message'].toString().trim()
            : 'حذف محصول از سبد خرید انجام نشد.';
        return false;
      }

      items.removeWhere((value) => _identity(value) == identity);
      count = items.length;
      return true;
    } catch (e) {
      if (kDebugMode) print('CART DELETE ERROR >>> $e');
      mutationError = 'حذف محصول انجام نشد. اتصال اینترنت را بررسی کنید.';
      return false;
    } finally {
      _busyItems.remove(identity);
      notifyListeners();
    }
  }
}
