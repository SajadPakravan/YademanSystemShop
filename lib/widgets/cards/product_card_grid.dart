import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/models/product_variable_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class ProductCardGrid extends StatelessWidget {
  ProductCardGrid({
    super.key,
    this.physics = const AlwaysScrollableScrollPhysics(),
    required this.productsLst,
    required this.productVariableLst,
  });

  final AppFunction appFun = AppFunction();
  final ScrollPhysics physics;
  final List<ProductModel> productsLst;
  final List<ProductVariableModel> productVariableLst;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final columns = r.isTablet ? 3 : 2;
    final itemExtent = r.isTablet ? r.space(330, min: 310, max: 380) : r.space(280, min: 260, max: 315);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: r.space(10),
          crossAxisSpacing: r.space(6),
          crossAxisCount: columns,
          mainAxisExtent: itemExtent,
        ),
        padding: EdgeInsets.symmetric(horizontal: r.space(6), vertical: r.space(4)),
        itemCount: productsLst.length,
        physics: physics,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          final product = productsLst[index];
          final img = product.images![0];

          String variableName = '';
          int price = int.parse(product.price!);
          int regularPrice = int.tryParse(product.regularPrice ?? '') ?? 0;
          int percent = 0;
          String toman = ' تومان';
          Color textColor = colors.textPrimary;
          double fontSize = 14;

          if (product.type == 'variable') {
            for (final productVariable in productVariableLst) {
              if (productVariable.parentId == product.id && productVariable.onSale == true) {
                price = int.parse(productVariable.price!);
                regularPrice = int.parse(productVariable.regularPrice!);
                variableName = ' | ${productVariable.name!}';
              }
            }
          }

          if (product.onSale == true) {
            textColor = colors.textMuted;
            fontSize = 12;
            toman = '';
            if (regularPrice > 0) {
              percent = (((price - regularPrice) / regularPrice) * 100).roundToDouble().toInt();
            }
          }

          return Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(r.cardRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => toProduct(id: product.id),
              child: Container(
                padding: EdgeInsets.all(r.space(10)),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(r.cardRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: r.space(5)),
                        child: CachedNetworkImage(
                          imageUrl: img.src!,
                          fit: BoxFit.contain,
                          errorWidget: (context, str, dyn) => Icon(Icons.image_outlined, color: colors.textMuted, size: r.icon(72)),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.symmetric(vertical: r.space(9)),
                      child: TextBodyMediumView('${product.name!}$variableName', maxLines: 2),
                    ),
                    if (price == 0)
                      const TextBodyMediumView('تماس بگیرید', textAlign: TextAlign.center, maxLines: 2)
                    else
                      Row(
                        children: [
                          if (product.onSale == true)
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: r.space(6), vertical: r.space(4)),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(r.radius(7)),
                              ),
                              child: TextBodyMediumView(
                                '${percent.toString().replaceAll('-', '').toPersianDigit()}%',
                                color: AppColors.onBrand,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (product.onSale == true) SizedBox(width: r.space(6)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (product.onSale == true) ...[
                                  TextBodyMediumView(
                                    price.toString().toPersianDigit().seRagham(),
                                    textAlign: TextAlign.left,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const TextBodyMediumView('تومان', fontWeight: FontWeight.bold),
                                  SizedBox(height: r.space(4)),
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: TextBodyMediumView(
                                        price.toString().toPersianDigit().seRagham(),
                                        textAlign: TextAlign.left,
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontSize,
                                        color: textColor,
                                      ),
                                    ),
                                    TextBodyMediumView(toman, fontWeight: FontWeight.bold, color: textColor),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
