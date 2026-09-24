import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/product_detail_model.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/cards/view_all_widget.dart';
import 'package:yad_sys/widgets/product/product_column_card.dart';

class RelatedProductCard extends StatelessWidget {
  const RelatedProductCard({super.key, required this.list, this.onProductTap});

  final List<RelatedProduct> list;
  final ValueChanged<int>? onProductTap;

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
                      ProductColumnCard(
                        product: products[index],
                        rows: metrics.rows,
                        length: products.length,
                        index: index,
                        onTap: onProductTap == null ? null : () => onProductTap!(products[index].id),
                      ),
                ),
              ),
            if (viewAll != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: metrics.verticalPadding),
                child: SizedBox(
                  width: metrics.viewAllWidth,
                  height: metrics.contentHeight,
                  child: ViewAllWidget(
                    title: viewAll.title,
                    onTap: () => SectionActionHandler.openShop(context: context, action: viewAll!.action),
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
