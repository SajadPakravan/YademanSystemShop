import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ImageBanner extends StatelessWidget {
  ImageBanner({
    required this.image,
    super.key,
  });

  String image = "";

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.contain,
        errorWidget: (context, str, dyn) {
          return const Icon(Icons.image, color: Colors.black26, size: 100);
        },
      ),
    );
  }
}
