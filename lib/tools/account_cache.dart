import 'package:yad_sys/models/auth/auth_model.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/app_cache.dart';

class AccountCache {
  AccountCache._();

  static Future<CustomerModel> getCustomer() async {
    return CustomerModel(
      id: await AppCache.getInt('id'),
      username: await AppCache.getString('username'),
      displayName: await AppCache.getString('display_name'),
      avatar: await AppCache.getString('avatar'),
      firstName: await AppCache.getString('first_name'),
      lastName: await AppCache.getString('last_name'),
      phone: await AppCache.getString('phone'),
      addressCount: await AppCache.getInt('address_count'),
      ordersCount: await AppCache.getInt('orders_count'),
      cartCount: await AppCache.getInt('cart_count'),
      commentsCount: await AppCache.getInt('comments_count'),
    );
  }

  static Future<void> refreshCounts({required CustomerModel customer}) async {
    customer.addressCount = await AppCache.getInt('address_count');
    customer.ordersCount = await AppCache.getInt('orders_count');
    customer.cartCount = await AppCache.getInt('cart_count');
    customer.commentsCount = await AppCache.getInt('comments_count');
  }

  static Future<void> save({AuthModel? auth, CustomerModel? customer}) async {
    final user = auth?.user ?? customer;
    if (user == null) return;

    if (auth != null) await AppCache.setString('token', auth.token);

    await AppCache.setInt('id', user.id);
    await AppCache.setString('username', user.username);
    await AppCache.setString('display_name', user.displayName);
    await AppCache.setString('avatar', user.avatar);
    await AppCache.setString('first_name', user.firstName);
    await AppCache.setString('last_name', user.lastName);
    await AppCache.setString('phone', user.phone);
    await AppCache.setInt('address_count', user.addressCount);
    await AppCache.setInt('orders_count', user.ordersCount);
    await AppCache.setInt('cart_count', user.cartCount);
    await AppCache.setInt('comments_count', user.commentsCount);
  }

  static Future<void> clear() async {
    for (final key in <String>[
      'token',
      'id',
      'username',
      'display_name',
      'avatar',
      'first_name',
      'last_name',
      'phone',
      'address_count',
      'orders_count',
      'cart_count',
      'comments_count',
      'favorites_count',
      'viewed_products_count',
    ]) {
      await AppCache.remove(key);
    }
  }
}
