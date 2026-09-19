import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/review_card_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ProductReviewCardWidget extends StatelessWidget {
  const ProductReviewCardWidget({super.key, required this.review});

  final ReviewCardModel review;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final author = review.author.trim();
    final firstLetter = author.isEmpty ? '?' : author.substring(0, 1);

    return Container(
      width: r.percentWidth(0.72, min: 250, max: r.isTablet ? 430 : 360),
      padding: EdgeInsets.all(r.space(14)),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(r.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: r.icon(19),
                backgroundColor: colors.inquiryBackground,
                foregroundColor: colors.inquiryForeground,
                child: AppText.titleSmall(firstLetter, color: colors.inquiryForeground, fontWeight: FontWeight.w800),
              ),
              SizedBox(width: r.space(9)),
              Expanded(
                child: AppText.bodyMedium(review.author, maxLines: 1, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w800),
              ),
              AppText.labelSmall(review.date.toPersianDate(), color: colors.textMuted),
            ],
          ),
          SizedBox(height: r.space(10)),
          RatingBarIndicator(
            rating: review.rating.toDouble(),
            itemCount: 5,
            itemSize: r.icon(17),
            itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.star),
          ),
          SizedBox(height: r.space(10)),
          Expanded(
            child: AppText.bodyMedium(review.content, maxLines: 5, overflow: TextOverflow.ellipsis, height: 1.7, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
