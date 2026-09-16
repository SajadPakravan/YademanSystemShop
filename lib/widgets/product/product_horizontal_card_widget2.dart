import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/product/price_view_widget.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ShopProductCard extends StatelessWidget {
  const ShopProductCard({super.key, required this.product});

  final ProductCardModel product;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final displayName = product.discountPercent > 0 && product.variationName.isNotEmpty ? '${product.name} | ${product.variationName}' : product.name;

    double cardHeight() {
      if (product.inquiry && (product.colors.isNotEmpty || product.averageRating != '0.0')) return r.percentHeight(0.21, min: 170, max: 240);
      if (product.discountPercent > 0) {
        if (product.colors.isEmpty && product.averageRating == '0.0') return r.percentHeight(0.23, min: 180, max: 250);
        return r.percentHeight(0.25, min: 195, max: 270);
      }
      if (product.colors.isNotEmpty || product.averageRating != '0.0') return r.percentHeight(0.20, min: 165, max: 230);
      return r.percentHeight(0.18, min: 155, max: 215);
    }

    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: () => toProduct(id: product.id),
        child: Container(
          height: cardHeight(),
          padding: EdgeInsets.all(r.space(12)),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.divider))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: r.percentWidth(0.33, min: 118, max: 160),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (_, _, _) => Center(child: Icon(Icons.image_not_supported_outlined, size: r.icon(46), color: colors.textMuted)),
                ),
              ),
              SizedBox(width: r.space(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (product.discountPercent > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: r.space(8), vertical: r.space(4)),
                          decoration: BoxDecoration(color: colors.chipActiveBackground, borderRadius: BorderRadius.circular(r.radius(8))),
                          child: const AppText.labelSmall('فروش ویژه', color: AppColors.accent, fontWeight: FontWeight.w600),
                        ),
                      ),
                    AppText.bodyMedium(
                      displayName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                      height: 1.75,
                    ),
                    Row(
                      children: [
                        _ratingBar(context),
                        SizedBox(width: r.space(5)),
                        Expanded(child: _colorBar(context)),
                      ],
                    ),
                    if (product.stockQuantity > 0 && product.stockQuantity <= 3)
                      AppText.bodySmall(
                        '${AppFunction.faDigit(product.stockQuantity)} عدد در انبار باقی مانده',
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      )
                    else if (product.stockQuantity > 0)
                      AppText.bodySmall('موجود در انبار', color: colors.textMuted),
                    if (product.inquiry)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: r.space(9), horizontal: r.space(10)),
                        decoration: BoxDecoration(color: colors.inquiryBackground, borderRadius: BorderRadius.circular(r.radius(9))),
                        child: AppText.labelMedium(
                          'استعلام قیمت و موجودی',
                          textAlign: TextAlign.center,
                          color: colors.inquiryForeground,
                          fontWeight: FontWeight.w700,
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

  Widget _ratingBar(BuildContext context) {
    if (product.averageRating == '0.0') return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.star, size: context.responsive.icon(20)),
        AppText.bodySmall(AppFunction.faDigit(product.averageRating), color: context.appColors.textSecondary),
      ],
    );
  }

  Widget _colorBar(BuildContext context) {
    if (product.colors.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: context.responsive.space(20),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: product.colors.length,
        separatorBuilder: (_, _) => SizedBox(width: context.responsive.space(4)),
        itemBuilder: (context, index) {
          final color = product.colors[index];
          return Container(
            width: context.responsive.space(18),
            height: context.responsive.space(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _colorHex(color),
              border: Border.all(color: context.appColors.border),
            ),
          );
        },
      ),
    );
  }

  Color _colorHex(String color) {
    final hex = color.replaceFirst('#', '');
    if (hex.length == 6) {
      final value = int.tryParse('FF$hex', radix: 16);
      if (value != null) return Color(value);
    }
    if (hex.length == 8) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) return Color(value);
    }
    return AppColors.neutralOption;
  }
}
