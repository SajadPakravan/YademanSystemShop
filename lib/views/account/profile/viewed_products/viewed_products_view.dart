import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/view_models/account/profile/viewed_products_view_model.dart';
import 'package:yad_sys/widgets/account/account_empty_state.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/product/shop_product_row_card.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ViewedProductsView extends StatelessWidget {
  const ViewedProductsView({super.key, required this.viewModel});

  final ViewedProductsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AppBarView(title: 'محصولات مشاهده‌شده'),
      body: _body(context, r),
    );
  }

  Widget _body(BuildContext context, AppDimension r) {
    if (viewModel.isLoading && viewModel.items.isEmpty) return const Loading();
    if (viewModel.errorMessage.isNotEmpty && viewModel.items.isEmpty) return _error(context);

    if (viewModel.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: AccountEmptyState(
                icon: Icons.history_rounded,
                title: 'محصول مشاهده‌شده‌ای وجود ندارد',
                message: 'محصولاتی که مشاهده می‌کنید در این بخش نمایش داده می‌شوند.',
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
        padding: EdgeInsets.symmetric(vertical: r.space(8)),
        itemCount: viewModel.items.length,
        separatorBuilder: (_, _) => SizedBox(height: r.space(4)),
        itemBuilder: (context, index) => ShopProductRowCard(product: viewModel.items[index]),
      ),
    );
  }

  Widget _error(BuildContext context) {
    final r = context.responsive;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.pageHorizontalPadding * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, color: context.appColors.textMuted, size: r.icon(62)),
            SizedBox(height: r.space(14)),
            AppText.bodyMedium(viewModel.errorMessage, textAlign: TextAlign.center, color: context.appColors.textSecondary),
            SizedBox(height: r.space(14)),
            AppButton(label: 'تلاش دوباره', expand: false, icon: Icons.refresh_rounded, onPressed: () => viewModel.load(refresh: true)),
          ],
        ),
      ),
    );
  }
}
