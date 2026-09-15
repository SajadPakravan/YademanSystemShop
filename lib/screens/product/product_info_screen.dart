import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_detail_model.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

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
        body = _description();
        break;
      case 2:
        title = 'مشخصات محصول';
        body = _attributes();
        break;
      case 3:
        title = 'دیدگاه‌ها';
        body = _reviews();
        break;
      default:
        title = '';
        body = const SizedBox.shrink();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBarView(title: title),
        body: body,
      ),
    );
  }

  Widget _description() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: HtmlWidget(
          Get.arguments['description'].toString().toPersianDigit(),
          textStyle: ThemeData.light().textTheme.bodyMedium!.copyWith(height: 2, fontSize: 16),
        ),
      ),
    );
  }

  Widget _attributes() {
    final List<ProductAttribute> attributes = List<ProductAttribute>.from(Get.arguments['attributes']);

    return ListView.separated(
      itemCount: attributes.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final attribute = attributes[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextBodyMediumView(
                  attribute.name.replaceAll('-', ' '),
                  color: Colors.black54,
                ),
              ),
              Expanded(
                child: TextBodyMediumView(
                  attribute.options.join('، ').toPersianDigit(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reviews() {
    final List<ProductDetailReview> reviews = List<ProductDetailReview>.from(Get.arguments['reviews']);

    return ListView.separated(
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final r = reviews[index];
        final review = r.data[index];
        final firstLetter = review.author.trim().isEmpty ? '?' : review.author.trim().substring(0, 1);

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xffeef5fd),
                foregroundColor: const Color(0xff0353a4),
                child: Text(firstLetter),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: TextBodyMediumView(review.author, fontWeight: FontWeight.bold)),
                        Text(review.date, style: const TextStyle(color: Colors.black45, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextBodyMediumView(review.content),
                    const SizedBox(height: 8),
                    RatingBarIndicator(
                      rating: review.rating.toDouble(),
                      itemCount: 5,
                      itemSize: 18,
                      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
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
