import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/cart_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/net_image.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class CustomerProductRowCard extends StatelessWidget {
  const CustomerProductRowCard({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
    final imageSize = r.percentWidth(0.27, min: 96, max: 145);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(r.radius(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(r.radius(14)),
        onTap: item.id > 0 ? () => toProduct(id: item.id) : null,
        child: Container(
          padding: EdgeInsets.all(r.space(10)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r.radius(14)),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              NetImage(imageUrl: item.image, width: imageSize, height: imageSize),
              SizedBox(width: r.space(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText.bodyMedium(
                      item.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      height: 1.6,
                    ),
                    if (item.variationText.isNotEmpty) ...[
                      SizedBox(height: r.space(6)),
                      AppText.bodySmall(
                        item.variationText,
                        color: colors.textSecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: r.space(10)),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: r.space(8), vertical: r.space(4)),
                          decoration: BoxDecoration(color: colors.surfaceVariant, borderRadius: BorderRadius.circular(r.radius(8))),
                          child: AppText.labelSmall(
                            'تعداد ${item.quantity.toString().toPersianDigit()}',
                            color: colors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        AppText.bodyMedium(
                          '${item.price.toString().seRagham().toPersianDigit()} تومان',
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
