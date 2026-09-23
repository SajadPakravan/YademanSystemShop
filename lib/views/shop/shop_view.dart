import 'package:flutter/material.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';
import 'package:yad_sys/views/shop/filter/full_filter_dialog.dart';
import 'package:yad_sys/widgets/bottom_sheet/filter_sheet_widget.dart';
import 'package:yad_sys/widgets/buttons/btn_filters.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/buttons/filter_chip_button_widget.dart';
import 'package:yad_sys/widgets/product/product_vertical_card.dart';
import 'package:yad_sys/widgets/product/shop_product_card.dart';
import 'package:yad_sys/widgets/search.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ShopView extends StatefulWidget {
  const ShopView({super.key, required this.viewModel});

  final ShopViewModel viewModel;

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  final ScrollController _scrollController = ScrollController();

  ShopViewModel get vm => widget.viewModel;
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 650) vm.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: colors.surface,
              surfaceTintColor: AppColors.transparent,
              titleSpacing: r.space(10),
              collapsedHeight: r.space(80, min: 74, max: 88),
              title: const Search(),
              bottom: vm.productsLst.isNotEmpty
                  ? PreferredSize(preferredSize: Size.fromHeight(r.space(80, min: 74, max: 90)), child: filtersArea(context))
                  : null,
            ),
          ],
          body: RefreshIndicator(
            onRefresh: vm.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                if (vm.isInitialLoading && vm.productsLst.isEmpty)
                  const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))
                else if (vm.errorMessage != null && vm.productsLst.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(message: vm.errorMessage!, onRetry: vm.retry),
                  )
                else if (vm.productsLst.isEmpty)
                  const SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
                else ...[
                  SliverToBoxAdapter(child: productsListHeader(context)),
                  isGridView
                      ? SliverGrid.builder(
                          key: const ValueKey("grid"),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: r.space(5),
                            mainAxisSpacing: r.space(5),
                            childAspectRatio: 0.6,
                          ),
                          itemCount: vm.productsLst.length,
                          itemBuilder: (context, index) => ProductVerticalCard(product: vm.productsLst[index], length: vm.productsLst.length, index: index),
                        )
                      : SliverList(
                          key: const ValueKey("list"),
                          delegate: SliverChildBuilderDelegate(
                            childCount: vm.productsLst.length,
                            (context, index) => ShopProductCard(product: vm.productsLst[index]),
                          ),
                        ),
                  SliverToBoxAdapter(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: vm.isLoadingMore
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: r.space(24)),
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                            )
                          : SizedBox(height: r.space(24)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget filtersArea(BuildContext context) {
    if (vm.filters.categories.isEmpty) return const SizedBox.shrink();
    final state = vm.appliedFilters;
    final colors = context.appColors;
    final r = context.responsive;

    return Material(
      color: colors.surface,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.only(bottom: r.space(5)),
        child: Row(
          children: [
            BtnFilters(
              title: 'فیلتر',
              badgeCount: state.activeFilterGroupsCount,
              icon: Icons.tune_rounded,
              onTap: () {
                final dialog = AllFilter(viewModel: vm);
                dialog.show(context);
              },
            ),
            Expanded(
              child: Column(spacing: r.space(5), children: [primaryFilters(context), attributeFilters(context)]),
            ),
          ],
        ),
      ),
    );
  }

  Widget primaryFilters(BuildContext context) {
    final state = vm.appliedFilters;
    final r = context.responsive;

    return SizedBox(
      height: r.chipHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: r.space(10)),
        children: [
          FilterChipButtonWidget(
            title: vm.sortChipTitle(state),
            active: state.hasNonDefaultSort,
            icon: Icons.sort_rounded,
            onTap: () => sortSheet(context, vm),
          ),
          FilterChipButtonWidget(
            title: vm.categoryChipTitle(state),
            active: state.categoryIds.isNotEmpty,
            badgeCount: state.categoryIds.length > 1 ? state.categoryIds.length : 0,
            onTap: () => categorySheet(context, vm),
          ),
          FilterChipButtonWidget(
            title: vm.brandChipTitle(state),
            active: state.brandIds.isNotEmpty,
            badgeCount: state.brandIds.length > 1 ? state.brandIds.length : 0,
            onTap: () => brandSheet(context, vm),
          ),
          FilterChipButtonWidget(title: 'محدوده قیمت', active: state.hasPriceFilter, onTap: () => priceSheet(context, vm)),
        ],
      ),
    );
  }

  Widget attributeFilters(BuildContext context) {
    final state = vm.appliedFilters;
    final r = context.responsive;

    return SizedBox(
      height: r.chipHeight,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: r.space(10)),
        scrollDirection: Axis.horizontal,
        itemCount: vm.filters.attributes.length,
        separatorBuilder: (_, _) => SizedBox(width: r.space(7)),
        itemBuilder: (context, index) {
          final attribute = vm.filters.attributes[index];
          final count = state.selectedOptionsFor(attribute.id).length;
          return FilterChipButtonWidget(
            title: vm.attributeChipTitle(attribute, state),
            active: count > 0,
            badgeCount: count > 1 ? count : 0,
            compactMargin: true,
            onTap: () => attributeSheet(context, vm, attribute),
          );
        },
      ),
    );
  }

  Widget productsListHeader(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Container(
      color: colors.surface,
      padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(18), r.pageHorizontalPadding, r.space(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: r.space(10),
            children: [
              AppText.titleSmall('${AppFunction.faDigit(vm.productCount)} کالا', fontWeight: FontWeight.w700, color: colors.textPrimary),
              if (vm.isRefreshing)
                SizedBox(
                  width: r.space(20),
                  height: r.space(20),
                  child: const CircularProgressIndicator(strokeWidth: 2.5),
                ),
            ],
          ),
          IconButton(onPressed: () => setState(() => isGridView = !isGridView), icon: Icon(isGridView ? Icons.format_list_bulleted : Icons.grid_view)),
        ],
      ),
    );
  }
}

class PriceLabel extends StatelessWidget {
  const PriceLabel({super.key, required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.space(12), vertical: r.space(11)),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(r.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          AppText.bodySmall(label, color: colors.textMuted),
          const Spacer(),
          Flexible(
            child: AppText.bodySmall('${AppFunction.faPrice(value)} تومان', overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.pageHorizontalPadding * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: r.icon(52), color: colors.textMuted),
            SizedBox(height: r.space(14)),
            AppText.bodyMedium(message, textAlign: TextAlign.center, height: 1.6, color: colors.textSecondary),
            SizedBox(height: r.space(16)),
            SizedBox(
              width: r.percentWidth(0.45, min: 150, max: 220),
              child: AppButton(label: 'تلاش دوباره', onPressed: onRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.pageHorizontalPadding * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: r.icon(52), color: colors.textMuted),
            SizedBox(height: r.space(12)),
            const AppText.bodyMedium('محصولی با این فیلترها پیدا نشد.', fontWeight: FontWeight.w600),
            SizedBox(height: r.space(6)),
            AppText.bodySmall('فیلترها را تغییر دهید و دوباره بررسی کنید.', color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}

bool isColorAttribute(ProductAttributeFilterModel attribute) {
  final value = attribute.name.replaceAll('\u200c', '').replaceAll(' ', '').toLowerCase();
  return value.contains('رنگ') || value == 'color';
}
