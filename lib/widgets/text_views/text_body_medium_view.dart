import 'package:flutter/material.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class TextBodyMediumView extends StatelessWidget {
  const TextBodyMediumView(this.data, {super.key, this.maxLines, this.textAlign, this.color, this.fontSize, this.fontWeight, this.height, this.overflow});

  final String data;
  final int? maxLines;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => AppText.bodyMedium(
        data,
        maxLines: maxLines,
        textAlign: textAlign,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        overflow: overflow,
      );
}
