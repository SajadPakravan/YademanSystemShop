import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeSlide extends StatelessWidget {
  HomeSlide({super.key, required this.slideIndex, required this.onSlideChange});

  final PageController _pageCtrl = PageController();
  final int slideIndex;
  final Function onSlideChange;
  final bool forwardSlide = true;

  final List<String> imgLst = [
    'https://yademansystem.ir/wp-content/uploads/2026/06/YademanSystem_banner_Laptop.webp',
    'https://yademansystem.ir/wp-content/uploads/2026/06/YademanSystem_banner_Speaker.webp'
    'https://yademansystem.ir/wp-content/uploads/2026/06/YademanSystem_banner_Laptop.webp',
    'https://yademansystem.ir/wp-content/uploads/2026/06/YademanSystem_banner_Speaker.webp'
    'https://yademansystem.ir/wp-content/uploads/2026/06/YademanSystem_banner_Laptop.webp',
    'https://yademansystem.ir/wp-content/uploads/2026/06/YademanSystem_banner_Speaker.webp'
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> itemSlider = imgLst
        .map((item) =>
            InkWell(child: AspectRatio(aspectRatio: 16 / 9, child: CachedNetworkImage(imageUrl: item, fit: BoxFit.cover)), onTap: () {}))
        .toList();

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
              _pageCtrl.animateToPage(slideIndex, duration: const Duration(milliseconds: 300), curve: Curves.linear);
            },
          ),
        ),
        Transform.translate(
          offset: const Offset(10, 100),
          child: Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 5),
            child: SmoothPageIndicator(
              controller: _pageCtrl,
              count: imgLst.length,
              effect: const ScrollingDotsEffect(dotHeight: 8, dotWidth: 8, activeDotColor: Colors.black87, dotColor: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
