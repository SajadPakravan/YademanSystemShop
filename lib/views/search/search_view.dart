import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/screens/main_screen.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/view_models/search/search_view_model.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';

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
        backgroundColor: Colors.white,
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
              const Divider(height: 1, color: Color(0xffeeeeee)),
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
                            _controller.value = TextEditingValue(
                              text: value,
                              selection: TextSelection.collapsed(offset: value.length),
                            );
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        children: <Widget>[
          IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_forward_rounded, size: 28)),
          const SizedBox(width: 4),
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
                    hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
                    prefixIcon: IconButton(onPressed: loading ? null : onSubmit, icon: const Icon(Icons.search_rounded, color: Colors.black54)),
                    suffixIcon: value.text.isEmpty
                        ? null
                        : IconButton(onPressed: onClear, icon: const Icon(Icons.close_rounded, color: Colors.black87)),
                    filled: true,
                    fillColor: const Color(0xfffafafa),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(color: Color(0xffdedede)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(color: Color(0xffbdbdbd), width: 1.2),
                    ),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      children: <Widget>[
        if (recentSearches.isNotEmpty) ...<Widget>[
          Row(
            children: <Widget>[
              const Text('جستجوهای اخیر', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(onPressed: onClearRecent, child: const Text('پاک کردن', style: TextStyle(color: Colors.black54))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches
                .map(
                  (value) => ActionChip(
                    onPressed: () => onRecentTap(value),
                    avatar: const Icon(Icons.history_rounded, size: 17),
                    label: Text(value),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xffdddddd)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 26),
        ],
        const Text('برای شروع جستجو حداقل ۳ کاراکتر وارد کنید.', style: TextStyle(color: Colors.black45, fontSize: 13)),
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
    // if (!viewModel.hasLocalResults) {
    //   return const Center(child: Text('نتیجه‌ای پیدا نشد.', style: TextStyle(color: Colors.black54)));
    // }

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: <Widget>[
        if (viewModel.categories.isNotEmpty) ...<Widget>[
          const _SectionTitle(title: 'دسته‌بندی‌ها'),
          ...viewModel.categories.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
              leading: const Icon(Icons.grid_view_rounded, color: Colors.black54),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('دسته‌بندی', style: TextStyle(color: Color(0xff2682bd), fontSize: 12)),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => onCategory(item),
            ),
          ),
        ],
        if (viewModel.brands.isNotEmpty) ...<Widget>[
          const _SectionTitle(title: 'برندها'),
          ...viewModel.brands.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
              leading: item.image.isEmpty
                  ? const Icon(Icons.sell_outlined, color: Colors.black54)
                  : SizedBox(
                      width: 38,
                      height: 38,
                      child: CachedNetworkImage(imageUrl: item.image, fit: BoxFit.contain),
                    ),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('برند', style: TextStyle(color: Color(0xff2682bd), fontSize: 12)),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      color: const Color(0xfffafafa),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
    );
  }
}

class _ProductSuggestion extends StatelessWidget {
  const _ProductSuggestion({required this.product});
  final ProductCardModel product;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (product.categories.isNotEmpty) product.categories.first.name,
      if (product.brand.name.isNotEmpty) product.brand.name,
    ];

    return ListTile(
      onTap: () => toProduct(id: product.id),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      leading: SizedBox(
        width: 54,
        height: 54,
        child: CachedNetworkImage(
          imageUrl: product.image,
          fit: BoxFit.contain,
          errorWidget: (_, _, _) => const Icon(Icons.image_not_supported_outlined, color: Colors.black26),
        ),
      ),
      title: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xff2682bd), fontSize: 12)),
      trailing: const Icon(Icons.chevron_left_rounded),
    );
  }
}
