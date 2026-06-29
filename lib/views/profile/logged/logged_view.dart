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
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/tools/app_cache.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 150 / 2, backgroundImage: NetworkImage(customer.avatarUrl!)),
                const SizedBox(height: 10),
                TextBodyLargeView('${customer.firstname} ${customer.lastname}'),
                const SizedBox(height: 10),
                TextBodyMediumView(customer.email!),
                const SizedBox(height: 20),
                option(
                  title: 'مشخصات فردی',
                  icon: Icons.person,
                  subtitle: personalInfoAlert ? const TextBodySmallView('لطفا مشخصات فردی خود را تکمیل کنید', color: Colors.red) : null,
                  onTap: () async {
                    await rightToPage(const PersonalInfoScreen(), arguments: customer);
                    if (await cache.getBool('profileChanged')) getCustomer();
                  },
                ),
                option(
                  title: 'تغییر رمز عبور',
                  icon: Icons.lock,
                  onTap: () async {
                    await rightToPage(const ChangePasswordScreen(), arguments: customer);
                    if (await cache.getBool('profileChanged')) signOut();
                  },
                ),
                option(
                  title: 'آدرس‌',
                  icon: Icons.location_on,
                  subtitle: addressAlert ? const TextBodySmallView('لطفا آدرس خود را وارد کنید', color: Colors.red) : null,
                  onTap: () => rightToPage(const AddressScreen(), arguments: customer),
                ),
                option(
                  title: 'سبد خرید',
                  icon: Icons.shopping_cart,
                  subtitle: cartAlert
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 25,
                            height: 25,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: ColorStyle.blueFav),
                            child: TextBodyMediumView(
                              cartNumber.toString().toPersianDigit(),
                              color: Colors.white,
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
                option(title: 'سفارشات', icon: Icons.shopping_bag, onTap: () => rightToPage(const OrderScreen())),
                option(title: 'علاقه‌مندی‌ها', icon: Icons.favorite, onTap: () => rightToPage(const FavoritesScreen())),
                option(
                  title: 'تماس با پشتیبانی',
                  icon: Icons.headphones,
                  onTap: () => rightToPage(const WebScreen(title: 'تماس با پشتیبانی', url: 'https://yademansystem.ir/contact-us')),
                ),
                option(title: 'خروج از حساب کاربری', icon: Icons.logout, onTap: signOut),
              ],
            ),
          ),
        ),
      ),
    );
  }

  option({required String title, required IconData icon, Widget? subtitle, required void Function() onTap}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 10),
      elevation: 0,
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: TextBodyMediumView(title),
        leading: Icon(icon),
        trailing: const Icon(Icons.arrow_forward_ios),
        subtitle: subtitle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        onTap: onTap,
      ),
    );
  }
}
