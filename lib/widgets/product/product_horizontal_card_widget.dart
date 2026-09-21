import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/product/price_view_widget.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ProductHorizontalCardWidget extends StatelessWidget {
  const ProductHorizontalCardWidget({super.key, required this.product, required this.rows, required this.length, required this.index});

  final ProductCardModel product;
  final int rows;
  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Material(
      color: colors.surface,
      borderRadius: _borderRadius,
      child: InkWell(
        borderRadius: _borderRadius,
        onTap: () => toProduct(id: product.id),
        child: Container(
          padding: EdgeInsets.all(r.space(10, min: 8, max: 13)),
          decoration: BoxDecoration(border:Border.all(color: context.appColors.divider),borderRadius: _borderRadius),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 44,
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: SizedBox(width: 23, height: 23, child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (context, url, error) => Center(child: Icon(Icons.broken_image_outlined, color: colors.textMuted, size: r.icon(44))),
                ),
              ),
              SizedBox(width: r.space(5, min: 5, max: 10)),
              Expanded(
                flex: 56,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText.bodyMedium(
                      _displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                      height: 1.45,
                    ),
                    SizedBox(height: r.space(8, min: 6, max: 10)),
                    if (product.inquiry)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: r.space(8), vertical: r.space(8, min: 7, max: 10)),
                        decoration: BoxDecoration(color: colors.inquiryBackground, borderRadius: BorderRadius.circular(r.radius(9))),
                        child: AppText.labelSmall(
                          'استعلام قیمت و موجودی',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: colors.inquiryForeground,
                          fontWeight: FontWeight.bold,
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

  BorderRadius get _borderRadius {
    final i = index + 1;
    if (rows > 1) {
      if (i <= rows) {
        if (i == 1) return const BorderRadius.only(topRight: Radius.circular(12));
        if (rows - i == 0) return const BorderRadius.only(bottomRight: Radius.circular(12));
      }
      if (i >= length - (rows - 1)) {
        if (i - (length - (rows - 1)) == 0) return const BorderRadius.only(topLeft: Radius.circular(12));
        if (i == length) return const BorderRadius.only(bottomLeft: Radius.circular(12));
      }
    } else {
      if (i == 1) return const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12));
      if (i == length) return const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12));
    }
    return BorderRadius.zero;
  }

  String get _displayName {
    final variation = product.variationName.trim();
    return variation.isEmpty ? product.name : '${product.name} | $variation';
  }
}
