import 'package:flutter/material.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/app_function.dart';

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
    final normalized = query.trim().toLowerCase();
    final visible = normalized.isEmpty ? widget.brands : widget.brands.where((brand) => brand.name.toLowerCase().contains(normalized)).toList(growable: false);

    return Column(
      children: [
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
            separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xffeeeeee)),
            itemBuilder: (context, index) {
              final brand = visible[index];
              final checked = widget.selectedIds.contains(brand.id);
              return CheckboxListTile(
                value: checked,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(brand.name),
                subtitle: brand.count > 0 ? Text('${AppFunction.faDigit(brand.count)} کالا') : null,
                onChanged: (value) => widget.onChanged(brand, value == true),
              );
            },
          ),
        ),
      ],
    );
  }
}
