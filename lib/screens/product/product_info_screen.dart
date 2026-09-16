import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_detail_model.dart';
import 'package:yad_sys/models/review_card_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ProductInfoScreen extends StatelessWidget {
  const ProductInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int content = Get.arguments['content'];

    late final String title;
    late final Widget body;

    switch (content) {
      case 1:
        title = 'معرفی محصول';
        body = _description(context);
        break;
      case 2:
        title = 'مشخصات محصول';
        body = _attributes(context);
        break;
      case 3:
        title = 'دیدگاه‌ها';
        body = _reviews(context);
        break;
      default:
        title = '';
        body = const SizedBox.shrink();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(appBar: AppBarView(title: title), body: body),
    );
  }

  Widget _description(BuildContext context) {
    final r = context.responsive;
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    return SingleChildScrollView(
      padding: EdgeInsets.all(r.pageHorizontalPadding),
      child: HtmlWidget(
        Get.arguments['description'].toString().toPersianDigit(),
        textStyle: baseStyle.copyWith(
          color: context.appColors.textPrimary,
          height: 2,
          fontSize: r.font(baseStyle.fontSize ?? 14),
        ),
      ),
    );
  }

  Widget _attributes(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final attributes = List<ProductAttribute>.from(Get.arguments['attributes']);

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: r.space(4)),
      itemCount: attributes.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: colors.divider),
      itemBuilder: (context, index) {
        final attribute = attributes[index];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding, vertical: r.space(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText.bodyMedium(
                  attribute.name.replaceAll('-', ' '),
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: r.space(12)),
              Expanded(
                child: AppText.bodyMedium(
                  attribute.options.join('، ').toPersianDigit(),
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reviews(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final groups = List<ProductDetailReview>.from(Get.arguments['reviews']);
    final List<ReviewCardModel> reviews = groups.expand((group) => group.data).toList(growable: false);

    if (reviews.isEmpty) {
      return Center(
        child: AppText.bodyMedium('هنوز دیدگاهی ثبت نشده است', color: colors.textSecondary),
      );
    }

    return ListView.separated(
      itemCount: reviews.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: colors.divider),
      itemBuilder: (context, index) {
        final review = reviews[index];
        final author = review.author.trim();
        final firstLetter = author.isEmpty ? '?' : author.substring(0, 1);

        return Padding(
          padding: EdgeInsets.all(r.pageHorizontalPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: r.icon(20),
                backgroundColor: colors.inquiryBackground,
                foregroundColor: colors.inquiryForeground,
                child: AppText.titleSmall(firstLetter, color: colors.inquiryForeground, fontWeight: FontWeight.w800),
              ),
              SizedBox(width: r.space(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: AppText.bodyMedium(review.author, fontWeight: FontWeight.w800)),
                        SizedBox(width: r.space(8)),
                        AppText.labelSmall(review.date.toPersianDigit(), color: colors.textMuted),
                      ],
                    ),
                    SizedBox(height: r.space(8)),
                    AppText.bodyMedium(review.content, height: 1.8),
                    SizedBox(height: r.space(8)),
                    RatingBarIndicator(
                      rating: review.rating.toDouble(),
                      itemCount: 5,
                      itemSize: r.icon(18),
                      itemBuilder: (context, _) => const Icon(Icons.star, color: AppColors.star),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
