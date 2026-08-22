import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';
import 'package:yad_sys/views/shop/filter/brand_list_view.dart';
import 'package:yad_sys/views/shop/filter/sheet_footer_view.dart';
import 'package:yad_sys/views/shop/shop_view.dart';
import 'package:yad_sys/widgets/cards/color_options_cards_widget.dart';

Future<void> sortSheet(BuildContext context, ShopViewModel viewModel) async {
  final draft = viewModel.appliedFilters.copy();
  viewModel.beginPreview();

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
            footer: SheetFooterView(
              viewModel: viewModel,
              deleteEnabled: draft.hasNonDefaultSort,
              onDelete: () async {
                setSheetState(() {
                  draft.orderby = 'date';
                  draft.order = 'desc';
                  draft.onSale = null;
                });
                final ready = await viewModel.previewFiltersNow(draft);
                if (!ready || !sheetContext.mounted) return;
                viewModel.applyPreview(draft);
                Navigator.pop(sheetContext);
              },
              onApply: () {
                final result = draft.copy();
                if (!viewModel.applyPreview(result)) return;
                Navigator.pop(sheetContext);
              },
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: ShopSortOption.values.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xffeeeeee)),
              itemBuilder: (context, index) {
                final option = ShopSortOption.values[index];
                final checked = option.title == selected.title;
                return ListTile(
                  dense: true,
                  minVerticalPadding: 4,
                  title: Text(option.title, style: TextStyle(fontWeight: checked ? FontWeight.w700 : FontWeight.w400)),
                  trailing: checked ? Icon(Icons.check_rounded, color: AppColors.accent) : null,
                  onTap: () {
                    setSheetState(() {
                      draft.orderby = option.orderby;
                      draft.order = option.order;
                      draft.onSale = option.onSale;
                    });
                    viewModel.previewFilters(draft);
                  },
                );
              },
            ),
          );
        },
      );
    },
  );
  viewModel.cancelPreview();
}

Future<void> categorySheet(BuildContext context, ShopViewModel viewModel) async {
  final draft = viewModel.appliedFilters.copy();
  final rows = flattenCategories(viewModel.filters.categories);
  viewModel.beginPreview();

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
            footer: SheetFooterView(
              viewModel: viewModel,
              deleteEnabled: draft.categoryIds.isNotEmpty,
              onDelete: () async {
                setSheetState(draft.categoryIds.clear);
                final ready = await viewModel.previewFiltersNow(draft);
                if (!ready || !sheetContext.mounted) return;
                viewModel.applyPreview(draft);
                Navigator.pop(sheetContext);
              },
              onApply: () {
                final result = draft.copy();
                if (!viewModel.applyPreview(result)) return;
                Navigator.pop(sheetContext);
              },
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: rows.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xfff0f0f0)),
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
                    viewModel.previewFilters(draft);
                  },
                );
              },
            ),
          );
        },
      );
    },
  );
  viewModel.cancelPreview();
}

List<CategoryRowData> flattenCategories(List<ProductCategoryFilterModel> categories) {
  final result = <CategoryRowData>[];

  void add(List<ProductCategoryFilterModel> items, int depth) {
    for (final item in items) {
      result.add(CategoryRowData(item, depth));
      add(item.children, depth + 1);
    }
  }

  add(categories, 0);
  return result;
}

Future<void> brandSheet(BuildContext context, ShopViewModel viewModel) async {
  final draft = viewModel.appliedFilters.copy();
  final brands = viewModel.filters.brands;
  viewModel.beginPreview();

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
            footer: SheetFooterView(
              viewModel: viewModel,
              deleteEnabled: draft.brandIds.isNotEmpty,
              onDelete: () async {
                setSheetState(draft.brandIds.clear);
                final ready = await viewModel.previewFiltersNow(draft);
                if (!ready || !sheetContext.mounted) return;
                viewModel.applyPreview(draft);
                Navigator.pop(sheetContext);
              },
              onApply: () {
                final result = draft.copy();
                if (!viewModel.applyPreview(result)) return;
                Navigator.pop(sheetContext);
              },
            ),
            child: BrandListView(
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
                viewModel.previewFilters(draft);
              },
            ),
          );
        },
      );
    },
  );
  viewModel.cancelPreview();
}

