import 'package:flutter/material.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/sections/category_section.dart';
import 'package:yad_sys/widgets/sections/image_section.dart';
import 'package:yad_sys/widgets/sections/products_section.dart';

class CategoriesSectionRenderer extends StatelessWidget {
  const CategoriesSectionRenderer({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Padding(
      padding: EdgeInsets.only(bottom: r.sectionVerticalGap),
      child: section.type != 'image'
          ? Container(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.symmetric(horizontal: BorderSide(color: colors.divider)),
              ),
              child: content(),
            )
          : content(),
    );
  }

  Widget content() {
    switch (section.type) {
      case 'image':
        return ImageSection(section: section);
      case 'products':
        return ProductsSection(section: section);
      default:
        return CategorySection(section: section);
    }
  }
}
