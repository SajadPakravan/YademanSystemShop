import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yad_sys/themes/color_style.dart';

class ProductSlide extends StatefulWidget {
  const ProductSlide({
    super.key,
    required this.images,
    required this.slideIndex,
    required this.onSlideChange,
    required this.onImageTap,
  });

  final List<String> images;
  final int slideIndex;
  final ValueChanged<int> onSlideChange;
  final ValueChanged<int> onImageTap;

  @override
  State<ProductSlide> createState() => _ProductSlideState();
}

class _ProductSlideState extends State<ProductSlide> {
  final PageController pageCtrl = PageController();

  @override
  void dispose() {
    pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.36,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.black26, size: 90),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.4,
            child: PageView.builder(
              controller: pageCtrl,
              itemCount: widget.images.length,
              onPageChanged: widget.onSlideChange,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => widget.onImageTap(index),
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image_outlined, color: Colors.black26, size: 90),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.images.length > 1)
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 10, bottom: 10),
              child: SmoothPageIndicator(
                controller: pageCtrl,
                count: widget.images.length,
                effect: const ScrollingDotsEffect(
                  dotHeight: 9,
                  dotWidth: 9,
                  activeDotColor: ColorStyle.blueFav,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
