import 'package:flutter/material.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/app_colors.dart';

class ColorOptionsCardsWidget extends StatelessWidget {
  const ColorOptionsCardsWidget({super.key, required this.options, required this.selectedIds, required this.onToggle});

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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, mainAxisExtent: 96, crossAxisSpacing: 10, mainAxisSpacing: 10),
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
                  color: selected ? AppColors.activeChipBackground : Colors.white,
                  border: Border.all(color: selected ? AppColors.accent : const Color(0xffe0e0e0), width: selected ? 1.4 : 1),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: color,
                          border: Border.all(color: color == Colors.white ? const Color(0xffdedede) : Colors.transparent),
                        ),
                        child: selected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black87,
                                size: 22,
                              )
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
  return const Color(0xff90a4ae);
}
