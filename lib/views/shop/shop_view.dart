import 'package:flutter/material.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';
import 'package:yad_sys/views/shop/filter/full_filter_dialog_view.dart';
import 'package:yad_sys/widgets/bottom_sheet/filter_sheet_widget.dart';
import 'package:yad_sys/widgets/buttons/all_filters_chip_button_widget.dart';
import 'package:yad_sys/widgets/buttons/filter_chip_button_widget.dart';
import 'package:yad_sys/widgets/product/product_horizontal_card_widget2.dart';
import 'package:yad_sys/widgets/search.dart';

class ShopView extends StatefulWidget {
  const ShopView({super.key, required this.viewModel});

  final ShopViewModel viewModel;

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  final ScrollController _scrollController = ScrollController();

  ShopViewModel get vm => widget.viewModel;

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
    if (_scrollController.position.extentAfter < 650) {
      vm.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              titleSpacing: 10,
              collapsedHeight: 80,
              title: const Search(),
              bottom: PreferredSize(preferredSize: const Size.fromHeight(80), child: _buildFiltersArea(context)),
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
                  SliverToBoxAdapter(child: _buildResultHeader()),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = vm.productsLst[index];
                      return ShopProductCard(product: product);
                    }, childCount: vm.productsLst.length),
                  ),
                  SliverToBoxAdapter(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: vm.isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                            )
                          : const SizedBox(height: 24),
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

  Widget _buildFiltersArea(BuildContext context) {
    if (vm.filters.categories.isEmpty) return SizedBox.shrink();
    final state = vm.appliedFilters;
    return Material(
      color: Colors.white,
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            AllFiltersChipButtonWidget(
              title: 'فیلتر',
              badgeCount: state.activeFilterGroupsCount,
              icon: Icons.tune_rounded,
              onTap: () => _openFullFilter(context),
            ),
            Expanded(child: Column(spacing: 5, children: [_buildPrimaryFilters(context), _buildAttributeFilters(context)])),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryFilters(BuildContext context) {
    final state = vm.appliedFilters;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeFilters(BuildContext context) {
    final state = vm.appliedFilters;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: vm.filters.attributes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
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

  Widget _buildResultHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Row(
        children: [
          Text(
            '${AppFunction.faDigit(vm.productCount)} کالا',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff202020)),
          ),
          if (vm.isRefreshing) ...[const SizedBox(width: 10), const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))],
        ],
      ),
    );
  }

  Future<void> _openFullFilter(BuildContext context) async {
    vm.beginPreview();
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'فیلترها',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 330),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FullFilterDialog(viewModel: vm);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
    vm.cancelPreview();
  }
}

class PriceLabel extends StatelessWidget {
  const PriceLabel({super.key, required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xfffafafa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe7e7e7)),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.black45, fontSize: 12)),
          const Spacer(),
          Flexible(
            child: Text(
              '${AppFunction.faPrice(value)} تومان',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 52, color: Colors.black26),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('تلاش دوباره')),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 52, color: Colors.black26),
            SizedBox(height: 12),
            Text('محصولی با این فیلترها پیدا نشد.', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('فیلترها را تغییر دهید و دوباره بررسی کنید.', style: TextStyle(color: Colors.black45)),
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
