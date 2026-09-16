import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';

class ProductImagesScreen extends StatefulWidget {
  const ProductImagesScreen({super.key});

  @override
  State<ProductImagesScreen> createState() => _ProductImagesScreenState();
}

class _ProductImagesScreenState extends State<ProductImagesScreen> {
  final CarouselSliderController slideCtrl = CarouselSliderController();
  int currentSlide = 0;
  bool getCurrentSlide = true;
  List<Widget> itemSlider = [];
  List<String> imageList = [];
  bool imageItemVis = true;

  void getProductImages() {
    imageList = List<String>.from(Get.arguments['images']);
    itemSlider = imageList
        .map(
          (item) => InteractiveViewer(
            panEnabled: false,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 2,
            child: Image.network(
              item,
              fit: BoxFit.contain,
              frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
            ),
            onInteractionStart: (_) => setState(() => imageItemVis = false),
            onInteractionEnd: (_) => setState(() => imageItemVis = true),
          ),
        )
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    getProductImages();
    if (getCurrentSlide) {
      currentSlide = Get.arguments['imageIndex'];
      if (kDebugMode) print('imageIndex >>>> $currentSlide');
      getCurrentSlide = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(backgroundColor: colors.surface),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            items: itemSlider,
            carouselController: slideCtrl,
            disableGesture: true,
            options: CarouselOptions(
              height: r.height,
              viewportFraction: 1,
              initialPage: currentSlide,
              scrollPhysics: const NeverScrollableScrollPhysics(),
              padEnds: false,
              onPageChanged: (index, reason) => setState(() => currentSlide = index),
            ),
          ),
          Visibility(
            visible: imageItemVis,
            child: Container(
              color: colors.surface.withValues(alpha: 0.94),
              alignment: Alignment.center,
              height: r.percentWidth(0.25, min: 88, max: 130),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: imageList.asMap().entries.map((entry) {
                    final selected = currentSlide == entry.key;
                    final imageSize = selected
                        ? r.percentWidth(0.20, min: 68, max: 105)
                        : r.percentWidth(0.10, min: 46, max: 70);
                    return InkWell(
                      onTap: () => slideCtrl.animateToPage(entry.key, duration: const Duration(milliseconds: 500)),
                      child: Padding(
                        padding: EdgeInsets.all(r.space(4)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: imageSize, height: imageSize, child: Image.network(entry.value, fit: BoxFit.contain)),
                            SizedBox(height: r.space(3)),
                            Container(
                              width: r.percentWidth(0.15, min: 54, max: 82),
                              height: 2,
                              decoration: BoxDecoration(
                                color: selected ? AppColors.accent : AppColors.transparent,
                                borderRadius: BorderRadius.circular(r.radius(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
