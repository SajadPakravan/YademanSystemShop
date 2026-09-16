import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';

// Legacy widget kept for compatibility. New product pages use ProductSlide.
class ProductImagesSlide extends StatelessWidget {
  ProductImagesSlide({
    super.key,
    required this.currentSlide,
    required this.moveSlide,
    required this.json,
  });

  final CarouselSliderController slideCtrl = CarouselSliderController();
  final Function moveSlide;
  final int currentSlide;
  final dynamic json;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final imageList = (json['images'] as List)
        .map((item) => item['src'].toString())
        .toList(growable: false);
    final itemSlider = imageList
        .map((item) => CachedNetworkImage(imageUrl: item, fit: BoxFit.contain))
        .toList(growable: false);

    return Container(
      color: colors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CarouselSlider(
            items: itemSlider,
            carouselController: slideCtrl,
            options: CarouselOptions(
              height: r.percentHeight(0.5, min: 260, max: 520),
              viewportFraction: 1,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) => moveSlide(index),
            ),
          ),
          SizedBox(
            height: r.percentWidth(0.2, min: 72, max: 112),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: imageList.asMap().entries.map((entry) {
                  final selected = currentSlide == entry.key;
                  final size = selected
                      ? r.percentWidth(0.18, min: 62, max: 96)
                      : r.percentWidth(0.11, min: 44, max: 68);
                  return InkWell(
                    onTap: () => slideCtrl.animateToPage(entry.key),
                    child: Container(
                      width: size,
                      height: size,
                      margin: EdgeInsets.all(r.space(4)),
                      decoration: BoxDecoration(
                        border: Border.all(color: selected ? AppColors.primary : colors.border),
                        borderRadius: BorderRadius.circular(r.radius(8)),
                      ),
                      child: CachedNetworkImage(imageUrl: entry.value, fit: BoxFit.contain),
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
