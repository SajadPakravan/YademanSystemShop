import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/widgets/product/price_view_widget.dart';

class ProductHorizontalCardWidget extends StatelessWidget {
  const ProductHorizontalCardWidget({super.key, required this.product, required this.rows, required this.length, required this.index});

  final ProductCardModel product;
  final int rows;
  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        final padding = (cardWidth * 0.035).clamp(8.0, 13.0).toDouble();
        final gap = (cardWidth * 0.028).clamp(7.0, 12.0).toDouble();
        final titleFontSize = (cardWidth * 0.05).clamp(12.0, 15.0).toDouble();
        final inquiryFontSize = (cardWidth * 0.042).clamp(10.5, 12.5).toDouble();
        final inquiryVerticalPadding = (cardHeight * 0.05).clamp(7.0, 10.0).toDouble();

        return InkWell(
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: _borderRadius,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 44,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: (cardHeight * 0.025).clamp(2.0, 5.0).toDouble()),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      height: double.infinity,
                      imageUrl: product.image,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(child: SizedBox(width: 23, height: 23, child: CircularProgressIndicator(strokeWidth: 2))),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.black26, size: 46)),
                    ),
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  flex: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: titleFontSize, height: 1.45, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: (cardHeight * 0.045).clamp(6.0, 10.0).toDouble()),
                      if (product.inquiry)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: inquiryVerticalPadding),
                          decoration: BoxDecoration(color: const Color(0xffeef5fd), borderRadius: BorderRadius.circular(9)),
                          child: Text(
                            'استعلام قیمت و موجودی',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: const Color(0xff0353a4), fontSize: inquiryFontSize, fontWeight: FontWeight.bold),
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
        );
      },
    );
  }

  BorderRadius get _borderRadius {
    int i = index + 1;

    if (rows > 1) {
      if (i <= rows) {
        if (i == 1) {
          return const BorderRadius.only(topRight: Radius.circular(12));
        }
        if (rows - i == 0) {
          return const BorderRadius.only(bottomRight: Radius.circular(12));
        }
      }

      if (i >= length - (rows - 1)) {
        if (i - (length - (rows - 1)) == 0) {
          return const BorderRadius.only(topLeft: Radius.circular(12));
        } else if(i == length) {
          return const BorderRadius.only(bottomLeft: Radius.circular(12));
        }
      }
    } else {
      if (i == 1) {
        return const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12));
      }
      if (i == length) {
        return const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12));
      }
    }

    return BorderRadius.zero;
  }

  String get _displayName {
    final variation = product.variationName?.trim() ?? '';
    return variation.isEmpty ? product.name : '${product.name} | $variation';
  }
}
