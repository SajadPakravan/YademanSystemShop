import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/screens/profile/address/address_screen.dart';
import 'package:yad_sys/screens/profile/cart/cart_screen.dart';
import 'package:yad_sys/screens/profile/change_password/change_password_screen.dart';
import 'package:yad_sys/screens/profile/favorites/favorites_screen.dart';
import 'package:yad_sys/screens/profile/orders/order_screen.dart';
import 'package:yad_sys/screens/profile/personal_info/personal_info_screen.dart';
import 'package:yad_sys/screens/web_screen.dart';
import 'package:yad_sys/tools/app_cache.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/text_views/text_body_large_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_small_view.dart';

class LoggedView extends StatelessWidget {
  LoggedView({
    super.key,
    required this.context,
    required this.customer,
    required this.getCustomer,
    required this.signOut,
    required this.personalInfoAlert,
    required this.addressAlert,
    required this.cartAlert,
    required this.cartNumber,
    required this.checkCart,
  });

  final BuildContext context;
  final AppCache cache = AppCache();
  final CustomerModel customer;
  final Function() getCustomer;
  final void Function() signOut;
  final void Function() checkCart;
  final bool personalInfoAlert;
  final bool addressAlert;
  final bool cartAlert;
  final int cartNumber;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: r.space(18)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: r.icon(74, min: 62, max: 88),
                  backgroundImage: NetworkImage(customer.avatarUrl!),
                ),
                SizedBox(height: r.space(10)),
                TextBodyLargeView('${customer.firstname} ${customer.lastname}'),
                SizedBox(height: r.space(8)),
                TextBodyMediumView(customer.email!),
                SizedBox(height: r.space(18)),
                _option(
                  context,
                  title: 'مشخصات فردی',
                  icon: Icons.person,
                  subtitle: personalInfoAlert ? const TextBodySmallView('لطفا مشخصات فردی خود را تکمیل کنید', color: AppColors.error) : null,
                  onTap: () async {
                    await rightToPage(const PersonalInfoScreen(), arguments: customer);
                    if (await cache.getBool('profileChanged')) getCustomer();
                  },
                ),
                _option(
                  context,
                  title: 'تغییر رمز عبور',
                  icon: Icons.lock,
                  onTap: () async {
                    await rightToPage(const ChangePasswordScreen(), arguments: customer);
                    if (await cache.getBool('profileChanged')) signOut();
                  },
                ),
                _option(
                  context,
                  title: 'آدرس‌',
                  icon: Icons.location_on,
                  subtitle: addressAlert ? const TextBodySmallView('لطفا آدرس خود را وارد کنید', color: AppColors.error) : null,
                  onTap: () => rightToPage(const AddressScreen(), arguments: customer),
                ),
                _option(
                  context,
                  title: 'سبد خرید',
                  icon: Icons.shopping_cart,
                  subtitle: cartAlert
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: r.icon(25),
                            height: r.icon(25),
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: r.space(5)),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                            child: TextBodyMediumView(
                              cartNumber.toString().toPersianDigit(),
                              color: AppColors.onBrand,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                  onTap: () async {
                    await rightToPage(const CartScreen());
                    checkCart();
                  },
                ),
                _option(context, title: 'سفارشات', icon: Icons.shopping_bag, onTap: () => rightToPage(const OrderScreen())),
                _option(context, title: 'علاقه‌مندی‌ها', icon: Icons.favorite, onTap: () => rightToPage(const FavoritesScreen())),
                _option(
                  context,
                  title: 'تماس با پشتیبانی',
                  icon: Icons.headphones,
                  onTap: () => rightToPage(const WebScreen(title: 'تماس با پشتیبانی', url: 'https://yademansystem.ir/contact-us')),
                ),
                _option(context, title: 'خروج از حساب کاربری', icon: Icons.logout, onTap: signOut),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? subtitle,
    required void Function() onTap,
  }) {
    final colors = context.appColors;
    final r = context.responsive;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding, vertical: r.space(7)),
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r.radius(12)),
        side: BorderSide(color: colors.border),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: r.space(14), vertical: r.space(3)),
        title: TextBodyMediumView(title, fontWeight: FontWeight.w600),
        leading: Icon(icon, color: AppColors.primary),
        trailing: Icon(Icons.arrow_forward_ios, size: r.icon(17), color: colors.textMuted),
        subtitle: subtitle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius(12))),
        onTap: onTap,
      ),
    );
  }
}
