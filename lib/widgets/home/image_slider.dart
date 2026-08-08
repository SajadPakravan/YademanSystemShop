import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:yad_sys/models/image_item_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';

class ImageSlider extends StatefulWidget {
  ImageSlider({super.key, required this.currentIndex, required this.items});

  int currentIndex;
  final List<ImageItemModel> items;

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        CarouselSlider.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index, realIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _BannerCard(imageItem: widget.items[index]),
            );
          },
          options: CarouselOptions(
            aspectRatio: 16 / 9,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 450),
            onPageChanged: (index, reason) => setState(() => widget.currentIndex = index),
          ),
        ),
        Positioned(
          bottom: 5,
          child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5), borderRadius: BorderRadius.circular(100)),
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: index == widget.currentIndex ? 18 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(color: index == widget.currentIndex ? Colors.white : Colors.grey.shade500, borderRadius: BorderRadius.circular(20)),
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
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Material(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => SectionActionHandler.handle(context: context, action: imageItem.action),
          child: CachedNetworkImage(
            imageUrl: imageItem.image,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.black26, size: 52)),
          ),
        ),
      ),
    );
  }
}
