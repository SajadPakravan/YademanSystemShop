import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';

class SearchViewModel with ChangeNotifier {
  final HttpRequest _httpRequest = HttpRequest();
  static final List<String> _sessionRecentSearches = <String>[];

  Timer? _debounce;
  int _requestSerial = 0;
  String query = '';
  bool isSearching = false;
  bool isApplying = false;
  List<ProductCategoryFilterModel> categories = const <ProductCategoryFilterModel>[];
  List<ProductBrandFilterModel> brands = const <ProductBrandFilterModel>[];
  List<ProductCardModel> products = const <ProductCardModel>[];

  List<String> get recentSearches => List<String>.unmodifiable(_sessionRecentSearches);

  bool get canSearch => query.trim().length >= 3;

  bool get hasResults => categories.isNotEmpty || brands.isNotEmpty || products.isNotEmpty;

  void onQueryChanged(String value) {
    query = value;
    _debounce?.cancel();

    if (!canSearch) {
      _requestSerial++;
      isSearching = false;
      categories = const <ProductCategoryFilterModel>[];
      brands = const <ProductBrandFilterModel>[];
      products = const <ProductCardModel>[];
      notifyListeners();
      return;
    }

    final serial = ++_requestSerial;
    isSearching = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _loadSuggestions(query.trim(), serial);
    });
  }

  Future<void> _loadSuggestions(String value, int serial) async {
    try {
      final json = await _httpRequest.getProducts(search: value, perPage: 12);
      if (serial != _requestSerial || json is! Map) return;

      final response = ProductsListModel.fromJson(Map<String, dynamic>.from(json));
      if (!response.success) return;

      final categoryIds = response.data.expand((item) => item.categories.map((category) => category.id)).toSet();
      final brandId = response.data.map((item) => item.brand.id).toSet();
      final normalized = value.toLowerCase();

      categories = response.filters.flatCategories
          .where((item) => categoryIds.contains(item.id) || item.name.toLowerCase().contains(normalized))
          .take(6)
          .toList(growable: false);
      brands = response.filters.brands
          .where((item) => brandId.contains(item.id) || item.name.toLowerCase().contains(normalized))
          .take(6)
          .toList(growable: false);
      products = response.data.take(12).toList(growable: false);
    } catch (e) {
      if (kDebugMode) debugPrint('SEARCH SUGGESTION ERROR >>>> $e');
    } finally {
      if (serial == _requestSerial) {
        isSearching = false;
        notifyListeners();
      }
    }
  }

  void useRecent(String value) {
    query = value;
    onQueryChanged(value);
  }

  void clearRecentSearches() {
    _sessionRecentSearches.clear();
    notifyListeners();
  }

  Future<bool> submitSearch(ShopViewModel shopViewModel) async {
    final value = query.trim();
    if (value.length < 3 || isApplying) return false;

    isApplying = true;
    notifyListeners();
    try {
      final success = await shopViewModel.applySearch(value);
      if (success) _remember(value);
      return success;
    } finally {
      isApplying = false;
      notifyListeners();
    }
  }

  Future<bool> selectCategory(ProductCategoryFilterModel category, ShopViewModel shopViewModel) async {
    if (isApplying) return false;
    isApplying = true;
    notifyListeners();
    try {
      return await shopViewModel.applyCategoryFromSearch(category.id);
    } finally {
      isApplying = false;
      notifyListeners();
    }
  }

  Future<bool> selectBrand(ProductBrandFilterModel brand, ShopViewModel shopViewModel) async {
    if (isApplying) return false;
    isApplying = true;
    notifyListeners();
    try {
      return await shopViewModel.applyBrandFromSearch(brand.id);
    } finally {
      isApplying = false;
      notifyListeners();
    }
  }

  void _remember(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return;
    _sessionRecentSearches.remove(normalized);
    _sessionRecentSearches.insert(0, normalized);
    if (_sessionRecentSearches.length > 8) {
      _sessionRecentSearches.removeRange(8, _sessionRecentSearches.length);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
