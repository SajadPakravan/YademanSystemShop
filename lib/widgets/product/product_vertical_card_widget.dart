import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/product/price_view_widget.dart';

class ProductVerticalCardWidget extends StatelessWidget {
  const ProductVerticalCardWidget({super.key, required this.product, required this.rows, required this.length, required this.index});

  final ProductCardModel product;
  final int rows;
  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => toProduct(id: product.id),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: _borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.black26, size: 56)),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(_displayName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, height: 1.45)),
            const SizedBox(height: 8),
            if (product.inquiry)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xffeef5fd), borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  'استعلام قیمت و موجودی',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xff0353a4), fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              )
            else
              PriceViewWidget(product: product),
          ],
        ),
      ),
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
