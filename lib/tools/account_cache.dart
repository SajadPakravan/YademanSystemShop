import 'package:yad_sys/models/auth/auth_model.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/app_cache.dart';

/// کش پایدار کم‌حجم حساب؛ هیچ‌یک از فیلدهای شخصی یا لیست‌ها ذخیره نمی‌شوند.
class AccountCache {
  AccountCache._();

  /// بازیابی فقط شناسه، نام کاربری، نام نمایشی و شمارنده‌های منو.
  static Future<CustomerModel> getCustomer() async {
    // پاکسازی مهاجرت از نسخه قدیمی به محض باز شدن اپلیکیشن.
    for (final key in _legacyPersonalKeys) { await AppCache.remove(key); }
    return CustomerModel(
    id: await AppCache.getInt('id'),
    username: await AppCache.getString('username'),
    displayName: await AppCache.getString('display_name'),
    addressCount: await AppCache.getInt('address_count'),
    ordersCount: await AppCache.getInt('orders_count'),
    cartCount: await AppCache.getInt('cart_count'),
    commentsCount: await AppCache.getInt('comments_count'),
    favoritesCount: await AppCache.getInt('favorites_count'),
    viewedProductsCount: await AppCache.getInt('viewed_products_count'),
    );
  }

  /// ذخیره فیلدهای مجاز و پاکسازی نسخه‌های قدیمی کش شامل اطلاعات شخصی.
  static Future<void> save({AuthModel? auth, CustomerModel? customer}) async {
    final user = auth?.user ?? customer;
    if (user == null) return;
    if (auth != null) await AppCache.setString('token', auth.token);
    await AppCache.setInt('id', user.id);
    await AppCache.setString('username', user.username);
    await AppCache.setString('display_name', user.displayName);
    await AppCache.setInt('address_count', user.addressCount);
    await AppCache.setInt('orders_count', user.ordersCount);
    await AppCache.setInt('cart_count', user.cartCount);
    await AppCache.setInt('comments_count', user.commentsCount);
    await AppCache.setInt('favorites_count', user.favoritesCount);
    await AppCache.setInt('viewed_products_count', user.viewedProductsCount);
    for (final key in _legacyPersonalKeys) { await AppCache.remove(key); }
  }

  /// فیلدهای شخصی ذخیره‌شده در نسخه‌های قبل باید یک بار حذف شوند.
  static const List<String> _legacyPersonalKeys = <String>[
    'first_name', 'last_name', 'phone', 'email', 'avatar', 'date_created',
  ];

  /// حذف همه داده‌های حساب فعلی هنگام خروج.
  static Future<void> clear() async {
    for (final key in <String>[
      'token', 'id', 'username', 'display_name', 'address_count', 'orders_count',
      'cart_count', 'comments_count', 'favorites_count', 'viewed_products_count',
      ..._legacyPersonalKeys,
    ]) { await AppCache.remove(key); }
  }
}
