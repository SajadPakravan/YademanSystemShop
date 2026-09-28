import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/category/category_detail_model.dart';
import 'package:yad_sys/tools/category_detail_cache.dart';

class CategoryViewModel with ChangeNotifier {
  CategoryViewModel({required int id}) : _currentCategoryId = id;

  final HttpRequest _httpRequest = HttpRequest();
  final CategoryDetailCache _cache = CategoryDetailCache.instance;
  int _currentCategoryId;
  final List<int> _categoryHistory = <int>[];
  CategoryDetailModel? _response;
  int _loadRequestSerial = 0;
  bool isLoading = true;
  String errorMessage = '';

  int get id => _currentCategoryId;

  int get currentCategoryId => _currentCategoryId;

  bool get hasCategoryHistory => _categoryHistory.isNotEmpty;

  CategoryDetailData? get category => _response?.data;

  Future<void> load({bool forceRefresh = false}) async {
    final targetId = _currentCategoryId;
    final requestSerial = ++_loadRequestSerial;
    errorMessage = '';

    if (!forceRefresh) {
      final cached = _cache.get(targetId);
      if (cached != null) {
        if (requestSerial != _loadRequestSerial || targetId != _currentCategoryId) return;

        _response = cached;
        isLoading = false;
        notifyListeners();
        return;
      }
    }

    isLoading = true;
    notifyListeners();

    try {
      final dynamic json = await _httpRequest.getCategory(id: targetId);
      if (json is! Map) throw const FormatException('پاسخ API جزئیات دسته‌بندی معتبر نیست');

      final result = CategoryDetailModel.fromJson(Map<String, dynamic>.from(json));
      if (!result.success || result.data.id == 0) throw const FormatException('جزئیات دسته‌بندی با موفقیت دریافت نشد');

      if (requestSerial != _loadRequestSerial || targetId != _currentCategoryId) return;

      _response = result;
      _cache.save(result);
    } catch (e, stackTrace) {
      if (requestSerial != _loadRequestSerial || targetId != _currentCategoryId) return;

      if (kDebugMode) {
        debugPrint('CATEGORY DETAIL ERROR >>> $e');
        debugPrintStack(label: 'CATEGORY DETAIL STACK TRACE', stackTrace: stackTrace);
      }
      errorMessage = 'دریافت جزئیات دسته‌بندی انجام نشد. اتصال اینترنت را بررسی کنید.';
    } finally {
      if (requestSerial == _loadRequestSerial && targetId == _currentCategoryId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> openChildCategory(int categoryId) async {
    if (categoryId == _currentCategoryId) return;

    _categoryHistory.add(_currentCategoryId);
    await _switchCategory(categoryId);
  }

  Future<bool> handleBack() async {
    if (_categoryHistory.isEmpty) return true;

    final previousCategoryId = _categoryHistory.removeLast();
    await _switchCategory(previousCategoryId);
    return false;
  }

  Future<void> _switchCategory(int categoryId) async {
    _currentCategoryId = categoryId;
    _response = null;
    errorMessage = '';
    isLoading = true;
    notifyListeners();

    await load();
  }
}
