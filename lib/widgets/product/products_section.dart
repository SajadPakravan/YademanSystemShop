import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/cards/view_all_widget.dart';
import 'package:yad_sys/widgets/home/discounted_products_widget.dart';
import 'package:yad_sys/widgets/home/latest_products_widget.dart';
import 'package:yad_sys/widgets/home/section_header.dart';
import 'package:yad_sys/widgets/product/product_carousel_widget.dart';

import 'product_vertical_card_widget.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final products = section.products;
    if (products.isEmpty) return const SizedBox.shrink();

    final isAmazing = section.id == 'amazing_offers';
    final isLatest = section.id == 'latest_products';

    if (isAmazing) {
      return DiscountedProductsWidget(section: section, products: products);
    } else {
      return Column(
        children: [
          SectionHeader(section: section),
          if (isLatest) LatestProductsWidget(section: section, products: products) else ProductCarouselWidget(section: section, products: products),
        ],
      );
    }
  }
}
