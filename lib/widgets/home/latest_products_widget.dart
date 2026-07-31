import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/cards/product_horizontal_card_widget.dart';
import 'package:yad_sys/widgets/cards/view_all_widget.dart';

class LatestProductsWidget extends StatelessWidget {
  const LatestProductsWidget({super.key, required this.section, required this.products});

  final SectionModel section;
  final List<ProductCardModel> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    final rows = section.layout.rows.clamp(1, 3).toInt();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = (screenWidth * 0.025).clamp(8.0, 12.0).toDouble();
    final verticalPadding = (screenWidth * 0.025).clamp(8.0, 12.0).toDouble();
    final spacing = (screenWidth * 0.01).clamp(7.0, 12.0).toDouble();
    final cardWidth = (screenWidth * 0.72).clamp(250.0, 420.0).toDouble();
    final cardHeight = (cardWidth * 0.3).clamp(125.0, 225.0).toDouble();
    final contentHeight = (cardHeight * rows) + (spacing * (rows - 1));
    final sectionHeight = contentHeight + (verticalPadding * 2);
    final columnCount = (products.length / rows).ceil();
    final gridWidth = (horizontalPadding * 2) + (columnCount * cardWidth) + (math.max(0, columnCount - 1) * spacing);
    final viewAll = section.viewAll;
    final viewAllWidth = (screenWidth * 0.28).clamp(110.0, 150.0).toDouble();

    return SizedBox(
      width: double.infinity,
      height: sectionHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
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
                  return ProductHorizontalCardWidget(product: products[index]);
                },
              ),
            ),
            if (viewAll != null) ...[
              SizedBox(
                width: viewAllWidth,
                height: contentHeight,
                child: ViewAllWidget(
                  title: viewAll.title,
                  onTap: () => SectionActionHandler.handle(context: context, action: viewAll.action),
                ),
              ),
              SizedBox(width: horizontalPadding),
            ],
          ],
        ),
      ),
    );
  }
}
