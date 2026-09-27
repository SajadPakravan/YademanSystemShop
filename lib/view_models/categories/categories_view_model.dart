import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/category/categories_model.dart';
import 'package:yad_sys/models/section_model.dart';

class CategoriesViewModel with ChangeNotifier {
  final HttpRequest httpRequest = HttpRequest();
  List<SectionModel> sections = const <SectionModel>[];

  bool isLoading = false;
  bool isRefreshing = false;
  String errorMessage = '';
  bool hasLoadedOnce = false;

  Future<void> load({bool refresh = false}) async {
    if (isLoading || isRefreshing) return;
    if (!refresh && hasLoadedOnce) return;

    if (refresh) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }

    errorMessage = '';
    notifyListeners();

    try {
      final dynamic json = await httpRequest.getCategories();
      if (json is! Map) throw const FormatException('پاسخ API دسته‌بندی‌ها معتبر نیست');

      final response = CategoriesModel.fromJson(Map<String, dynamic>.from(json));
      if (!response.success) throw const FormatException('API دسته‌بندی پاسخ ناموفق برگرداند');

      sections = List<SectionModel>.unmodifiable(response.sections);
      hasLoadedOnce = true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('CATEGORY API ERROR >>>> $e');
        debugPrint('$stackTrace');
      }
      errorMessage = 'دریافت اطلاعات صفحه دسته‌بندی‌ها انجام نشد. اتصال اینترنت را بررسی کنید.';
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }
}
