import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';

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
    final r = context.responsive;
    final colors = context.appColors;
    final height = r.percentHeight(0.40, min: 250, max: r.isTablet ? 520 : 430);

    if (widget.images.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Icon(Icons.broken_image_outlined, color: colors.textMuted, size: r.icon(86))),
      );
    }

    return ColoredBox(
      color: colors.surface,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: height,
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
                    errorWidget: (context, url, error) => Center(
                      child: Icon(Icons.broken_image_outlined, color: colors.textMuted, size: r.icon(86)),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.images.length > 1)
            PositionedDirectional(
              start: r.space(10),
              bottom: r.space(10),
              child: SmoothPageIndicator(
                controller: pageCtrl,
                count: widget.images.length,
                effect: ScrollingDotsEffect(
                  dotHeight: r.space(8, min: 7, max: 10),
                  dotWidth: r.space(8, min: 7, max: 10),
                  dotColor: colors.border,
                  activeDotColor: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
