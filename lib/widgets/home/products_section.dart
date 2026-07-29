import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/cards/view_all_widget.dart';
import 'package:yad_sys/widgets/home/discounted_products_widget.dart';
import 'package:yad_sys/widgets/home/latest_products_widget.dart';
import 'package:yad_sys/widgets/home/section_header.dart';

import '../cards/product_card_widget.dart';

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
          if (isLatest) LatestProductsWidget(section: section, products: products) else _ProductCarousel(section: section, products: products),
        ],
      );
    }
  }
}

class _ProductCarousel extends StatelessWidget {
  const _ProductCarousel({required this.section, required this.products});

  final SectionModel section;
  final List<ProductCardModel> products;
  static const double _cardHeight = 300;
  static const double _verticalPadding = 20;
  static const double _rowSpacing = 10;
  static const double _mainAxisSpacing = 3;
  static const double _horizontalPadding = 20;

  @override
  Widget build(BuildContext context) {
    final rows = section.layout.rows.clamp(1, 3).toInt();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth * 0.35).clamp(150.0, 220.0).toDouble();
    final contentHeight = (_cardHeight * rows) + (_rowSpacing * (rows - 1));
    final hasViewAll = section.viewAll != null;
    final itemCount = products.length + (hasViewAll ? 1 : 0);

    return Container(
      width: double.infinity,
      height: contentHeight + (_verticalPadding * 2),
      padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rows,
          mainAxisSpacing: _mainAxisSpacing,
          crossAxisSpacing: _rowSpacing,
          mainAxisExtent: cardWidth,
        ),
        itemBuilder: (context, index) {
          if (index < products.length) {
            return ProductCardWidget(product: products[index], length: products.length, index: index);
          }

          final viewAll = section.viewAll!;

          return ViewAllWidget(
            title: viewAll.title,
            onTap: () => SectionActionHandler.handle(context: context, action: viewAll.action),
          );
        },
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
    final columns = section.layout.columns;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 304),
      itemBuilder: (context, index) => ProductCardWidget(product: products[index], length: products.length, index: index),
    );
  }
}