Future<void> priceSheet(BuildContext context, ShopViewModel viewModel) async {
  final draft = viewModel.appliedFilters.copy();
  viewModel.beginPreview();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final ceiling = math.max(viewModel.priceCeiling, math.max(draft.maxPrice ?? 0, draft.minPrice ?? 0)).toDouble();
          final start = (draft.minPrice ?? viewModel.priceFloor).clamp(viewModel.priceFloor, ceiling.toInt()).toDouble();
          final end = (draft.maxPrice ?? ceiling.toInt()).clamp(start.toInt(), ceiling.toInt()).toDouble();

          return _FilterSheetShell(
            title: 'محدوده قیمت',
            contentHeight: 230,
            footer: SheetFooterView(
              viewModel: viewModel,
              deleteEnabled: draft.hasPriceFilter,
              onDelete: () async {
                setSheetState(() {
                  draft.minPrice = null;
                  draft.maxPrice = null;
                });
                final ready = await viewModel.previewFiltersNow(draft);
                if (!ready || !sheetContext.mounted) return;
                viewModel.applyPreview(draft);
                Navigator.pop(sheetContext);
              },
              onApply: () {
                final result = draft.copy();
                if (!viewModel.applyPreview(result)) return;
                Navigator.pop(sheetContext);
              },
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: PriceLabel(label: 'از', value: draft.minPrice ?? viewModel.priceFloor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: PriceLabel(label: 'تا', value: draft.maxPrice ?? ceiling.toInt()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RangeSlider(
                    min: viewModel.priceFloor.toDouble(),
                    max: ceiling <= viewModel.priceFloor ? viewModel.priceFloor + 1 : ceiling,
                    values: RangeValues(start, end),
                    activeColor: AppColors.accent,
                    labels: RangeLabels(AppFunction.faPrice(start.round()), AppFunction.faPrice(end.round())),
                    onChanged: (values) {
                      setSheetState(() {
                        draft.minPrice = values.start.round();
                        draft.maxPrice = values.end.round();
                      });
                      viewModel.previewFilters(draft);
                    },
                  ),
                  const Text('مبالغ بر حسب تومان هستند', style: TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      );
    },
  );
  viewModel.cancelPreview();
}

Future<void> attributeSheet(BuildContext context, ShopViewModel viewModel, ProductAttributeFilterModel attribute) async {
  final draft = viewModel.appliedFilters.copy();
  draft.attributeOptionIds.putIfAbsent(attribute.id, () => <int>{});
  viewModel.beginPreview();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final selected = draft.attributeOptionIds[attribute.id]!;
          final isColor = isColorAttribute(attribute);
          return _FilterSheetShell(
            title: attribute.name,
            contentHeight: _adaptiveContentHeight(context, attribute.options.length, itemExtent: isColor ? 88 : 55, maxFactor: 0.62),
            footer: SheetFooterView(
              viewModel: viewModel,
              deleteEnabled: selected.isNotEmpty,
              onDelete: () async {
                setSheetState(selected.clear);
                draft.attributeOptionIds.remove(attribute.id);
                final ready = await viewModel.previewFiltersNow(draft);
                if (!ready || !sheetContext.mounted) return;
                viewModel.applyPreview(draft);
                Navigator.pop(sheetContext);
              },
              onApply: () {
                if (selected.isEmpty) draft.attributeOptionIds.remove(attribute.id);
                final result = draft.copy();
                if (!viewModel.applyPreview(result)) return;
                Navigator.pop(sheetContext);
              },
            ),
            child: isColor
                ? ColorOptionsCardsWidget(
                    options: attribute.options,
                    selectedIds: selected,
                    onToggle: (option) {
                      setSheetState(() => toggleId(selected, option.id));
                      viewModel.previewFilters(draft);
                    },
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: attribute.options.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xffeeeeee)),
                    itemBuilder: (context, index) {
                      final option = attribute.options[index];
                      final checked = selected.contains(option.id);
                      return CheckboxListTile(
                        value: checked,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(option.name),
                        onChanged: (_) {
                          setSheetState(() => toggleId(selected, option.id));
                          viewModel.previewFilters(draft);
                        },
                      );
                    },
                  ),
          );
        },
      );
    },
  );
  viewModel.cancelPreview();
}

void toggleId(Set<int> set, int id) {
  if (!set.add(id)) set.remove(id);
}

double _adaptiveContentHeight(BuildContext context, int itemCount, {double itemExtent = 55, double maxFactor = 0.60}) {
  final available = MediaQuery.sizeOf(context).height * maxFactor;
  return math.min(available, math.max(120, itemCount * itemExtent));
}

class CategoryRowData {
  const CategoryRowData(this.category, this.depth);

  final ProductCategoryFilterModel category;
  final int depth;
}

class _FilterSheetShell extends StatelessWidget {
  const _FilterSheetShell({required this.title, required this.contentHeight, required this.child, required this.footer});

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
          children: [
            const SizedBox(height: 8),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), color: Colors.black54),
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
