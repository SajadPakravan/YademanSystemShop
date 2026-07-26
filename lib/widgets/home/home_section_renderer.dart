import 'package:flutter/material.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/widgets/home/image_section.dart';
import 'package:yad_sys/widgets/home/home_brand_section.dart';
import 'package:yad_sys/widgets/home/home_category_section.dart';
import 'package:yad_sys/widgets/home/products_section.dart';

class HomeSectionRenderer extends StatelessWidget {
  const HomeSectionRenderer({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    switch (section.type) {
      case 'image':
        return ImageSection(section: section);
      case 'products':
        return ProductsSection(section: section);
      case 'category':
        return HomeCategorySection(section: section);
      case 'brand':
        return HomeBrandSection(section: section);
      default:
        return const SizedBox.shrink();
    }
  }
}
