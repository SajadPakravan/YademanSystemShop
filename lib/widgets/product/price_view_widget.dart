import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class PriceViewWidget extends StatelessWidget {
  const PriceViewWidget({super.key, required this.product});

  final ProductCardModel product;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
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
                padding: EdgeInsets.symmetric(horizontal: r.space(9), vertical: r.space(3)),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(r.radius(50))),
                child: AppText.labelSmall('٪ ${AppFunction.faDigit(product.discountPercent)}', color: AppColors.onBrand, fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: AppText.labelSmall(
                  regularPrice,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: colors.textMuted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        SizedBox(height: r.space(2)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(child: AppText.bodyMedium(currentPrice, maxLines: 1, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold)),
            SizedBox(width: r.space(4)),
            const AppText.labelSmall('تومان'),
          ],
        ),
      ],
    );
  }

  String _formatPrice(int? value) => AppFunction.faPrice(value ?? 0);
}
