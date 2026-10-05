import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/cart_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/view_models/account/profile/cart_view_model.dart';
import 'package:yad_sys/widgets/account/account_empty_state.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/net_image.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class CartView extends StatelessWidget {
  const CartView({super.key, required this.viewModel});

  final CartViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AppBarView(title: 'سبد خرید'),
      body: _body(context, r),
      bottomNavigationBar: viewModel.items.isEmpty ? null : _summary(context),
    );
  }

  Widget _body(BuildContext context, AppDimension r) {
    if (viewModel.isLoading && viewModel.items.isEmpty) return const Loading();

    if (viewModel.errorMessage.isNotEmpty && viewModel.items.isEmpty) {
      return _error(context, viewModel.errorMessage, viewModel.load);
    }

    if (viewModel.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: AccountEmptyState(
                icon: Icons.shopping_cart_outlined,
                title: 'سبد خرید خالی است',
                message: 'هنوز محصولی به سبد خرید اضافه نکرده‌اید.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(12), r.pageHorizontalPadding, r.space(24)),
        itemCount: viewModel.items.length,
        separatorBuilder: (_, _) => SizedBox(height: r.space(10)),
        itemBuilder: (context, index) => _CartItemCard(item: viewModel.items[index], viewModel: viewModel),
      ),
    );
  }

  Widget _summary(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(10), r.pageHorizontalPadding, r.space(10)),
        decoration: BoxDecoration(color: colors.surface, border: Border(top: BorderSide(color: colors.divider))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodySmall('${viewModel.totalQuantity.toString().toPersianDigit()} کالا', color: colors.textSecondary),
                  SizedBox(height: r.space(3)),
                  AppText.titleSmall('${viewModel.totalPrice.toString().seRagham().toPersianDigit()} تومان', fontWeight: FontWeight.w800),
                ],
              ),
            ),
            if (viewModel.mutationError.isNotEmpty)
              Flexible(child: AppText.bodySmall(viewModel.mutationError, color: AppColors.error, textAlign: TextAlign.end)),
          ],
        ),
      ),
    );
  }

  Widget _error(BuildContext context, String message, Future<void> Function({bool refresh}) retry) {
    final r = context.responsive;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.pageHorizontalPadding * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, color: context.appColors.textMuted, size: r.icon(62)),
            SizedBox(height: r.space(14)),
            AppText.bodyMedium(message, textAlign: TextAlign.center, color: context.appColors.textSecondary),
            SizedBox(height: r.space(14)),
            AppButton(label: 'تلاش دوباره', expand: false, icon: Icons.refresh_rounded, onPressed: () => retry(refresh: true)),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item, required this.viewModel});

  final CartItemModel item;
  final CartViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
    final busy = viewModel.isBusy(item);
    final imageSize = r.percentWidth(0.24, min: 88, max: 118);

    return Container(
      padding: EdgeInsets.all(r.space(10)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(r.radius(14)),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(r.radius(12)),
            child: NetImage(imageUrl: item.image, width: imageSize, height: imageSize),
          ),
          SizedBox(width: r.space(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText.bodyMedium(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w700),
                if (item.variationText.isNotEmpty) ...[
                  SizedBox(height: r.space(5)),
                  AppText.bodySmall(item.variationText, color: colors.textSecondary, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                SizedBox(height: r.space(10)),
                AppText.bodyMedium('${item.lineTotal.toString().seRagham().toPersianDigit()} تومان', fontWeight: FontWeight.w800),
                SizedBox(height: r.space(10)),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.add_rounded,
                      enabled: !busy,
                      onTap: () => viewModel.increase(item),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: r.space(10)),
                      child: busy
                          ? SizedBox(width: r.icon(18), height: r.icon(18), child: const CircularProgressIndicator(strokeWidth: 2))
                          : AppText.bodyMedium(item.quantity.toString().toPersianDigit(), fontWeight: FontWeight.w800),
                    ),
                    _QuantityButton(
                      icon: Icons.remove_rounded,
                      enabled: !busy && item.quantity > 1,
                      onTap: () => viewModel.decrease(item),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'حذف از سبد خرید',
                      onPressed: busy ? null : () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText.titleSmall('حذف محصول', fontWeight: FontWeight.w800),
        content: const AppText.bodyMedium('این محصول از سبد خرید حذف شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) await viewModel.remove(item);
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Material(
      color: context.appColors.surfaceVariant,
      borderRadius: BorderRadius.circular(r.radius(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(r.radius(10)),
        onTap: enabled ? onTap : null,
        child: SizedBox(width: r.icon(34), height: r.icon(34), child: Icon(icon, size: r.icon(18))),
      ),
    );
  }
}
