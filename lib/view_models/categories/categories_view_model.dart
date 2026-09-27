import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/categories_model.dart';
import 'package:yad_sys/models/section_model.dart';

class CategoriesViewModel with ChangeNotifier {
  final HttpRequest _httpRequest = HttpRequest();
  List<SectionModel> _sections = const <SectionModel>[];

  bool _isLoading = false;
  bool _isRefreshing = false;
  String _errorMessage = '';
  bool _hasLoadedOnce = false;

  List<SectionModel> get sections => _sections;

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  String get errorMessage => _errorMessage;

  bool get hasError => _errorMessage.isNotEmpty;

  bool get hasLoadedOnce => _hasLoadedOnce;

  Future<void> load({bool refresh = false}) async {
    if (_isLoading || _isRefreshing) return;
    if (!refresh && _hasLoadedOnce) return;

    if (refresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }

    _errorMessage = '';
    notifyListeners();

    try {
      final dynamic json = await _httpRequest.getCategories();
      if (json is! Map) {
        throw const FormatException('پاسخ API خانه معتبر نیست');
      }

      final response = CategoriesModel.fromJson(Map<String, dynamic>.from(json));
      if (!response.success) {
        throw const FormatException('API خانه پاسخ ناموفق برگرداند');
      }

      _sections = List<SectionModel>.unmodifiable(response.sections);
      _hasLoadedOnce = true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('CATEGORY API ERROR >>>> $e');
        debugPrint('$stackTrace');
      }
      _errorMessage = 'دریافت اطلاعات صفحه خانه انجام نشد. اتصال اینترنت یا API را بررسی کنید.';
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }
}
