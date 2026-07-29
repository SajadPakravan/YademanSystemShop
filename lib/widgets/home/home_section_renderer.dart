import 'package:flutter/material.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/widgets/home/image_section.dart';
import 'package:yad_sys/widgets/home/home_brand_section.dart';
import 'package:yad_sys/widgets/home/category_section.dart';
import 'package:yad_sys/widgets/home/products_section.dart';

class HomeSectionRenderer extends StatelessWidget {
  const HomeSectionRenderer({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 15),
      child: section.type != 'image'
          ? Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: BoxBorder.symmetric(horizontal: BorderSide(color: Colors.grey.shade400)),
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
      case 'category':
        return CategorySection(section: section);
      case 'brand':
        return HomeBrandSection(section: section);
      default:
        return const SizedBox.shrink();
    }
  }
}
