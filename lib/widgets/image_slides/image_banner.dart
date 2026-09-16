import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';

class ImageBanner extends StatelessWidget {
  const ImageBanner({required this.image, super.key});

  final String image;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return ClipRRect(
      borderRadius: BorderRadius.circular(r.radius(10)),
      child: CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.contain,
        errorWidget: (context, str, dyn) => Icon(Icons.image_outlined, color: context.appColors.textMuted, size: r.icon(72)),
      ),
    );
  }
}
