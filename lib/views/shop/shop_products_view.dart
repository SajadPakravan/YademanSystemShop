import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/product/shop_product_row_card.dart';
import 'package:yad_sys/widgets/product/product_column_card.dart';

class ShopProductsView extends StatelessWidget {
  const ShopProductsView({super.key, required this.products, required this.isGrid});

  final List<ProductCardModel> products;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    if (isGrid) {
      return SliverPadding(
        padding: EdgeInsets.all(r.space(10)),
        sliver: SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: r.width > 800 ? 3 : 2,
            crossAxisSpacing: r.space(5),
            mainAxisSpacing: r.space(5),
            childAspectRatio: r.height < 900 ? 0.6 : 0.65,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductColumnCard(product: products[index], length: products.length, index: index, simpleRadius: false);
          },
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: products.length, (context, index) {
        return ShopProductRowCard(product: products[index]);
      }),
    );
  }
}
