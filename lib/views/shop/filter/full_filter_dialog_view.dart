import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';
import 'package:yad_sys/views/shop/filter/sheet_footer_view.dart';
import 'package:yad_sys/views/shop/shop_view.dart';
import 'package:yad_sys/widgets/bottom_sheet/filter_sheet_widget.dart';
import 'package:yad_sys/widgets/cards/color_options_cards_widget.dart';

class FullFilterDialog extends StatefulWidget {
  const FullFilterDialog({super.key, required this.viewModel});

  final ShopViewModel viewModel;

  @override
  State<FullFilterDialog> createState() => _FullFilterDialogState();
}

class _FullFilterDialogState extends State<FullFilterDialog> {
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

  @override
  Widget build(BuildContext context) {
    final categories = flattenCategories(vm.filters.categories);
    final ceiling = math.max(vm.priceCeiling, math.max(draft.maxPrice ?? 0, draft.minPrice ?? 0));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Material(
          color: const Color(0xfff8f8f8),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), color: Colors.black54),
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
                  children: [
                    _FullFilterSection(
                      title: 'مرتب‌سازی',
                      subtitle: vm.sortChipTitle(draft),
                      child: Column(
                        children: ShopSortOption.values
                            .map((option) {
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
                        })
                            .toList(growable: false),
                      ),
                    ),
                    _FullFilterSection(
                      title: 'محدوده قیمت',
                      subtitle: draft.hasPriceFilter
                          ? '${AppFunction.faPrice(draft.minPrice ?? vm.priceFloor)} تا ${AppFunction.faPrice(draft.maxPrice ?? ceiling)} تومان'
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
                      subtitle: draft.categoryIds.isEmpty ? 'همه دسته‌ها' : '${AppFunction.faDigit(draft.categoryIds.length)} مورد انتخاب شده',
                      child: Column(
                        children: categories
                            .map((row) {
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
                        })
                            .toList(growable: false),
                      ),
                    ),
                    _FullFilterSection(
                      title: 'برند',
                      subtitle: draft.brandIds.isEmpty ? 'همه برندها' : '${AppFunction.faDigit(draft.brandIds.length)} مورد انتخاب شده',
                      child: Column(
                        children: vm.filters.brands
                            .map((brand) {
                          return CheckboxListTile(
                            value: draft.brandIds.contains(brand.id),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            title: Text(brand.name),
                            subtitle: brand.count > 0 ? Text('${AppFunction.faDigit(brand.count)} کالا') : null,
                            onChanged: (value) {
                              if (value == true) {
                                draft.brandIds.add(brand.id);
                              } else {
                                draft.brandIds.remove(brand.id);
                              }
                              _changed();
                            },
                          );
                        })
                            .toList(growable: false),
                      ),
                    ),
                    ...vm.filters.attributes.map((attribute) {
                      final selected = draft.attributeOptionIds.putIfAbsent(attribute.id, () => <int>{});
                      return _FullFilterSection(
                        title: attribute.name,
                        subtitle: selected.isEmpty ? 'همه' : '${AppFunction.faDigit(selected.length)} مورد انتخاب شده',
                        child: isColorAttribute(attribute)
                            ? ColorOptionsCardsWidget(
                          options: attribute.options,
                          selectedIds: selected,
                          onToggle: (option) {
                            toggleId(selected, option.id);
                            _changed();
                          },
                        )
                            : Column(
                          children: attribute.options
                              .map((option) {
                            return CheckboxListTile(
                              value: selected.contains(option.id),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              title: Text(option.name),
                              onChanged: (_) {
                                toggleId(selected, option.id);
                                _changed();
                              },
                            );
                          })
                              .toList(growable: false),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SheetFooterView(
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
        children: [child],
      ),
    );
  }
}

class _InlinePriceFilter extends StatefulWidget {
  const _InlinePriceFilter({required this.floor, required this.ceiling, required this.minValue, required this.maxValue, required this.onChanged});

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
        children: [
          Row(
            children: [
              Expanded(
                child: PriceLabel(label: 'از', value: values.start.round()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PriceLabel(label: 'تا', value: values.end.round()),
              ),
            ],
          ),
          RangeSlider(
            min: widget.floor.toDouble(),
            max: ceiling,
            values: values,
            activeColor: AppColors.accent,
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
