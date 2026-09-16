import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';

class HomeSlide extends StatelessWidget {
  HomeSlide({super.key, required this.slideIndex, required this.onSlideChange});

  final PageController _pageCtrl = PageController();
  final int slideIndex;
  final Function onSlideChange;

  final List<String> imgLst = const [
    'https://yademansystem.ir/wp-content/uploads/2026/06/YademanSystem_banner_Laptop.webp',
    'https://yademansystem.ir/wp-content/uploads/2026/06/YademanSystem_banner_Speaker.webp',
  ];

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final itemSlider = imgLst
        .map((item) => InkWell(child: AspectRatio(aspectRatio: 16 / 9, child: CachedNetworkImage(imageUrl: item, fit: BoxFit.cover)), onTap: () {}))
        .toList(growable: false);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(height: 0, child: PageView(controller: _pageCtrl, children: itemSlider)),
        CarouselSlider(
          items: itemSlider,
          options: CarouselOptions(
            viewportFraction: 1,
            autoPlay: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 300),
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, value) {
              onSlideChange(index);
              _pageCtrl.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.linear);
            },
          ),
        ),
        Positioned(
          left: r.space(14),
          bottom: r.space(12),
          child: SmoothPageIndicator(
            controller: _pageCtrl,
            count: imgLst.length,
            effect: ScrollingDotsEffect(
              dotHeight: r.space(8),
              dotWidth: r.space(8),
              activeDotColor: AppColors.primary,
              dotColor: context.appColors.border,
            ),
          ),
        ),
      ],
    );
  }
}
