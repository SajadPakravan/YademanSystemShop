import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/screens/account/profile/addresses/addresses_screen.dart';
import 'package:yad_sys/screens/account/profile/cart/cart_screen.dart';
import 'package:yad_sys/screens/account/profile/favorites/favorites_screen.dart';
import 'package:yad_sys/screens/account/profile/orders/orders_screen.dart';
import 'package:yad_sys/screens/account/profile/password/change_password_screen.dart';
import 'package:yad_sys/screens/account/profile/personal_info/personal_info_screen.dart';
import 'package:yad_sys/screens/account/profile/reviews/reviews_screen.dart';
import 'package:yad_sys/screens/account/profile/viewed_products/viewed_products_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/view_models/account/profile_view_model.dart';
import 'package:yad_sys/widgets/account/profile_menu_card.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ProfileMenuGrid extends StatelessWidget {
  const ProfileMenuGrid({super.key, required this.customer, required this.viewModel, required this.logout});

  final ProfileViewModel viewModel;
  final CustomerModel customer;
  final Future<void> Function() logout;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final spacing = r.space(10, min: 8, max: 14);
    final available = r.width - (r.pageHorizontalPadding * 2) - (spacing * 2);
    final cardSize = (available / 3).clamp(94.0, r.isTablet ? 170.0 : 132.0).toDouble();

    final items = [
      ProfileMenuCard(
        title: 'مشخصات فردی',
        icon: Icons.person_outline_rounded,
        showAlertDot: customer.personalInfoIncomplete,
        onTap: () => _openPersonalInfo(context, PersonalInfoScreen(customer: customer, token: viewModel.token)),
      ),
      ProfileMenuCard(
        title: 'آدرس‌ها',
        icon: Icons.location_on_outlined,
        showAlertDot: customer.addressCount <= 0,
        onTap: () => _openList(context, AddressesScreen(token: viewModel.token)),
      ),
      ProfileMenuCard(
        title: 'سفارشات',
        icon: Icons.receipt_long_outlined,
        badgeCount: customer.ordersCount,
        onTap: () => _openList(context, OrdersScreen(token: viewModel.token)),
      ),
      ProfileMenuCard(
        title: 'سبد خرید',
        icon: Icons.shopping_cart_outlined,
        badgeCount: customer.cartCount,
        onTap: () => _openList(context, CartScreen(token: viewModel.token)),
      ),
      ProfileMenuCard(
        title: 'علاقه‌مندی‌ها',
        icon: Icons.favorite_border_rounded,
        onTap: () => _openList(context, FavoritesScreen(token: viewModel.token)),
      ),
      ProfileMenuCard(
        title: 'نظرات من',
        icon: Icons.rate_review_outlined,
        badgeCount: customer.commentsCount,
        onTap: () => _openList(context, ReviewsScreen(token: viewModel.token)),
      ),
      ProfileMenuCard(
        title: 'محصولات مشاهده‌شده',
        icon: Icons.history_rounded,
        onTap: () => _openList(context, ViewedProductsScreen(token: viewModel.token)),
      ),
      ProfileMenuCard(title: 'اعلانات', icon: Icons.notifications_none_rounded, showAlertDot: customer.personalInfoIncomplete, onTap: () {}),
      ProfileMenuCard(
        title: 'تغییر گذرواژه',
        icon: Icons.lock_outline_rounded,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
      ),
      ProfileMenuCard(title: 'خروج از حساب', icon: Icons.logout_rounded, onTap: () => _confirmLogout(context)),
    ];

    final rows = <Widget>[];
    for (var start = 0; start < items.length; start += 3) {
      final end = (start + 3).clamp(0, items.length).toInt();
      final rowItems = items.sublist(start, end);
      rows.add(
        Row(
          spacing: r.space(10),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < rowItems.length; index++) ...[SizedBox(width: cardSize, height: cardSize, child: rowItems[index])],
          ],
        ),
      );
    }

    return Column(spacing: r.space(10), children: rows);
  }

  Future<void> _openList(BuildContext context, Widget screen) async {
    await rightToPage(() => screen);
    viewModel.getCustomer();
  }

  Future<void> _openPersonalInfo(BuildContext context, Widget screen) async {
    final updated = await rightToPage(() => screen);
    if (updated is CustomerModel) viewModel.applyCustomer(updated);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const AppText.titleMedium('خروج از حساب', fontWeight: FontWeight.w800),
          content: const AppText.bodyMedium('آیا می‌خواهید از حساب کاربری خارج شوید؟'),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.onBrand),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: AppText.bodyMedium('خروج', color: Colors.white),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: AppText.bodyMedium('انصراف', color: context.appColors.inquiryForeground),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) await logout();
  }
}
