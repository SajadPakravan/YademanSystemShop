import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/models/review_model.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class ProductInfoScreen extends StatefulWidget {
  const ProductInfoScreen({super.key});

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  String title = '';
  Widget body = Container();
  List<Attribute> attributesLst = [];
  List<ReviewModel> reviewsLst = [];

  loadContent() async {
    switch (Get.arguments['content']) {
      case 1:
        {
          setState(() {
            title = 'معرفی محصول';
            body = description();
          });
          break;
        }
      case 2:
        {
          setState(() {
            title = 'مشخصات محصول';
            attributesLst = Get.arguments['attributes'];
            body = attributes();
          });
          break;
        }
      case 3:
        {
          setState(() {
            title = 'دیدگاه‌ها';
            reviewsLst = Get.arguments['reviews'];
            body = reviews();
          });
          break;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    loadContent();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(appBar: AppBarView(title: title), body: body));
  }

  description() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: HtmlWidget(
          Get.arguments['description'].toString().toPersianDigit(),
          textStyle: ThemeData.light().textTheme.bodyMedium!.copyWith(height: 2, fontSize: 16),
        ),
      ),
    );
  }

  attributes() {
    return ListView.builder(
      itemCount: attributesLst.length,
      itemBuilder: (BuildContext context, int index) {
        Attribute attribute = attributesLst[index];
        String name = attribute.name!.replaceAll('-', ' ');
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black26))),
          child: Row(
            children: [
              Expanded(child: TextBodyMediumView(name, color: Colors.black54)),
              Expanded(child: TextBodyMediumView(attribute.options![0].toString().toPersianDigit())),
            ],
          ),
        );
      },
    );
  }

  reviews() {
    return ListView.builder(
      itemCount: reviewsLst.length,
      itemBuilder: (BuildContext context, int index) {
        ReviewModel review = reviewsLst[index];
        ReviewerAvatarUrls avatar = review.avatarUrls!;
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black26))),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    CachedNetworkImage(imageUrl: avatar.s48!),
                    const SizedBox(width: 10),
                    Expanded(child: TextBodyMediumView(review.reviewer!))
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HtmlWidget(
                      review.review!,
                      textStyle: ThemeData.light().textTheme.bodyMedium!.copyWith(color: Colors.black87, fontSize: 16),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.03,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.bottomLeft,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: RatingBar.builder(
                          initialRating: review.rating!.toDouble(),
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          ignoreGestures: true,
                          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (double value) {},
                        ),
                      ),
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
