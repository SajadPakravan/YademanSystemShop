import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/product/products_list_model.dart';

/// نتیجه پردازش هر صفحه همراه با مدل صفحه‌بندی پاسخ همان API.
class AccountListLoadResult<T> {
  /// دریافت داده‌های صفحه و صفحه‌بندی بدون نگهداری کش فهرست.
  const AccountListLoadResult({required this.success, required this.count, required this.items, required this.pagination});
  final bool success;
  final int count;
  final List<T> items;
  final ProductsPaginationModel pagination;
}

/// منطق مشترک دریافت صفحه‌های تازه فهرست‌های حساب کاربری.
abstract class AccountListViewModel<T> extends ChangeNotifier {
  /// تزریق درخواست HTTP برای امکان تست هر فهرست.
  AccountListViewModel({required this.token, HttpRequest? httpRequest}) : httpRequest = httpRequest ?? HttpRequest();
  final String token;
  final HttpRequest httpRequest;
  List<T> items = <T>[];
  int count = 0;
  int perPage = 20;
  ProductsPaginationModel pagination = ProductsPaginationModel.empty();
  bool isLoading = false, isRefreshing = false, isLoadingMore = false;
  bool _disposed = false;
  String errorMessage = '';

  /// متن خطای مخصوص API فرزند.
  String get loadErrorMessage;
  /// برای سفارش‌ها و سبد خرید تمام صفحه‌ها جمع می‌شوند تا محاسبات کامل باشند.
  bool get loadAllPages => false;
  /// دریافت صفحه مشخص از سرور در هر بار ورود.
  Future<dynamic> request({int page = 1});
  /// تبدیل JSON هر فهرست به مدل اختصاصی آن.
  AccountListLoadResult<T> parse(Map<String, dynamic> json);

  /// دریافت تازه از صفحه اول؛ فهرست قبلی فقط پس از دریافت موفق جایگزین می‌شود.
  Future<void> load({bool refresh = false}) async {
    if (isLoading || isRefreshing || isLoadingMore || _disposed) return;
    isLoading = items.isEmpty;
    isRefreshing = !isLoading;
    errorMessage = '';
    notifyListeners();
    try {
      final loaded = <T>[];
      var page = 1;
      late ProductsPaginationModel next;
      do {
        final response = await request(page: page);
        if (_disposed) return;
        final result = parse(_checked(response));
        if (!result.success) throw StateError(loadErrorMessage);
        loaded.addAll(result.items);
        next = result.pagination;
        if (next.currentPage != page || (next.hasNext && result.items.isEmpty)) {
          throw StateError('پاسخ صفحه‌بندی سرور معتبر نیست.');
        }
        page = next.currentPage + 1;
      } while (loadAllPages && next.hasNext);
      items = loaded;
      pagination = next;
      count = next.totalItems;
    } catch (e) {
      errorMessage = e is StateError ? e.message.toString() : loadErrorMessage;
    } finally {
      isLoading = isRefreshing = false;
      notifyListeners();
    }
  }

  /// بارگذاری صفحه بعد فقط با استفاده از has_next پاسخ سرور.
  Future<void> loadMore() async {
    if (_disposed || isLoading || isRefreshing || isLoadingMore || !pagination.hasNext) return;
    isLoadingMore = true;
    errorMessage = '';
    notifyListeners();
    try {
      final page = pagination.currentPage + 1;
      final result = parse(_checked(await request(page: page)));
      if (_disposed) return;
      final next = result.pagination;
      if (!result.success || next.currentPage != page || (next.hasNext && result.items.isEmpty)) throw StateError(loadErrorMessage);
      items.addAll(result.items);
      pagination = next;
      count = next.totalItems;
    } catch (e) {
      errorMessage = e is StateError ? e.message.toString() : loadErrorMessage;
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  /// اعتبارسنجی نوع پاسخ و پیام خطای API.
  Map<String, dynamic> _checked(dynamic response) {
    if (response is! Map) throw StateError(loadErrorMessage);
    if (response['success'] != true) throw StateError(response['message']?.toString() ?? loadErrorMessage);
    return Map<String, dynamic>.from(response);
  }

  /// دریافت مجدد داده بدون خواندن کش.
  Future<void> refresh() => load(refresh: true);

  /// جلوگیری از فراخوانی notifyListeners پس از خروج از صفحه.
  @override
  void notifyListeners() { if (!_disposed) super.notifyListeners(); }

  /// علامت‌گذاری پایان عمر مدل هنگام بسته شدن صفحه.
  @override
  void dispose() { _disposed = true; super.dispose(); }
}
