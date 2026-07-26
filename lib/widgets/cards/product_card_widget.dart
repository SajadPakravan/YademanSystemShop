import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/tools/go_page.dart';

class ProductCardWidget extends StatelessWidget {
  const ProductCardWidget({super.key, required this.product});

  final ProductCardModel product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: product.id > 0 ? () => toProduct(id: product.id) : null,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined, color: Colors.black26, size: 56),
                      ),
                    ),
                    if (product.discountPercent > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            '${product.discountPercent.toString().toPersianDigit()}٪',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
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
                _PriceView(product: product),
            ],
          ),
        ),
      ),
    );
  }

  String get _displayName {
    final variation = product.variationName?.trim() ?? '';
    return variation.isEmpty ? product.name : '${product.name} | $variation';
  }
}

class _PriceView extends StatelessWidget {
  const _PriceView({required this.product});

  final ProductCardModel product;

  @override
  Widget build(BuildContext context) {
    final currentPrice = _formatPrice(product.price);
    final regularPrice = _formatPrice(product.regularPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (product.discountPercent > 0)
          Text(
            regularPrice,
            maxLines: 1,
            style: const TextStyle(color: Colors.black38, fontSize: 11, decoration: TextDecoration.lineThrough),
          ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                currentPrice,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 4),
            const Text('تومان', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    );
  }

  String _formatPrice(int? value) {
    return value.toString().toPersianDigit().seRagham();
  }
}
