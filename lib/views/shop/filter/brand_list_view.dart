import 'package:flutter/material.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class BrandListView extends StatefulWidget {
  const BrandListView({super.key, required this.brands, required this.selectedIds, required this.onChanged});

  final List<ProductBrandFilterModel> brands;
  final Set<int> selectedIds;
  final void Function(ProductBrandFilterModel brand, bool selected) onChanged;

  @override
  State<BrandListView> createState() => _BrandListViewState();
}

class _BrandListViewState extends State<BrandListView> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final normalized = query.trim().toLowerCase();
    final visible = normalized.isEmpty ? widget.brands : widget.brands.where((brand) => brand.name.toLowerCase().contains(normalized)).toList(growable: false);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(10), r.pageHorizontalPadding, r.space(8)),
          child: TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(hintText: 'جستجوی نام برند', prefixIcon: Icon(Icons.search_rounded), isDense: true),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: visible.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final brand = visible[index];
              final checked = widget.selectedIds.contains(brand.id);
              return CheckboxListTile(
                value: checked,
                controlAffinity: ListTileControlAffinity.leading,
                title: AppText.bodyMedium(brand.name),
                subtitle: brand.count > 0 ? AppText.bodySmall('${AppFunction.faDigit(brand.count)} کالا', color: context.appColors.textMuted) : null,
                onChanged: (value) => widget.onChanged(brand, value == true),
              );
            },
          ),
        ),
      ],
    );
  }
}
