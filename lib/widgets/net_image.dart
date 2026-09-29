import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';

class NetImage extends StatelessWidget {
  const NetImage({super.key, required this.imageUrl, this.width, this.height});

  final String imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return SizedBox(
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) => DecoratedBox(
          decoration: BoxDecoration(color: colors.surfaceVariant, borderRadius: BorderRadius.circular(r.radius(16))),
          child: Icon(Icons.broken_image_outlined, color: colors.textMuted, size: width),
        ),
      ),
    );
  }
}
