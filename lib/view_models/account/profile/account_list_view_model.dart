import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';

class AccountListLoadResult<T> {
  const AccountListLoadResult({required this.success, required this.count, required this.items});
  final bool success;
  final int count;
  final List<T> items;
}

abstract class AccountListViewModel<T> extends ChangeNotifier {
  AccountListViewModel({required this.token, HttpRequest? httpRequest}) : httpRequest = httpRequest ?? HttpRequest();

  final String token;
  final HttpRequest httpRequest;

  List<T> items = <T>[];
  int count = 0;
  bool isLoading = false;
  bool isRefreshing = false;
  String errorMessage = '';

  String get loadErrorMessage;
  Future<dynamic> request();
  AccountListLoadResult<T> parse(Map<String, dynamic> json);

  /// Return true when this page restored a previously loaded session result.
  bool restoreSessionCache() => false;

  /// Called after every successful server load and after local mutations.
  void writeSessionCache() {}

  Future<void> load({bool refresh = false}) async {
    if (isLoading || isRefreshing) return;

    if (!refresh && restoreSessionCache()) {
      errorMessage = '';
      notifyListeners();
      return;
    }

    if (items.isEmpty && !refresh) {
      isLoading = true;
    } else {
      isRefreshing = true;
    }
    errorMessage = '';
    notifyListeners();

    try {
      final response = await request();
      if (response is! Map) {
        errorMessage = loadErrorMessage;
        return;
      }

      final result = parse(Map<String, dynamic>.from(response));
      if (!result.success) {
        errorMessage = response['message']?.toString().trim().isNotEmpty == true
            ? response['message'].toString().trim()
            : loadErrorMessage;
        return;
      }

      count = result.count;
      items = result.items;
      writeSessionCache();
    } catch (e) {
      if (kDebugMode) print('${runtimeType.toString().toUpperCase()} ERROR >>>> $e');
      errorMessage = '$loadErrorMessage اتصال اینترنت را بررسی کنید.';
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(refresh: true);
}
