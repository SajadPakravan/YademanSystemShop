import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/screens/main_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/view_models/search/search_view_model.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _SearchHeader(
                controller: _controller,
                focusNode: _focusNode,
                loading: vm.isApplying,
                onChanged: vm.onQueryChanged,
                onSubmit: () => _submitSearch(context, vm),
                onBack: () => Navigator.maybePop(context),
                onClear: () {
                  _controller.clear();
                  vm.onQueryChanged('');
                  _focusNode.requestFocus();
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: vm.canSearch
                      ? _SearchResults(
                          key: ValueKey<String>('results-${vm.query}'),
                          viewModel: vm,
                          onCategory: (item) => _selectCategory(context, vm, item),
                          onBrand: (item) => _selectBrand(context, vm, item),
                        )
                      : _SearchIdle(
                          key: const ValueKey<String>('idle'),
                          recentSearches: vm.recentSearches,
                          onClearRecent: vm.clearRecentSearches,
                          onRecentTap: (value) {
                            _controller.value = TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length));
                            vm.useRecent(value);
                            _focusNode.requestFocus();
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitSearch(BuildContext context, SearchViewModel vm) async {
    FocusScope.of(context).unfocus();
    final success = await vm.submitSearch(context.read<ShopViewModel>());
    if (!mounted || !success) return;
    Get.offAll(() => const MainScreen(pageIndex: 1), transition: Transition.fade, duration: const Duration(milliseconds: 300));
  }

  Future<void> _selectCategory(BuildContext context, SearchViewModel vm, ProductCategoryFilterModel item) async {
    FocusScope.of(context).unfocus();
    final success = await vm.selectCategory(item, context.read<ShopViewModel>());
    if (!mounted || !success) return;
    Get.offAll(() => const MainScreen(pageIndex: 1), transition: Transition.fade, duration: const Duration(milliseconds: 300));
  }

  Future<void> _selectBrand(BuildContext context, SearchViewModel vm, ProductBrandFilterModel item) async {
    FocusScope.of(context).unfocus();
    final success = await vm.selectBrand(item, context.read<ShopViewModel>());
    if (!mounted || !success) return;
    Get.offAll(() => const MainScreen(pageIndex: 1), transition: Transition.fade, duration: const Duration(milliseconds: 300));
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.loading,
    required this.onChanged,
    required this.onSubmit,
    required this.onBack,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool loading;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.all(r.space(10)),
      child: Row(
        children: <Widget>[
          IconButton(onPressed: onBack, icon: Icon(Icons.arrow_forward_rounded, size: r.icon(28), color: colors.textPrimary)),
          SizedBox(width: r.space(4)),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: onChanged,
                  onSubmitted: (_) => onSubmit(),
                  decoration: InputDecoration(
                    hintText: 'جستجو در همه کالاها',
                    prefixIcon: IconButton(onPressed: loading ? null : onSubmit, icon: Icon(Icons.search_rounded, color: colors.textSecondary)),
                    suffixIcon: value.text.isEmpty ? null : IconButton(onPressed: onClear, icon: Icon(Icons.close_rounded, color: colors.textPrimary)),
                    contentPadding: EdgeInsets.symmetric(horizontal: r.space(14), vertical: r.space(12)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(28)), borderSide: BorderSide(color: colors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(28)), borderSide: BorderSide(color: colors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(28)), borderSide: const BorderSide(color: AppColors.primary, width: 1.3)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchIdle extends StatelessWidget {
  const _SearchIdle({super.key, required this.recentSearches, required this.onClearRecent, required this.onRecentTap});

  final List<String> recentSearches;
  final VoidCallback onClearRecent;
  final ValueChanged<String> onRecentTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return ListView(
      padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(18), r.pageHorizontalPadding, r.space(30)),
      children: <Widget>[
        if (recentSearches.isNotEmpty) ...<Widget>[
          Row(
            children: <Widget>[
              const AppText.titleSmall('جستجوهای اخیر', fontWeight: FontWeight.w700),
              const Spacer(),
              TextButton(onPressed: onClearRecent, child: AppText.labelMedium('پاک کردن', color: colors.textSecondary)),
            ],
          ),
          SizedBox(height: r.space(8)),
          Wrap(
            spacing: r.space(8),
            runSpacing: r.space(8),
            children: recentSearches
                .map(
                  (value) => ActionChip(
                    onPressed: () => onRecentTap(value),
                    avatar: Icon(Icons.history_rounded, size: r.icon(17), color: colors.textSecondary),
                    label: AppText.bodySmall(value),
                  ),
                )
                .toList(growable: false),
          ),
          SizedBox(height: r.space(26)),
        ],
        AppText.bodySmall('برای شروع جستجو حداقل ۳ کاراکتر وارد کنید.', color: colors.textMuted),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({super.key, required this.viewModel, required this.onCategory, required this.onBrand});

  final SearchViewModel viewModel;
  final ValueChanged<ProductCategoryFilterModel> onCategory;
  final ValueChanged<ProductBrandFilterModel> onBrand;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return ListView(
      padding: EdgeInsets.only(bottom: r.space(28)),
      children: <Widget>[
        if (viewModel.categories.isNotEmpty) ...<Widget>[
          const _SectionTitle(title: 'دسته‌بندی‌ها'),
          ...viewModel.categories.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
              leading: Icon(Icons.grid_view_rounded, color: colors.textSecondary),
              title: AppText.bodyMedium(item.name, fontWeight: FontWeight.w600),
              subtitle: const AppText.bodySmall('دسته‌بندی', color: AppColors.primary),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => onCategory(item),
            ),
          ),
        ],
        if (viewModel.brands.isNotEmpty) ...<Widget>[
          const _SectionTitle(title: 'برندها'),
          ...viewModel.brands.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
              leading: item.image.isEmpty
                  ? Icon(Icons.sell_outlined, color: colors.textSecondary)
                  : SizedBox(width: r.icon(38), height: r.icon(38), child: CachedNetworkImage(imageUrl: item.image, fit: BoxFit.contain)),
              title: AppText.bodyMedium(item.name, fontWeight: FontWeight.w600),
              subtitle: const AppText.bodySmall('برند', color: AppColors.primary),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => onBrand(item),
            ),
          ),
        ],
        if (viewModel.products.isNotEmpty) ...<Widget>[
          const _SectionTitle(title: 'محصولات مرتبط'),
          ...viewModel.products.map((item) => _ProductSuggestion(product: item)),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return Container(
      padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(18), r.pageHorizontalPadding, r.space(8)),
      color: colors.surfaceVariant,
      child: AppText.bodyMedium(title, fontWeight: FontWeight.w800),
    );
  }
}

class _ProductSuggestion extends StatelessWidget {
  const _ProductSuggestion({required this.product});
  final ProductCardModel product;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final subtitleParts = <String>[
      if (product.categories.isNotEmpty) product.categories.first.name,
      if (product.brand.name.isNotEmpty) product.brand.name,
    ];

    return ListTile(
      onTap: () => toProduct(id: product.id),
      contentPadding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding, vertical: r.space(5)),
      leading: SizedBox(
        width: r.icon(54),
        height: r.icon(54),
        child: CachedNetworkImage(
          imageUrl: product.image,
          fit: BoxFit.contain,
          errorWidget: (_, _, _) => Icon(Icons.image_not_supported_outlined, color: colors.textMuted),
        ),
      ),
      title: AppText.bodyMedium(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600),
      subtitle: subtitleParts.isEmpty ? null : AppText.bodySmall(subtitleParts.join(' • '), maxLines: 1, overflow: TextOverflow.ellipsis, color: AppColors.primary),
      trailing: const Icon(Icons.chevron_left_rounded),
    );
  }
}
