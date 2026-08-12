import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/products_local_store.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';

class SearchViewModel with ChangeNotifier {
  SearchViewModel({ProductsLocalStore? localStore}) : _localStore = localStore ?? ProductsLocalStore.instance;

  final ProductsLocalStore _localStore;
  static final List<String> _sessionRecentSearches = <String>[];

  Timer? _debounce;
  String query = '';
  bool isApplying = false;
  List<ProductCategoryFilterModel> categories = const <ProductCategoryFilterModel>[];
  List<ProductBrandFilterModel> brands = const <ProductBrandFilterModel>[];
  List<ProductsListItemModel> products = const <ProductsListItemModel>[];

  List<String> get recentSearches => List<String>.unmodifiable(_sessionRecentSearches);
  bool get canSearch => query.trim().length >= 3;
  bool get hasLocalResults => categories.isNotEmpty || brands.isNotEmpty || products.isNotEmpty;

  void onQueryChanged(String value) {
    query = value;
    _debounce?.cancel();

    if (value.trim().length < 3) {
      categories = const <ProductCategoryFilterModel>[];
      brands = const <ProductBrandFilterModel>[];
      products = const <ProductsListItemModel>[];
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 120), () {
      final normalized = query.trim();
      categories = _localStore.searchCategories(normalized, limit: 6);
      brands = _localStore.searchBrands(normalized, limit: 6);
      products = _localStore.searchProducts(normalized, limit: 12);
      notifyListeners();
    });
  }

  void useRecent(String value) {
    query = value;
    categories = _localStore.searchCategories(value, limit: 6);
    brands = _localStore.searchBrands(value, limit: 6);
    products = _localStore.searchProducts(value, limit: 12);
    notifyListeners();
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
