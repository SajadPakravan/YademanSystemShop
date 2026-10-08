import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/cart_model.dart';
import 'package:yad_sys/models/product/product_detail_model.dart';
import 'package:yad_sys/screens/product/product_images_screen.dart';
import 'package:yad_sys/tools/app_cache.dart';
import 'package:yad_sys/tools/product_detail_cache.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';

class ProductViewModel with ChangeNotifier {
  ProductViewModel({required int id}) : _currentProductId = id;

  int _currentProductId;
  final List<int> _productHistory = <int>[];
  int _loadRequestSerial = 0;
  final HttpRequest _httpRequest = HttpRequest();
  final ProductDetailCache _cache = ProductDetailCache.instance;
  ProductDetailModel? _response;
  final Map<int, int> _selectedVariationOptionIds = <int, int>{};
  bool isLoading = true;
  String errorMessage = '';
  bool authError = false;
  bool personalInfoError = false;
  bool existCart = false;
  int quantity = 0;
  bool isFavorite = false;
  bool isAddingToCart = false;
  String _authToken = '';
  int slideIndex = 0;
  final TextEditingController reviewController = TextEditingController();
  int rating = 0;
  String _name = '';
  String _email = '';

  int get id => _currentProductId;

  int get currentProductId => _currentProductId;

  bool get hasProductHistory => _productHistory.isNotEmpty;

  ProductDetail? get product => _response?.data;

  String get authToken => _authToken;

  List<String> get galleryImages {
    final value = product;
    if (value == null) return const <String>[];

    final images = <String>[];

    void addImage(String? image) {
      final normalized = image?.trim() ?? '';
      if (normalized.isNotEmpty && !images.contains(normalized)) {
        images.add(normalized);
      }
    }

    for (final image in value.gallery) {
      addImage(image);
    }
    addImage(value.image);

    for (final variation in value.variations) {
      for (final option in variation.options) {
        addImage(option.productImage);
      }
    }

    return List<String>.unmodifiable(images);
  }

