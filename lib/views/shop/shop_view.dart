import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';
import 'package:yad_sys/widgets/price_view_widget.dart';
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
        backgroundColor: const Color(0xfffafafa),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: vm.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: <Widget>[
                SliverToBoxAdapter(child: _buildTopArea(context)),
                if (vm.isInitialLoading && vm.productsLst.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (vm.errorMessage != null && vm.productsLst.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(message: vm.errorMessage!, onRetry: vm.retry),
                  )
                else if (vm.productsLst.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else ...<Widget>[
                  SliverToBoxAdapter(child: _buildResultHeader()),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = vm.productsLst[index];
                        return _ShopProductCard(product: product);
                      },
                      childCount: vm.productsLst.length,
                    ),
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

  Widget _buildTopArea(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          children: <Widget>[
            const Search(),
            const SizedBox(height: 12),
            _buildPrimaryFilters(context),
            if (vm.filters.attributes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              _buildAttributeFilters(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryFilters(BuildContext context) {
    final state = vm.appliedFilters;

    // دکمه «فیلتر» ثابت در سمت راست می‌ماند و بقیه فیلترهای اصلی
    // در فضای سمت چپ آن به صورت افقی اسکرول می‌شوند.
    return SizedBox(
      height: 45,
      child: Row(
        children: <Widget>[
          _FilterChipButton(
            title: 'فیلتر',
            active: state.activeFilterGroupsCount > 0,
            badgeCount: state.activeFilterGroupsCount,
            icon: Icons.tune_rounded,
            compactMargin: true,
            onTap: () => _openFullFilter(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                _FilterChipButton(
                  title: vm.sortChipTitle(state),
                  active: state.hasNonDefaultSort,
                  icon: Icons.sort_rounded,
                  onTap: () => _openSortSheet(context),
                ),
                _FilterChipButton(
                  title: vm.categoryChipTitle(state),
                  active: state.categoryIds.isNotEmpty,
                  badgeCount: state.categoryIds.length > 1 ? state.categoryIds.length : 0,
                  onTap: () => _openCategorySheet(context),
                ),
                _FilterChipButton(
                  title: vm.brandChipTitle(state),
                  active: state.brandIds.isNotEmpty,
                  badgeCount: state.brandIds.length > 1 ? state.brandIds.length : 0,
                  onTap: () => _openBrandSheet(context),
                ),
                _FilterChipButton(
                  title: 'محدوده قیمت',
                  active: state.hasPriceFilter,
                  onTap: () => _openPriceSheet(context),
                ),
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
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: vm.filters.attributes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final attribute = vm.filters.attributes[index];
          final count = state.selectedOptionsFor(attribute.id).length;
          return _FilterChipButton(
            title: vm.attributeChipTitle(attribute, state),
            active: count > 0,
            badgeCount: count > 1 ? count : 0,
            compactMargin: true,
            onTap: () => _openAttributeSheet(context, attribute),
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
        children: <Widget>[
          const Icon(Icons.grid_view_rounded, size: 22, color: Colors.black87),
          const Spacer(),
          Text(
            '${_fa(vm.productCount)} کالا',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff202020)),
          ),
          if (vm.isRefreshing) ...<Widget>[
            const SizedBox(width: 10),
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ],
      ),
    );
  }

  Future<void> _openSortSheet(BuildContext context) async {
    final draft = vm.appliedFilters.copy();
    vm.beginPreview();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selected = ShopSortOption.resolve(orderby: draft.orderby, order: draft.order, onSale: draft.onSale);
            return _FilterSheetShell(
              title: 'مرتب‌سازی',
              contentHeight: math.min(MediaQuery.sizeOf(context).height * 0.52, 7 * 52.0),
              footer: _SheetFooter(
                viewModel: vm,
                deleteEnabled: draft.hasNonDefaultSort,
                onDelete: () async {
                  setSheetState(() {
                    draft.orderby = 'date';
                    draft.order = 'desc';
                    draft.onSale = null;
                  });
                  final ready = await vm.previewFiltersNow(draft);
                  if (!ready || !sheetContext.mounted) return;
                  vm.applyPreview(draft);
                  Navigator.pop(sheetContext);
                },
                onApply: () {
                  final result = draft.copy();
                  if (!vm.applyPreview(result)) return;
                  Navigator.pop(sheetContext);
                },
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: ShopSortOption.values.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xffeeeeee)),
                itemBuilder: (context, index) {
                  final option = ShopSortOption.values[index];
                  final checked = option.title == selected.title;
                  return ListTile(
                    dense: true,
                    minVerticalPadding: 4,
                    title: Text(option.title, style: TextStyle(fontWeight: checked ? FontWeight.w700 : FontWeight.w400)),
                    trailing: checked ? const Icon(Icons.check_rounded, color: _accent) : null,
                    onTap: () {
                      setSheetState(() {
                        draft.orderby = option.orderby;
                        draft.order = option.order;
                        draft.onSale = option.onSale;
                      });
                      vm.previewFilters(draft);
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
    vm.cancelPreview();
  }

  Future<void> _openCategorySheet(BuildContext context) async {
    final draft = vm.appliedFilters.copy();
    final rows = _flattenCategories(vm.filters.categories);
    vm.beginPreview();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _FilterSheetShell(
              title: 'دسته‌بندی',
              contentHeight: _adaptiveContentHeight(context, rows.length),
              footer: _SheetFooter(
                viewModel: vm,
                deleteEnabled: draft.categoryIds.isNotEmpty,
                onDelete: () async {
                  setSheetState(draft.categoryIds.clear);
                  final ready = await vm.previewFiltersNow(draft);
                  if (!ready || !sheetContext.mounted) return;
                  vm.applyPreview(draft);
                  Navigator.pop(sheetContext);
                },
                onApply: () {
                  final result = draft.copy();
                  if (!vm.applyPreview(result)) return;
                  Navigator.pop(sheetContext);
                },
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xfff0f0f0)),
                itemBuilder: (context, index) {
                  final row = rows[index];
                  final checked = draft.categoryIds.contains(row.category.id);
                  return CheckboxListTile(
                    value: checked,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.only(right: 16.0 + (row.depth * 18), left: 16),
                    title: Text(row.category.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                    secondary: row.depth > 0 ? const Icon(Icons.subdirectory_arrow_left_rounded, size: 17, color: Colors.black26) : null,
                    onChanged: (value) {
                      setSheetState(() {
                        if (value == true) {
                          draft.categoryIds.add(row.category.id);
                        } else {
                          draft.categoryIds.remove(row.category.id);
                        }
                      });
                      vm.previewFilters(draft);
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
    vm.cancelPreview();
  }

  Future<void> _openBrandSheet(BuildContext context) async {
    final draft = vm.appliedFilters.copy();
    final brands = vm.filters.brands;
    vm.beginPreview();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _FilterSheetShell(
              title: 'برند',
              contentHeight: _adaptiveContentHeight(context, brands.length, maxFactor: 0.67),
              footer: _SheetFooter(
                viewModel: vm,
                deleteEnabled: draft.brandIds.isNotEmpty,
                onDelete: () async {
                  setSheetState(draft.brandIds.clear);
                  final ready = await vm.previewFiltersNow(draft);
                  if (!ready || !sheetContext.mounted) return;
                  vm.applyPreview(draft);
                  Navigator.pop(sheetContext);
                },
                onApply: () {
                  final result = draft.copy();
                  if (!vm.applyPreview(result)) return;
                  Navigator.pop(sheetContext);
                },
              ),
              child: _BrandList(
                brands: brands,
                selectedIds: draft.brandIds,
                onChanged: (brand, value) {
                  setSheetState(() {
                    if (value) {
                      draft.brandIds.add(brand.id);
                    } else {
                      draft.brandIds.remove(brand.id);
                    }
                  });
                  vm.previewFilters(draft);
                },
              ),
            );
          },
        );
      },
    );
    vm.cancelPreview();
  }

  Future<void> _openPriceSheet(BuildContext context) async {
    final draft = vm.appliedFilters.copy();
    vm.beginPreview();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final ceiling = math.max(vm.priceCeiling, math.max(draft.maxPrice ?? 0, draft.minPrice ?? 0)).toDouble();
            final start = (draft.minPrice ?? vm.priceFloor).clamp(vm.priceFloor, ceiling.toInt()).toDouble();
            final end = (draft.maxPrice ?? ceiling.toInt()).clamp(start.toInt(), ceiling.toInt()).toDouble();

            return _FilterSheetShell(
              title: 'محدوده قیمت',
              contentHeight: 230,
              footer: _SheetFooter(
                viewModel: vm,
                deleteEnabled: draft.hasPriceFilter,
                onDelete: () async {
                  setSheetState(() {
                    draft.minPrice = null;
                    draft.maxPrice = null;
                  });
                  final ready = await vm.previewFiltersNow(draft);
                  if (!ready || !sheetContext.mounted) return;
                  vm.applyPreview(draft);
                  Navigator.pop(sheetContext);
                },
                onApply: () {
                  final result = draft.copy();
                  if (!vm.applyPreview(result)) return;
                  Navigator.pop(sheetContext);
                },
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: _PriceLabel(label: 'از', value: draft.minPrice ?? vm.priceFloor)),
                        const SizedBox(width: 14),
                        Expanded(child: _PriceLabel(label: 'تا', value: draft.maxPrice ?? ceiling.toInt())),
                      ],
                    ),
                    const SizedBox(height: 20),
                    RangeSlider(
                      min: vm.priceFloor.toDouble(),
                      max: ceiling <= vm.priceFloor ? vm.priceFloor + 1 : ceiling,
                      values: RangeValues(start, end),
                      activeColor: _accent,
                      labels: RangeLabels(_money(start.round()), _money(end.round())),
                      onChanged: (values) {
                        setSheetState(() {
                          draft.minPrice = values.start.round();
                          draft.maxPrice = values.end.round();
                        });
                        vm.previewFilters(draft);
                      },
                    ),
                    const Text('مبالغ بر حسب تومان هستند.', style: TextStyle(color: Colors.black45, fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    vm.cancelPreview();
  }

  Future<void> _openAttributeSheet(BuildContext context, ProductAttributeFilterModel attribute) async {
    final draft = vm.appliedFilters.copy();
    draft.attributeOptionIds.putIfAbsent(attribute.id, () => <int>{});
    vm.beginPreview();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selected = draft.attributeOptionIds[attribute.id]!;
            final isColor = _isColorAttribute(attribute);
            return _FilterSheetShell(
              title: attribute.name,
              contentHeight: _adaptiveContentHeight(
                context,
                attribute.options.length,
                itemExtent: isColor ? 88 : 55,
                maxFactor: 0.62,
              ),
              footer: _SheetFooter(
                viewModel: vm,
                deleteEnabled: selected.isNotEmpty,
                onDelete: () async {
                  setSheetState(selected.clear);
                  draft.attributeOptionIds.remove(attribute.id);
                  final ready = await vm.previewFiltersNow(draft);
                  if (!ready || !sheetContext.mounted) return;
                  vm.applyPreview(draft);
                  Navigator.pop(sheetContext);
                },
                onApply: () {
                  if (selected.isEmpty) draft.attributeOptionIds.remove(attribute.id);
                  final result = draft.copy();
                  if (!vm.applyPreview(result)) return;
                  Navigator.pop(sheetContext);
                },
              ),
              child: isColor
                  ? _ColorOptionsGrid(
                      options: attribute.options,
                      selectedIds: selected,
                      onToggle: (option) {
                        setSheetState(() => _toggleId(selected, option.id));
                        vm.previewFilters(draft);
                      },
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: attribute.options.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xffeeeeee)),
                      itemBuilder: (context, index) {
                        final option = attribute.options[index];
                        final checked = selected.contains(option.id);
                        return CheckboxListTile(
                          value: checked,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(option.name),
                          onChanged: (_) {
                            setSheetState(() => _toggleId(selected, option.id));
                            vm.previewFilters(draft);
                          },
                        );
                      },
                    ),
            );
          },
        );
      },
    );
    vm.cancelPreview();
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
        return _FullFilterDialog(viewModel: vm);
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

  double _adaptiveContentHeight(
    BuildContext context,
    int itemCount, {
    double itemExtent = 55,
    double maxFactor = 0.60,
  }) {
    final available = MediaQuery.sizeOf(context).height * maxFactor;
    return math.min(available, math.max(120, itemCount * itemExtent));
  }
}

class _FullFilterDialog extends StatefulWidget {
  const _FullFilterDialog({required this.viewModel});

  final ShopViewModel viewModel;

  @override
  State<_FullFilterDialog> createState() => _FullFilterDialogState();
}

class _FullFilterDialogState extends State<_FullFilterDialog> {
  late ShopFilterState draft;

  ShopViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    draft = vm.appliedFilters.copy();
  }

  void _changed() {
    setState(() {});
    vm.previewFilters(draft);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _flattenCategories(vm.filters.categories);
    final ceiling = math.max(vm.priceCeiling, math.max(draft.maxPrice ?? 0, draft.minPrice ?? 0));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Material(
          color: const Color(0xfff8f8f8),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: <Widget>[
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                    const Spacer(),
                    const Text('فیلترها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  children: <Widget>[
                    _FullFilterSection(
                      title: 'مرتب‌سازی',
                      subtitle: vm.sortChipTitle(draft),
                      child: Column(
                        children: ShopSortOption.values.map((option) {
                          final selected = ShopSortOption.resolve(orderby: draft.orderby, order: draft.order, onSale: draft.onSale).title == option.title;
                          return RadioListTile<String>(
                            value: option.title,
                            groupValue: selected ? option.title : null,
                            title: Text(option.title),
                            onChanged: (_) {
                              draft.orderby = option.orderby;
                              draft.order = option.order;
                              draft.onSale = option.onSale;
                              _changed();
                            },
                          );
                        }).toList(growable: false),
                      ),
                    ),
                    _FullFilterSection(
                      title: 'محدوده قیمت',
                      subtitle: draft.hasPriceFilter
                          ? '${_money(draft.minPrice ?? vm.priceFloor)} تا ${_money(draft.maxPrice ?? ceiling)} تومان'
                          : 'بدون محدودیت',
                      child: _InlinePriceFilter(
                        floor: vm.priceFloor,
                        ceiling: ceiling,
                        minValue: draft.minPrice,
                        maxValue: draft.maxPrice,
                        onChanged: (min, max) {
                          draft.minPrice = min;
                          draft.maxPrice = max;
                          _changed();
                        },
                      ),
                    ),
                    _FullFilterSection(
                      title: 'دسته‌بندی',
                      subtitle: draft.categoryIds.isEmpty ? 'همه دسته‌ها' : '${_fa(draft.categoryIds.length)} مورد انتخاب شده',
                      child: Column(
                        children: categories.map((row) {
                          return CheckboxListTile(
                            value: draft.categoryIds.contains(row.category.id),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.only(right: row.depth * 18.0, left: 4),
                            dense: true,
                            title: Text(row.category.name),
                            onChanged: (value) {
                              if (value == true) {
                                draft.categoryIds.add(row.category.id);
                              } else {
                                draft.categoryIds.remove(row.category.id);
                              }
                              _changed();
                            },
                          );
                        }).toList(growable: false),
                      ),
                    ),
                    _FullFilterSection(
                      title: 'برند',
                      subtitle: draft.brandIds.isEmpty ? 'همه برندها' : '${_fa(draft.brandIds.length)} مورد انتخاب شده',
                      child: Column(
                        children: vm.filters.brands.map((brand) {
                          return CheckboxListTile(
                            value: draft.brandIds.contains(brand.id),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            title: Text(brand.name),
                            subtitle: brand.count > 0 ? Text('${_fa(brand.count)} کالا') : null,
                            onChanged: (value) {
                              if (value == true) {
                                draft.brandIds.add(brand.id);
                              } else {
                                draft.brandIds.remove(brand.id);
                              }
                              _changed();
                            },
                          );
                        }).toList(growable: false),
                      ),
                    ),
                    ...vm.filters.attributes.map((attribute) {
                      final selected = draft.attributeOptionIds.putIfAbsent(attribute.id, () => <int>{});
                      return _FullFilterSection(
                        title: attribute.name,
                        subtitle: selected.isEmpty ? 'همه' : '${_fa(selected.length)} مورد انتخاب شده',
                        child: _isColorAttribute(attribute)
                            ? _ColorOptionsGrid(
                                options: attribute.options,
                                selectedIds: selected,
                                onToggle: (option) {
                                  _toggleId(selected, option.id);
                                  _changed();
                                },
                              )
                            : Column(
                                children: attribute.options.map((option) {
                                  return CheckboxListTile(
                                    value: selected.contains(option.id),
                                    controlAffinity: ListTileControlAffinity.leading,
                                    dense: true,
                                    title: Text(option.name),
                                    onChanged: (_) {
                                      _toggleId(selected, option.id);
                                      _changed();
                                    },
                                  );
                                }).toList(growable: false),
                              ),
                      );
                    }),
                  ],
                ),
              ),
              _SheetFooter(
                viewModel: vm,
                deleteEnabled: draft.activeFilterGroupsCount > 0,
                deleteLabel: 'حذف فیلترها',
                onDelete: () async {
                  draft.clearAll(keepSearch: true);
                  setState(() {});
                  final ready = await vm.previewFiltersNow(draft);
                  if (!ready || !context.mounted) return;
                  vm.applyPreview(draft);
                  Navigator.pop(context);
                },
                onApply: () {
                  final result = draft.copy();
                  if (!vm.applyPreview(result)) return;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlinePriceFilter extends StatefulWidget {
  const _InlinePriceFilter({
    required this.floor,
    required this.ceiling,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  final int floor;
  final int ceiling;
  final int? minValue;
  final int? maxValue;
  final void Function(int? min, int? max) onChanged;

  @override
  State<_InlinePriceFilter> createState() => _InlinePriceFilterState();
}

class _InlinePriceFilterState extends State<_InlinePriceFilter> {
  late RangeValues values;

  @override
  void initState() {
    super.initState();
    _resetValues();
  }

  @override
  void didUpdateWidget(covariant _InlinePriceFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minValue != widget.minValue || oldWidget.maxValue != widget.maxValue || oldWidget.ceiling != widget.ceiling) {
      _resetValues();
    }
  }

  void _resetValues() {
    final ceiling = math.max(widget.ceiling, widget.floor + 1);
    final start = (widget.minValue ?? widget.floor).clamp(widget.floor, ceiling).toDouble();
    final end = (widget.maxValue ?? ceiling).clamp(start.toInt(), ceiling).toDouble();
    values = RangeValues(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final ceiling = math.max(widget.ceiling, widget.floor + 1).toDouble();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _PriceLabel(label: 'از', value: values.start.round())),
              const SizedBox(width: 10),
              Expanded(child: _PriceLabel(label: 'تا', value: values.end.round())),
            ],
          ),
          RangeSlider(
            min: widget.floor.toDouble(),
            max: ceiling,
            values: values,
            activeColor: _accent,
            onChanged: (newValues) {
              setState(() => values = newValues);
              widget.onChanged(newValues.start.round(), newValues.end.round());
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: widget.minValue == null && widget.maxValue == null ? null : () => widget.onChanged(null, null),
              child: const Text('حذف محدوده قیمت'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullFilterSection extends StatelessWidget {
  const _FullFilterSection({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xffe8e8e8)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        children: <Widget>[child],
      ),
    );
  }
}

class _BrandList extends StatefulWidget {
  const _BrandList({required this.brands, required this.selectedIds, required this.onChanged});

  final List<ProductBrandFilterModel> brands;
  final Set<int> selectedIds;
  final void Function(ProductBrandFilterModel brand, bool selected) onChanged;

  @override
  State<_BrandList> createState() => _BrandListState();
}

class _BrandListState extends State<_BrandList> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final normalized = query.trim().toLowerCase();
    final visible = normalized.isEmpty
        ? widget.brands
        : widget.brands.where((brand) => brand.name.toLowerCase().contains(normalized)).toList(growable: false);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: InputDecoration(
              hintText: 'جستجوی نام برند',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xfff8f8f8),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: visible.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xffeeeeee)),
            itemBuilder: (context, index) {
              final brand = visible[index];
              final checked = widget.selectedIds.contains(brand.id);
              return CheckboxListTile(
                value: checked,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(brand.name),
                subtitle: brand.count > 0 ? Text('${_fa(brand.count)} کالا') : null,
                onChanged: (value) => widget.onChanged(brand, value == true),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ColorOptionsGrid extends StatelessWidget {
  const _ColorOptionsGrid({required this.options, required this.selectedIds, required this.onToggle});

  final List<ProductAttributeOptionModel> options;
  final Set<int> selectedIds;
  final ValueChanged<ProductAttributeOptionModel> onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 360 ? 3 : 4;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 96,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
        final option = options[index];
        final selected = selectedIds.contains(option.id);
        final color = _colorForOption(option);
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onToggle(option),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected ? _activeChipBackground : Colors.white,
              border: Border.all(color: selected ? _accent : const Color(0xffe0e0e0), width: selected ? 1.4 : 1),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: color,
                      border: Border.all(color: color == Colors.white ? const Color(0xffdedede) : Colors.transparent),
                    ),
                    child: selected
                        ? Icon(Icons.check_rounded, color: _bestForeground(color), size: 22)
                        : null,
                  ),
                ),
                const SizedBox(height: 5),
                Text(option.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          );
        },
      );
      },
    );
  }
}

class _FilterSheetShell extends StatelessWidget {
  const _FilterSheetShell({
    required this.title,
    required this.contentHeight,
    required this.child,
    required this.footer,
  });

  final String title;
  final double contentHeight;
  final Widget child;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;
    final safeContentHeight = math.min(contentHeight, maxHeight - 150);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 8),
            Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
              child: Row(
                children: <Widget>[
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  const Spacer(),
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xffeeeeee)),
            SizedBox(height: safeContentHeight, child: child),
            footer,
          ],
        ),
      ),
    );
  }
}

