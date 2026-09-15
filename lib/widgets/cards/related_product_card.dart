import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/product_detail_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/cards/view_all_widget.dart';
import 'package:yad_sys/widgets/product/product_vertical_card_widget.dart';

class RelatedProductCard extends StatelessWidget {
  const RelatedProductCard({super.key, required this.list});

  final List<RelatedProduct> list;

  @override
  Widget build(BuildContext context) {
    const rows = 1;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = (screenWidth * 0.025).clamp(8.0, 12.0).toDouble();
    final verticalPadding = (screenWidth * 0.025).clamp(8.0, 12.0).toDouble();
    final spacing = (screenWidth * 0.005).clamp(3.0, 12.0).toDouble();
    final cardWidth = (screenWidth * 0.35).clamp(150.0, 220.0).toDouble();
    final cardHeight = (cardWidth * 1.7).clamp(200.0, 300.0).toDouble();
    final contentHeight = (cardHeight * rows) + (spacing * (rows - 1));
    final sectionHeight = contentHeight + (verticalPadding * 2);

    final products = <ProductCardModel>[];
    ProductDetailViewAll? viewAll;

    for (final item in list) {
      products.addAll(item.data);
      viewAll ??= item.viewAll;
    }

    final columnCount = (products.length / rows).ceil();
    final gridWidth = (horizontalPadding * 2) + (columnCount * cardWidth) + (math.max(0, columnCount - 1) * spacing);
    final viewAllWidth = (screenWidth * 0.28).clamp(110.0, 150.0).toDouble();

    if (products.isEmpty && viewAll == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: sectionHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (products.isNotEmpty)
              SizedBox(
                width: gridWidth,
                height: sectionHeight,
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                  physics: const NeverScrollableScrollPhysics(),
                  primary: false,
                  shrinkWrap: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rows,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    mainAxisExtent: cardWidth,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductVerticalCardWidget(product: product, rows: rows, length: products.length, index: index);
                  },
                ),
              ),
            if (viewAll != null && products.length > 10)
              Padding(
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                child: SizedBox(
                  width: viewAllWidth,
                  height: contentHeight,
                  child: ViewAllWidget(
                    title: viewAll.title,
                    onTap: () => SectionActionHandler.handle(context: context, action: viewAll!.action),
                  ),
                ),
              ),
            SizedBox(width: horizontalPadding),
          ],
        ),
      ),
    );
  }
}
