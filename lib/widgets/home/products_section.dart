import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/widgets/cards/product_card_widget.dart';
import 'package:yad_sys/widgets/home/discounted_products_widget.dart';
import 'package:yad_sys/widgets/home/section_header.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final products = section.products;
    if (products.isEmpty) return const SizedBox.shrink();

    if (section.id == 'amazing_offers') {
      return DiscountedProductsWidget(
        section: section,
        products: products,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Column(
        children: [
          SectionHeader(section: section),
          if (section.layout.isHorizontal)
            _ProductCarousel(section: section, products: products)
          else
            _ProductGrid(section: section, products: products),
        ],
      ),
    );
  }
}

class _ProductCarousel extends StatelessWidget {
  const _ProductCarousel({required this.section, required this.products});

  final SectionModel section;
  final List<ProductCardModel> products;

  @override
  Widget build(BuildContext context) {
    final rows = section.layout.rows.clamp(1, 3).toInt();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth * 0.46).clamp(168.0, 220.0).toDouble();
    const cardHeight = 304.0;

    return SizedBox(
      height: (cardHeight * rows) + ((rows - 1) * 10),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rows,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: cardWidth,
        ),
        itemBuilder: (context, index) => ProductCardWidget(
          product: products[index],
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.section, required this.products});

  final SectionModel section;
  final List<ProductCardModel> products;

  @override
  Widget build(BuildContext context) {
    final columns = section.layout.columns.clamp(1, 4).toInt();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 304,
      ),
      itemBuilder: (context, index) => ProductCardWidget(
        product: products[index],
      ),
    );
  }
}
