import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yad_sys/models/product/product_item_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/dialogs/product_consulta.dart';
import 'package:yad_sys/widgets/net_image.dart';
import 'package:yad_sys/widgets/product/price_view_widget.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ProductRowCard extends StatelessWidget {
  const ProductRowCard({super.key, required this.product, required this.rows, required this.length, required this.index});

  final ProductItemModel product;
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
          decoration: BoxDecoration(
            border: Border.all(color: context.appColors.divider),
            borderRadius: _borderRadius,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;
              final maxWidth = constraints.maxWidth;
              final imageHeight = math.min(maxHeight.isFinite ? maxHeight * 0.6 : maxWidth * 1, maxWidth * 1).clamp(110.0, 150.0).toDouble();

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: r.space(10),
                children: [
                  NetImage(imageUrl: product.image, width: imageHeight, height: imageHeight),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: r.space(10),
                      children: [
                        AppText.bodyMedium(
                          _displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                          height: 1.45,
                        ),
                        if (product.inquiry)
                          InkWell(
                            onTap: () => ProductConsulta.show(context: context, name: _displayName, image: product.image),
                            child: Container(
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
                            ),
                          )
                        else
                          PriceViewWidget(product: product),
                      ],
                    ),
                  ),
                ],
              );
            },
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
