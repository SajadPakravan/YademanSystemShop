import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class ProductCardGrid extends StatelessWidget {
  ProductCardGrid({super.key, this.physics = const AlwaysScrollableScrollPhysics(), required this.list});

  final AppFunction appFun = AppFunction();
  final ScrollPhysics physics;
  final List<ProductModel> list;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 10, crossAxisCount: 2, mainAxisExtent: 280),
        padding: EdgeInsets.zero,
        itemCount: list.length,
        scrollDirection: Axis.vertical,
        physics: physics,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (BuildContext context, int index) {
          ProductModel product = list[index];
          ProductImage img = product.images![0];

          int price = int.parse(product.price!);
          int regularPrice = int.parse(product.regularPrice!);
          int percent = 0;
          String toman = ' تومان';
          Color textColor = Colors.black87;
          double fontSize = 14;

          if (product.onSale!) {
            textColor = Colors.black45;
            fontSize = 12;
            toman = '';
            percent = (((price - regularPrice) / regularPrice) * 100).roundToDouble().toInt();
          }
          return InkWell(
            onTap: () => toProduct(product: product),
            child: Container(
              width: width * 0.45,
              height: height,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black54, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: CachedNetworkImage(
                        imageUrl: img.src!,
                        fit: BoxFit.contain,
                        errorWidget: (context, str, dyn) => const Icon(Icons.image, color: Colors.black26, size: 100),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: TextBodyMediumView(product.name!, maxLines: 2),
                  ),
                  price == 0
                      ? const TextBodyMediumView('تماس بگیرید', textAlign: TextAlign.center, maxLines: 2)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Visibility(
                              visible: product.onSale!,
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(color: Colors.red.shade600),
                                child: TextBodyMediumView(
                                  "${percent.toString().replaceAll('-', '').toPersianDigit()}%",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Visibility(
                                    visible: product.onSale!,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      margin: const EdgeInsets.only(bottom: 5),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextBodyMediumView(
                                            price.toString().toPersianDigit().seRagham(),
                                            textAlign: TextAlign.left,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          const TextBodyMediumView('تومان', fontWeight: FontWeight.bold),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextBodyMediumView(
                                          regularPrice.toString().toPersianDigit().seRagham(),
                                          textAlign: TextAlign.left,
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSize,
                                          color: textColor,
                                        ),
                                        TextBodyMediumView(toman, fontWeight: FontWeight.bold),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
