import 'package:flutter/material.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/widgets/home/discounted_products_widget.dart';
import 'package:yad_sys/widgets/home/latest_products_widget.dart';
import 'package:yad_sys/widgets/home/section_header.dart';
import 'package:yad_sys/widgets/product/product_carousel.dart';

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
          if (isLatest) LatestProductsWidget(section: section, products: products) else ProductCarousel(section: section, products: products),
        ],
      );
    }
  }
}
