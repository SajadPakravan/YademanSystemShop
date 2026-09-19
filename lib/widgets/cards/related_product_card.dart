import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/product_detail_model.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/cards/view_all_widget.dart';
import 'package:yad_sys/widgets/product/product_vertical_card_widget.dart';

class RelatedProductCard extends StatelessWidget {
  const RelatedProductCard({super.key, required this.list});

  final List<RelatedProduct> list;

  @override
  Widget build(BuildContext context) {
    const rows = 1;
    final products = <ProductCardModel>[];
    ProductDetailViewAll? viewAll;

    for (final item in list) {
      products.addAll(item.data);
      viewAll ??= item.viewAll;
    }

    if (products.isEmpty && viewAll == null) return const SizedBox.shrink();

    final metrics = HorizontalGridMetrics.verticalProducts(context, rows: rows, itemCount: products.length);

    return SizedBox(
      width: double.infinity,
      height: metrics.sectionHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (products.isNotEmpty)
              SizedBox(
                width: metrics.gridWidth,
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
                    mainAxisExtent: metrics.cardWidth,
                  ),
                  itemBuilder: (context, index) =>
                      ProductVerticalCardWidget(product: products[index], rows: metrics.rows, length: products.length, index: index),
                ),
              ),
            if (viewAll != null && products.length > 10) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: metrics.verticalPadding),
                child: SizedBox(
                  width: metrics.viewAllWidth,
                  height: metrics.contentHeight,
                  child: ViewAllWidget(
                    title: viewAll.title,
                    onTap: () => SectionActionHandler.handle(context: context, action: viewAll!.action),
                  ),
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
