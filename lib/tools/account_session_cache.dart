import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/models/cart_model.dart';
import 'package:yad_sys/models/order/order_model.dart';
import 'package:yad_sys/models/product/product_item_model.dart';
import 'package:yad_sys/models/review_item_model.dart';

/// Session-only cache for account APIs.
///
/// This cache intentionally lives only in memory. It survives navigation between
/// account pages but is cleared on logout (and naturally disappears when the
/// app process is killed). Each page owns its own API request and writes the
/// fresh result here after a successful load/mutation.
class AccountSessionCache {
  AccountSessionCache._();

  static AddressBookModel? addresses;
  static bool addressesLoaded = false;

  static List<CartItemModel>? cart;
  static int cartCount = 0;

  static List<OrderModel>? orders;
  static int ordersCount = 0;

  static List<ProductItemModel>? favorites;
  static int favoritesCount = 0;

  static List<ProductItemModel>? viewedProducts;
  static int viewedProductsCount = 0;

  static List<ReviewItemModel>? reviews;
  static int reviewsCount = 0;

  static void clear() {
    addresses = null;
    addressesLoaded = false;
    cart = null;
    cartCount = 0;
    orders = null;
    ordersCount = 0;
    favorites = null;
    favoritesCount = 0;
    viewedProducts = null;
    viewedProductsCount = 0;
    reviews = null;
    reviewsCount = 0;
  }
}
