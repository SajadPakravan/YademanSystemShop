import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/image_item_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key, required this.currentIndex, required this.items});

  final int currentIndex;
  final List<ImageItemModel> items;

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index, realIndex) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding * 0.7),
              child: _BannerCard(imageItem: widget.items[index]),
            );
          },
          options: CarouselOptions(
            aspectRatio: 16 / 9,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 450),
            onPageChanged: (index, reason) => setState(() => _currentIndex = index),
          ),
        ),
        Positioned(
          bottom: r.space(5),
          child: Container(
            decoration: BoxDecoration(
              color: colors.overlay.withValues(alpha: context.isDarkMode ? 0.55 : 0.72),
              borderRadius: BorderRadius.circular(100),
            ),
            padding: EdgeInsets.all(r.space(5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: index == _currentIndex ? r.space(18) : r.space(7),
                  height: r.space(7),
                  margin: EdgeInsets.symmetric(horizontal: r.space(3)),
                  decoration: BoxDecoration(
                    color: index == _currentIndex ? AppColors.onBrand : AppColors.onBrand.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.imageItem});

  final ImageItemModel imageItem;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Material(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(r.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // onTap: () => SectionActionHandler.handle(context: context, action: imageItem.action),
          child: CachedNetworkImage(
            imageUrl: imageItem.image,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            errorWidget: (context, url, error) => Center(
              child: Icon(Icons.broken_image_outlined, color: colors.textMuted, size: r.icon(52)),
            ),
          ),
        ),
      ),
    );
  }
}
