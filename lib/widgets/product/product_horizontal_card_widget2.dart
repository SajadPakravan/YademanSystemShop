import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/product/price_view_widget.dart';

class ShopProductCard extends StatelessWidget {
  ShopProductCard({super.key, required this.product});

  final ProductCardModel product;
  final Color _accent = Color(0xffe6123f);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final displayName = product.discountPercent > 0 && product.variationName!.isNotEmpty ? '${product.name} | ${product.variationName!}' : product.name;
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => toProduct(id: product.id),
        child: Container(
          height: screenHeight * 0.2,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xffeeeeee))),
          ),
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 145,
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (_, _, _) => const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.black26)),
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (product.discountPercent > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xfffff0f3), borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            'فروش ویژه',
                            style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    Text(
                      displayName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.8, fontWeight: FontWeight.w500, color: Color(0xff333333)),
                    ),
                    if (product.stockQuantity > 0 && product.stockQuantity <= 3)
                      Text(
                        '${AppFunction.faDigit(product.stockQuantity)} عدد در انبار باقی مانده',
                        style: TextStyle(color: _accent, fontSize: 11.5, fontWeight: FontWeight.w600),
                      )
                    else if (product.stockQuantity > 0)
                      const Text('موجود در انبار', style: TextStyle(color: Colors.black45, fontSize: 11.5)),
                    const Spacer(),
                    if (product.inquiry)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        decoration: BoxDecoration(color: const Color(0xffeef5fd), borderRadius: BorderRadius.circular(9)),
                        child: const Text(
                          'استعلام قیمت و موجودی',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xff0353a4), fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      )
                    else
                      PriceViewWidget(product: product),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
