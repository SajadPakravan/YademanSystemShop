import 'package:flutter/material.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ColorOptionsCardsWidget extends StatelessWidget {
  const ColorOptionsCardsWidget({super.key, required this.options, required this.selectedIds, required this.onToggle});

  final List<ProductAttributeOptionModel> options;
  final Set<int> selectedIds;
  final ValueChanged<ProductAttributeOptionModel> onToggle;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final columns = r.width < 360 ? 3 : (r.isTablet ? 5 : 4);

    return GridView.builder(
      padding: EdgeInsets.all(r.space(12)),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: r.space(96, min: 90, max: 112),
        crossAxisSpacing: r.space(10),
        mainAxisSpacing: r.space(10),
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final selected = selectedIds.contains(option.id);
        final color = _colorForOption(option);

        return InkWell(
          borderRadius: BorderRadius.circular(r.radius(14)),
          onTap: () => onToggle(option),
          child: Container(
            padding: EdgeInsets.all(r.space(7)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r.radius(14)),
              color: selected ? colors.chipActiveBackground : colors.surface,
              border: Border.all(color: selected ? AppColors.accent : colors.border, width: selected ? 1.4 : 1),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(r.radius(10)),
                      color: color,
                      border: Border.all(color: color == AppColors.onBrand ? colors.border : AppColors.transparent),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? AppColors.onBrand : AppColors.shadow,
                            size: r.icon(22),
                          )
                        : null,
                  ),
                ),
                SizedBox(height: r.space(5)),
                AppText.bodySmall(option.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              ],
            ),
          ),
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
  return AppColors.neutralOption;
}
