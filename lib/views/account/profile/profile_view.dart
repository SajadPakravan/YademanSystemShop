import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/screens/account/profile/addresses/addresses_screen.dart';
import 'package:yad_sys/screens/account/profile/cart/cart_screen.dart';
import 'package:yad_sys/screens/account/profile/favorites/favorites_screen.dart';
import 'package:yad_sys/screens/account/profile/orders/orders_screen.dart';
import 'package:yad_sys/screens/account/profile/password/change_password_screen.dart';
import 'package:yad_sys/screens/account/profile/personal_info/personal_info_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/view_models/account/profile_view_model.dart';
import 'package:yad_sys/widgets/account/profile_menu_card.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/net_image.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.viewModel, required this.logout});

  final ProfileViewModel viewModel;
  final Future<void> Function() logout;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    if (viewModel.isLoading && viewModel.customer == null) {
      return Scaffold(backgroundColor: colors.background, body: const Loading());
    }

    if (viewModel.customer == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(r.pageHorizontalPadding * 1.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_outlined, color: colors.textMuted, size: r.icon(68)),
                  SizedBox(height: r.space(14)),
                  AppText.bodyMedium(
                    viewModel.errorMessage.isEmpty ? 'دریافت اطلاعات حساب کاربری انجام نشد.' : viewModel.errorMessage,
                    textAlign: TextAlign.center,
                    color: colors.textSecondary,
                    height: 1.7,
                  ),
                  SizedBox(height: r.space(18)),
                  AppButton(label: 'تلاش دوباره', icon: Icons.refresh_rounded, expand: false, onPressed: () => viewModel.loadCustomer()),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final customer = viewModel.customer!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.refreshCustomer,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(18), r.pageHorizontalPadding, r.space(28)),
            children: [
              _profileHeader(context, customer),
              SizedBox(height: r.space(24)),
              if (viewModel.isRefreshing) ...[const LinearProgressIndicator(minHeight: 2), SizedBox(height: r.space(14))],
              _menuGrid(context, customer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader(BuildContext context, CustomerModel customer) {
    final colors = context.appColors;
    final r = context.responsive;
    final avatarSize = r.icon(94, min: 82, max: 116);

    return Container(
      padding: EdgeInsets.all(r.space(16)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(r.radius(18)),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          ClipOval(
            child: customer.avatar.isNotEmpty
                ? NetImage(imageUrl: customer.avatar, width: avatarSize, height: avatarSize)
                : Container(
                    width: avatarSize,
                    height: avatarSize,
                    color: colors.surfaceVariant,
                    child: Icon(Icons.person_rounded, color: colors.textMuted, size: r.icon(48)),
                  ),
          ),
          SizedBox(width: r.space(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.titleMedium(customer.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w800),
                SizedBox(height: r.space(5)),
                AppText.bodyMedium(
                  '@${customer.username}',
                  color: colors.textSecondary,
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (customer.email.isNotEmpty) ...[
                  SizedBox(height: r.space(4)),
                  AppText.bodySmall(customer.email, color: colors.textMuted, textDirection: TextDirection.ltr, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuGrid(BuildContext context, CustomerModel customer) {
    final r = context.responsive;
    final spacing = r.space(10, min: 8, max: 14);
    final available = r.width - (r.pageHorizontalPadding * 2) - (spacing * 2);
    final cardSize = (available / 3).clamp(94.0, r.isTablet ? 170.0 : 132.0).toDouble();

    final items = <Widget>[
      ProfileMenuCard(
        title: 'مشخصات فردی',
        icon: Icons.person_outline_rounded,
        showAlertDot: customer.personalInfoIncomplete,
        onTap: () => _openEditable(context, PersonalInfoScreen(customer: customer)),
      ),
      ProfileMenuCard(
        title: 'آدرس‌ها',
        icon: Icons.location_on_outlined,
        showAlertDot: customer.addressIncomplete,
        onTap: () => _openEditable(context, AddressesScreen(customer: customer)),
      ),
      ProfileMenuCard(
        title: 'علاقه‌مندی‌ها',
        icon: Icons.favorite_border_rounded,
        badgeCount: customer.wishlistCount,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FavoritesScreen(items: customer.wishlist))),
      ),
      ProfileMenuCard(
        title: 'سبد خرید',
        icon: Icons.shopping_cart_outlined,
        badgeCount: customer.cartCount,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CartScreen(items: customer.cart))),
      ),
      ProfileMenuCard(
        title: 'سفارشات',
        icon: Icons.receipt_long_outlined,
        badgeCount: customer.incompleteOrdersCount,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrdersScreen(orders: customer.orders))),
      ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < rowItems.length; index++) ...[
              if (index > 0) SizedBox(width: spacing),
              SizedBox(width: cardSize, height: cardSize, child: rowItems[index]),
            ],
          ],
        ),
      );
      if (end < items.length) rows.add(SizedBox(height: spacing));
    }

    return Column(children: rows);
  }

  Future<void> _openEditable(BuildContext context, Widget screen) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => screen));
    if (changed == true) await viewModel.refreshCustomer();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText.titleMedium('خروج از حساب', fontWeight: FontWeight.w800),
        content: const AppText.bodyMedium('آیا می‌خواهید از حساب کاربری خارج شوید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.onBrand),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (confirmed == true) await logout();
  }
}
