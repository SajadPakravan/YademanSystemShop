import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/cards/view_all_widget.dart';
import 'package:yad_sys/widgets/product/product_horizontal_card.dart';

class LatestProductsWidget extends StatelessWidget {
  const LatestProductsWidget({super.key, required this.section, required this.products});

  final SectionModel section;
  final List<ProductCardModel> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final metrics = HorizontalGridMetrics.horizontalProducts(context, rows: section.layout.rows, itemCount: products.length);
    final viewAll = section.viewAll;

    return SizedBox(
      width: double.infinity,
      height: metrics.sectionHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: metrics.gridWidth * 1.2,
              height: metrics.sectionHeight,
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: metrics.horizontalPadding, vertical: metrics.verticalPadding),
                physics: const NeverScrollableScrollPhysics(),
                primary: false,
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: metrics.rows,
                  mainAxisSpacing: metrics.spacing,
                  crossAxisSpacing: metrics.spacing,
                  mainAxisExtent: metrics.cardWidth * 1.2,
                ),
                itemBuilder: (context, index) =>
                    ProductHorizontalCard(product: products[index], rows: metrics.rows, length: products.length, index: index),
              ),
            ),
            if (viewAll != null) ...[
              SizedBox(
                width: metrics.viewAllWidth,
                height: metrics.contentHeight,
                child: ViewAllWidget(
                  title: viewAll.title,
                  onTap: () => SectionActionHandler.openShop(context: context, action: viewAll.action),
                ),
              ),
              SizedBox(width: metrics.horizontalPadding),
            ],
          ],
        ),
      ),
    );
  }
}