  Future<void> loadProduct({bool forceRefresh = false}) async {
    final targetId = _currentProductId;
    final requestSerial = ++_loadRequestSerial;
    errorMessage = '';

    if (!forceRefresh) {
      final cached = _cache.get(targetId);
      if (cached != null) {
        if (requestSerial != _loadRequestSerial || targetId != _currentProductId) return;

        _response = cached;
        _initializeProductUiState();
        isLoading = false;
        notifyListeners();

        await _refreshLocalState();
        if (requestSerial == _loadRequestSerial && targetId == _currentProductId) {
          notifyListeners();
        }
        return;
      }
    }

    isLoading = true;
    notifyListeners();

    try {
      final dynamic json = await _httpRequest.getProduct(id: targetId);
      final result = ProductDetailModel.fromJson(Map<String, dynamic>.from(json));

      if (!result.success) {
        throw const FormatException('جزئیتات محصول با موفقیت دریافت نشد');
      }

      if (requestSerial != _loadRequestSerial || targetId != _currentProductId) return;

      _response = result;
      _cache.save(result);
      _initializeProductUiState();
      await _refreshLocalState();
    } catch (e, stackTrace) {
      if (requestSerial != _loadRequestSerial || targetId != _currentProductId) return;

      debugPrint('PRODUCT DETAIL ERROR >>> $e');
      debugPrintStack(label: 'PRODUCT DETAIL STACK TRACE', stackTrace: stackTrace);
      errorMessage = 'دریافت جزئیات محصول انجام نشد. اتصال اینترنت را بررسی کنید.';
    } finally {
      if (requestSerial == _loadRequestSerial && targetId == _currentProductId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> openRelatedProduct(int productId) async {
    if (productId == _currentProductId) return;

    _productHistory.add(_currentProductId);
    await _switchProduct(productId);
  }

  Future<bool> handleBack() async {
    if (_productHistory.isEmpty) return true;

    final previousProductId = _productHistory.removeLast();
    await _switchProduct(previousProductId);
    return false;
  }

  Future<void> _switchProduct(int productId) async {
    _currentProductId = productId;
    _response = null;
    errorMessage = '';
    isLoading = true;
    slideIndex = 0;
    reviewController.clear();
    rating = 0;
    _selectedVariationOptionIds.clear();
    notifyListeners();

    await loadProduct();
  }

  void _initializeProductUiState() {
    final value = product;
    _selectedVariationOptionIds.clear();
    slideIndex = 0;

    if (value == null) return;

    for (final variation in value.variations) {
      if (variation.options.isEmpty) continue;

      ProductVariationOption? selected;

      final defaultVariationId = value.defaultVariation;
      if (defaultVariationId != null) {
        for (final option in variation.options) {
          if (option.id == defaultVariationId) {
            selected = option;
            break;
          }
        }
      }

      if (selected == null && value.variationName.trim().isNotEmpty) {
        final currentName = value.variationName.trim();
        for (final option in variation.options) {
          if (option.name.trim() == currentName) {
            selected = option;
            break;
          }
        }
      }

      selected ??= variation.options.first;
      _selectedVariationOptionIds[variation.id] = selected.id;
    }

    _syncSlideWithSelectedVariation();
  }

  ProductVariationOption? selectedOptionFor(ProductVariation variation) {
    final selectedId = _selectedVariationOptionIds[variation.id];
    if (selectedId == null) return null;

    for (final option in variation.options) {
      if (option.id == selectedId) return option;
    }
    return null;
  }

  bool isVariationOptionSelected(ProductVariation variation, ProductVariationOption option) {
    return _selectedVariationOptionIds[variation.id] == option.id;
  }

  void selectVariationOption(ProductVariation variation, ProductVariationOption option) {
    if (_selectedVariationOptionIds[variation.id] == option.id) return;

    _selectedVariationOptionIds[variation.id] = option.id;
    _syncSlideWithImage(option.productImage);
    notifyListeners();
  }

  void _syncSlideWithSelectedVariation() {
    final value = product;
    if (value == null) return;

    for (final variation in value.variations) {
      final selected = selectedOptionFor(variation);
      if (selected != null && selected.productImage.trim().isNotEmpty) {
        _syncSlideWithImage(selected.productImage);
        return;
      }
    }
  }

  void _syncSlideWithImage(String image) {
    final normalized = image.trim();
    if (normalized.isEmpty) return;

    final index = galleryImages.indexOf(normalized);
    if (index >= 0) {
      slideIndex = index;
    }
  }

  Future<void> _refreshLocalState() async {
    await _checkLogged();
    if (!authError) {
      await _refreshServerCartState();
    } else {
      existCart = false;
      quantity = 0;
    }
    _checkFavorites();
  }

  Future<void> _checkLogged() async {
    _authToken = await AppCache.getString('token');
    _name = await AppCache.getString('first_name');
    _email = await AppCache.getString('email');
    authError = _authToken.isEmpty;
    personalInfoError = _name.trim().isEmpty;
  }

  int? get selectedVariationId {
    final value = product;
    if (value == null || value.variations.isEmpty) return null;
    for (final variation in value.variations) {
      final selected = selectedOptionFor(variation);
      if (selected != null && selected.id > 0) return selected.id;
    }
    return value.defaultVariation;
  }

  Map<String, String> get selectedVariationValues {
    final value = product;
    if (value == null) return const <String, String>{};
    final result = <String, String>{};
    for (final variation in value.variations) {
      final selected = selectedOptionFor(variation);
      if (selected != null) result[variation.name] = selected.name;
    }
    return result;
  }

  Future<void> _refreshServerCartState() async {
    final value = product;
    existCart = false;
    quantity = 0;
    if (value == null || _authToken.isEmpty) return;

    try {
      final response = await _httpRequest.getCompleteCart(token: _authToken);
      if (response is! Map) return;
      final model = CartResponseModel.fromJson(Map<String, dynamic>.from(response));
      if (!model.success) return;

      final selectedVarId = selectedVariationId;
      for (final item in model.data) {
        final sameProduct = item.productId == value.id || item.id == value.id;
        if (!sameProduct) continue;
        if (selectedVarId != null && item.variationId > 0 && item.variationId != selectedVarId) continue;
        if (item.variationId == 0 && item.variation.isNotEmpty && selectedVariationValues.isNotEmpty &&
            !item.variation.values.every((option) => selectedVariationValues.values.contains(option))) continue;
        quantity += item.quantity;
      }
      existCart = quantity > 0;
    } catch (e) {
      debugPrint('PRODUCT CART STATE ERROR >>> $e');
    }
  }

  void _checkFavorites() {
    final value = product;
    isFavorite = false;

    // if (value == null || authError || _favoritesBox.isEmpty) return;
    //
    // for (final favorite in _favoritesBox.values) {
    //   if (favorite.id == value.id) {
    //     isFavorite = true;
    //     return;
    //   }
    // }
  }

  void onSlideChange(int index) {
    slideIndex = index;
    notifyListeners();
  }

  Future<void> onTapProductImage(int imageIndex) async {
    final images = galleryImages;
    if (images.isEmpty) return;

    await Get.to(
      const ProductImagesScreen(),
      transition: Transition.size,
      duration: const Duration(milliseconds: 350),
      arguments: <String, dynamic>{'imageIndex': imageIndex, 'images': images},
    );
  }

  Future<void> addCart(BuildContext context) async {
    final value = product;
    if (value == null || isAddingToCart) return;

    await _checkLogged();
    if (authError) {
      SnackBarView.show(context, 'برای افزودن محصول به سبد خرید لطفا وارد حساب کاربری شوید');
      return;
    }

    if (value.stockQuantity <= 0 || value.price <= 0) {
      SnackBarView.show(context, 'این محصول در حال حاضر قابل افزودن به سبد خرید نیست');
      return;
    }

    isAddingToCart = true;
    notifyListeners();
    try {
      final response = await _httpRequest.addCartItem(
        token: _authToken,
        productId: value.id,
        quantity: 1,
        variationId: selectedVariationId,
        variation: selectedVariationValues,
      );

      if (response is Map && response['success'] == true) {
        await _refreshServerCartState();
        if (context.mounted) SnackBarView.show(context, 'محصول به سبد خرید اضافه شد');
      } else {
        final message = response is Map && response['message']?.toString().trim().isNotEmpty == true
            ? response['message'].toString().trim()
            : 'افزودن محصول به سبد خرید انجام نشد';
        if (context.mounted) SnackBarView.show(context, message);
      }
    } catch (e) {
      debugPrint('ADD CART ERROR >>> $e');
      if (context.mounted) SnackBarView.show(context, 'افزودن محصول به سبد خرید انجام نشد');
    } finally {
      isAddingToCart = false;
      notifyListeners();
    }
  }

  Future<void> refreshCartState() async {
    await _checkLogged();
    if (!authError) await _refreshServerCartState();
    notifyListeners();
  }

  Future<void> addRemoveFavorite(BuildContext context) async {
    final value = product;
    if (value == null) return;

    if (authError) {
      SnackBarView.show(context, 'برای افزودن محصول به لیست علاقه‌مندی‌ها لطفا وارد حساب کاربری شوید');
      return;
    }

    // if (isFavorite) {
    //   FavoriteModel? target;
    //   for (final favorite in _favoritesBox.values) {
    //     if (favorite.id == value.id) {
    //       target = favorite;
    //       break;
    //     }
    //   }
    //   if (target != null) await target.delete();
    // } else {
    //   await _favoritesBox.add(
    //     FavoriteModel(
    //       id: value.id,
    //       name: value.name,
    //       image: value.image,
    //       price: value.price,
    //       regularPrice: value.regularPrice,
    //       onSale: value.discountPercent > 0,
    //     ),
    //   );
    // }

    _checkFavorites();
    notifyListeners();
  }

  void onRatingUpdate(double value) {
    rating = value.toInt();
    notifyListeners();
  }

  Future<void> createReview(BuildContext context) async {
    final value = product;
    if (value == null) return;

    if (authError) {
      SnackBarView.show(context, 'برای ثبت دیدگاه خود لطفا وارد حساب کاربری شوید و مشخصات فردی را تکمیل کنید');
      return;
    }

    if (personalInfoError) {
      SnackBarView.show(context, 'برای ثبت دیدگاه خود لطفا مشخصات فردی را تکمیل کنید');
      return;
    }

    if (reviewController.text.trim().isEmpty || rating == 0) {
      SnackBarView.show(context, 'لطفا دیدگاه و امتیاز خود را وارد کنید');
      return;
    }
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
}
