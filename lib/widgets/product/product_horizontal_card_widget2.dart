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
    final displayName = product.discountPercent > 0 && product.variationName.isNotEmpty ? '${product.name} | ${product.variationName}' : product.name;

    double cardSize() {
      if(product.inquiry){
        if (product.colors.isNotEmpty || product.averageRating != '0.0') return screenHeight * 0.21;
      }
      if (product.discountPercent > 0) {
        if (product.colors.isEmpty && product.averageRating == '0.0') return screenHeight * 0.23;
        return screenHeight * 0.25;
      }
      if (product.colors.isNotEmpty || product.averageRating != '0.0') return screenHeight * 0.2;
      return screenHeight * 0.18;
    }

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => toProduct(id: product.id),
        child: Container(
          height: cardSize(),
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
                  spacing: 10,
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
                    Row(
                      spacing: 5,
                      children: [
                        ratingBar(),
                        Expanded(child: colorBar()),
                      ],
                    ),
                    if (product.stockQuantity > 0 && product.stockQuantity <= 3)
                      Text(
                        '${AppFunction.faDigit(product.stockQuantity)} عدد در انبار باقی مانده',
                        style: TextStyle(color: _accent, fontSize: 11.5, fontWeight: FontWeight.w600),
                      )
                    else if (product.stockQuantity > 0)
                      const Text('موجود در انبار', style: TextStyle(color: Colors.black45, fontSize: 11.5)),
                    if (product.inquiry) ...[
                      SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        decoration: BoxDecoration(color: const Color(0xffeef5fd), borderRadius: BorderRadius.circular(9)),
                        child: const Text(
                          'استعلام قیمت و موجودی',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xff0353a4), fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: 10),
                      PriceViewWidget(product: product),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ratingBar() {
    if (product.averageRating == '0.0') return SizedBox.shrink();
    return Row(
      children: [
        Icon(Icons.star_rounded, color: Colors.yellow.shade700),
        Text(AppFunction.faDigit(product.averageRating), style: TextStyle(color: Color(0xff333333), fontSize: 14)),
      ],
    );
  }

  Widget colorBar() {
    if (product.colors.isEmpty) return SizedBox.shrink();
    return SizedBox(
      height: 20,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: product.colors.length,
        itemExtent: 25,
        itemBuilder: (context, index) {
          final color = product.colors[index];
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorHex(color),
              border: Border.all(color: Colors.grey.shade500),
            ),
          );
        },
      ),
    );
  }

  Color colorHex(String color) {
    final hex = color.replaceFirst('#', '');
    if (hex.length == 6) {
      final value = int.tryParse('FF$hex', radix: 16);
      if (value != null) return Color(value);
    }
    if (hex.length == 8) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) return Color(value);
    }
    return const Color(0xff90a4ae);
  }
}