class _SheetFooter extends StatelessWidget {
  const _SheetFooter({
    required this.viewModel,
    required this.deleteEnabled,
    required this.onDelete,
    required this.onApply,
    this.deleteLabel = 'حذف فیلتر',
  });

  final ShopViewModel viewModel;
  final bool deleteEnabled;
  final VoidCallback onDelete;
  final VoidCallback onApply;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, math.max(10, MediaQuery.paddingOf(context).bottom + 4)),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffeeeeee))),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: deleteEnabled ? onDelete : null,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: BorderSide(color: deleteEnabled ? _accent : Colors.black12),
                foregroundColor: _accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(deleteLabel),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedBuilder(
              animation: viewModel,
              builder: (context, child) {
                return IgnorePointer(
                  ignoring: !viewModel.canApplyPreview,
                  child: FilledButton(
                    onPressed: onApply,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: viewModel.isPreviewLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : viewModel.previewErrorMessage != null
                            ? const Text('خطا در محاسبه محصولات')
                            : Text('مشاهده ${_fa(viewModel.previewCount)} محصول'),
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

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.title,
    required this.active,
    required this.onTap,
    this.badgeCount = 0,
    this.icon,
    this.compactMargin = false,
  });

  final String title;
  final bool active;
  final int badgeCount;
  final IconData? icon;
  final VoidCallback onTap;
  final bool compactMargin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: compactMargin ? 0 : 7),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Material(
            color: active ? _activeChipBackground : Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: active ? const Color(0xffffc9d3) : const Color(0xffdddddd)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (icon != null) ...<Widget>[
                      Icon(icon, size: 18, color: active ? _accent : Colors.black54),
                      const SizedBox(width: 5),
                    ],
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 125),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: active ? _accent : const Color(0xff333333), fontWeight: active ? FontWeight.w600 : FontWeight.w400),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: active ? _accent : Colors.black54),
                  ],
                ),
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -5,
              left: -3,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
                child: Text(_fa(badgeCount), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShopProductCard extends StatelessWidget {
  const _ShopProductCard({required this.product});

  final ProductCardModel product;

  @override
  Widget build(BuildContext context) {
    final displayName = (product.variationName?.trim().isNotEmpty ?? false) ? '${product.name} | ${product.variationName!.trim()}' : product.name;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => toProduct(id: product.id),
        child: Container(
          height: 190,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffeeeeee)))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: 145,
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.black26)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (product.discountPercent > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xfffff0f3), borderRadius: BorderRadius.circular(8)),
                          child: const Text('فروش ویژه', style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    if (product.discountPercent > 0) const SizedBox(height: 7),
                    Text(
                      displayName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.55, fontWeight: FontWeight.w500, color: Color(0xff333333)),
                    ),
                    const SizedBox(height: 8),
                    if (product.stockQuantity > 0 && product.stockQuantity <= 3)
                      Text(
                        '${_fa(product.stockQuantity)} عدد در انبار باقی مانده',
                        style: const TextStyle(color: _accent, fontSize: 11.5, fontWeight: FontWeight.w600),
                      )
                    else if (product.stockQuantity > 0)
                      const Text('موجود در انبار', style: TextStyle(color: Colors.black45, fontSize: 11.5)),
                    const Spacer(),
                    if (product.inquiry)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        decoration: BoxDecoration(color: const Color(0xffeef5fd), borderRadius: BorderRadius.circular(9)),
                        child: const Text('استعلام قیمت و موجودی', textAlign: TextAlign.center, style: TextStyle(color: Color(0xff0353a4), fontSize: 12, fontWeight: FontWeight.w700)),
                      )
                    else
                      PriceViewWidget(product: product),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.label, required this.value});

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
        children: <Widget>[
          Text(label, style: const TextStyle(color: Colors.black45, fontSize: 12)),
          const Spacer(),
          Flexible(child: Text('${_money(value)} تومان', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
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
          children: <Widget>[
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
          children: <Widget>[
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

class _CategoryRowData {
  const _CategoryRowData(this.category, this.depth);

  final ProductCategoryFilterModel category;
  final int depth;
}

List<_CategoryRowData> _flattenCategories(List<ProductCategoryFilterModel> categories) {
  final result = <_CategoryRowData>[];

  void add(List<ProductCategoryFilterModel> items, int depth) {
    for (final item in items) {
      result.add(_CategoryRowData(item, depth));
      add(item.children, depth + 1);
    }
  }

  add(categories, 0);
  return result;
}

void _toggleId(Set<int> set, int id) {
  if (!set.add(id)) set.remove(id);
}

bool _isColorAttribute(ProductAttributeFilterModel attribute) {
  final value = attribute.name.replaceAll('\u200c', '').replaceAll(' ', '').toLowerCase();
  return value.contains('رنگ') || value == 'color';
}

Color _colorForOption(ProductAttributeOptionModel option) {
  final raw = option.color.trim();
  if (raw.isNotEmpty) {
    final hex = raw.replaceFirst('#', '');
    if (hex.length == 6) {
      final value = int.tryParse('FF$hex', radix: 16);
      if (value != null) return Color(value);
    }
    if (hex.length == 8) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) return Color(value);
    }
  }
  return _colorForName(option.name);
}

Color _colorForName(String rawName) {
  final name = rawName.replaceAll('\u200c', '').replaceAll(' ', '').toLowerCase();
  if (name.contains('مشک')) return Colors.black;
  if (name.contains('سفید')) return Colors.white;
  if (name.contains('آبی') || name.contains('ابي')) return const Color(0xff2878c8);
  if (name.contains('قرمز')) return const Color(0xffe53935);
  if (name.contains('صورتی')) return const Color(0xffd81b60);
  if (name.contains('بنفش')) return const Color(0xff7b1fa2);
  if (name.contains('سبز')) return const Color(0xff5a9f32);
  if (name.contains('نارنجی')) return const Color(0xffff8c1a);
  if (name.contains('خاکستری') || name.contains('طوسی')) return const Color(0xff9e9e9e);
  if (name.contains('طلایی') || name.contains('طلا')) return const Color(0xffffc107);
  if (name.contains('قهوه')) return const Color(0xff795548);
  if (name.contains('نقره')) return const Color(0xffc0c0c0);
  return const Color(0xff90a4ae);
}

Color _bestForeground(Color color) {
  return ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black87;
}

String _fa(Object value) => value.toString().toPersianDigit();
String _money(int value) => value.toString().toPersianDigit().seRagham();

const Color _accent = Color(0xffe6123f);
const Color _activeChipBackground = Color(0xfffff0f3);
