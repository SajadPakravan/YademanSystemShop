import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/product/product_vertical_card_widget.dart';
import 'package:yad_sys/widgets/cards/view_all_widget.dart';

class ProductCarouselWidget extends StatelessWidget {
  const ProductCarouselWidget({super.key, required this.section, required this.products});

  final SectionModel section;
  final List<ProductCardModel> products;

  @override
  Widget build(BuildContext context) {
    final rows = section.layout.rows.clamp(1, 3).toInt();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = (screenWidth * 0.025).clamp(8.0, 12.0).toDouble();
    final verticalPadding = (screenWidth * 0.025).clamp(8.0, 12.0).toDouble();
    final spacing = (screenWidth * 0.005).clamp(3.0, 12.0).toDouble();
    final cardWidth = (screenWidth * 0.35).clamp(150.0, 220.0).toDouble();
    final cardHeight = (cardWidth * 1.7).clamp(200.0, 300.0).toDouble();
    final contentHeight = (cardHeight * rows) + (spacing * (rows - 1));
    final sectionHeight = contentHeight + (verticalPadding * 2);
    final columnCount = (products.length / rows).ceil();
    final gridWidth = (horizontalPadding * 2) + (columnCount * cardWidth) + (math.max(0, columnCount - 1) * spacing);
    final viewAll = section.viewAll;
    final viewAllWidth = (screenWidth * 0.28).clamp(110.0, 150.0).toDouble();

    return Container(
      width: double.infinity,
      height: sectionHeight,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: gridWidth,
              height: sectionHeight,
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                  return ProductVerticalCardWidget(product: products[index], rows: rows, length: products.length, index: index);
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
