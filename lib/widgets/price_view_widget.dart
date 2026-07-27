import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_card_model.dart';

class PriceViewWidget extends StatelessWidget {
  const PriceViewWidget({super.key, required this.product});

  final ProductCardModel product;

  @override
  Widget build(BuildContext context) {
    final currentPrice = _formatPrice(product.price);
    final regularPrice = _formatPrice(product.regularPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (product.discountPercent > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(50)),
                child: Text(
                  '٪ ${product.discountPercent.toString().toPersianDigit()}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                regularPrice,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black38, fontSize: 11, decoration: TextDecoration.lineThrough),
              ),
            ],
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
    final safeValue = value ?? 0;
    return safeValue.toString().toPersianDigit().seRagham();
  }
}