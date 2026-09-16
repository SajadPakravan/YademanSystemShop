import 'package:flutter/material.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class TextBodyLargeView extends StatelessWidget {
  const TextBodyLargeView(this.data, {super.key, this.color, this.fontSize, this.fontWeight, this.height, this.textAlign, this.maxLines, this.overflow});

  final String data;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => AppText.bodyLarge(
        data,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
}
