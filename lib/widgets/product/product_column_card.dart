import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/dialogs/product_consulta.dart';
import 'package:yad_sys/widgets/product/price_view_widget.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ProductColumnCard extends StatelessWidget {
  const ProductColumnCard({super.key, required this.product, this.rows = 1, required this.length, required this.index, this.onTap, this.simpleRadius = true});

  final ProductCardModel product;
  final int rows;
  final int length;
  final int index;
  final VoidCallback? onTap;
  final bool simpleRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Material(
      color: colors.surface,
      borderRadius: AppFunction.borderRadius(simpleRadius, index, rows, length),
      child: InkWell(
        borderRadius: AppFunction.borderRadius(simpleRadius, index, rows, length),
        onTap: onTap ?? () => toProduct(id: product.id),
        child: Container(
          padding: EdgeInsets.all(r.space(10)),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
            borderRadius: AppFunction.borderRadius(simpleRadius, index, rows, length),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;
              final maxWidth = constraints.maxWidth;
              final imageHeight = math.min(maxHeight.isFinite ? maxHeight * 0.6 : maxWidth * 1, maxWidth * 1).clamp(100.0, 150.0).toDouble();
              final titleHeight = r.space(42, min: 40, max: 46);

              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: r.space(15),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(r.radius(8)),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: imageHeight,
                          height: imageHeight,
                          child: CachedNetworkImage(
                            imageUrl: product.image,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(Icons.broken_image_outlined, color: colors.textMuted, size: r.icon(52)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: titleHeight,
                        child: Align(
                          alignment: AlignmentDirectional.topStart,
                          child: AppText.bodySmall(
                            _displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 13,
                            height: 1.45,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.bottomCenter,
                          child: product.inquiry
                              ? InkWell(
                                  onTap: () => ProductConsulta.show(context: context, name: _displayName, image: product.image),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(horizontal: r.space(8), vertical: r.space(8)),
                                    decoration: BoxDecoration(color: colors.inquiryBackground, borderRadius: BorderRadius.circular(r.radius(8))),
                                    child: AppText.labelSmall(
                                      'استعلام',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      color: colors.inquiryForeground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : PriceViewWidget(product: product),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: imageHeight - 10,
                    child: Row(
                      spacing: r.space(5),
                      children: [if (product.averageRating != '0.0') rating(context), if (product.colors.isNotEmpty) attributeColor(context)],
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

  String get _displayName {
    final variation = product.variationName.trim();
    return variation.isEmpty ? product.name : '${product.name} | $variation';
  }

  Widget rating(BuildContext context) {
    final r = context.responsive;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.space(5), vertical: r.space(2)),
      decoration: BoxDecoration(
        border: Border.all(color: context.appColors.border),
        borderRadius: BorderRadius.all(Radius.circular(100)),
        color: context.appColors.surface,
      ),
      child: SizedBox(
        height: r.space(12),
        child: Row(
          spacing: 3,
          children: [
            Icon(Icons.star_rounded, color: AppColors.star, size: r.space(12)),
            AppText.labelSmall(product.averageRating.toPersianDigit(), height: 1),
          ],
        ),
      ),
    );
  }

  Widget attributeColor(BuildContext context) {
    final r = context.responsive;
    final productColors = product.colors.take(4).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.space(5), vertical: r.space(2)),
      decoration: BoxDecoration(
        border: Border.all(color: context.appColors.border),
        borderRadius: BorderRadius.circular(100),
        color: context.appColors.surface,
      ),
      child: SizedBox(
        width: r.space(productColors.length * 10),
        height: r.space(12),
        child: Stack(
          children: [
            for (int i = 0; i < productColors.length; i++)
              Positioned(
                right: i * r.space(8),
                child: Container(
                  width: r.space(12),
                  height: r.space(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.hex(productColors[i]),
                    border: Border.all(color: context.appColors.border),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
