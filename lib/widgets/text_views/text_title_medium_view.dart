import 'package:flutter/material.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class TextTitleMediumView extends StatelessWidget {
  const TextTitleMediumView(this.data, {super.key, this.color, this.fontSize, this.fontWeight, this.height, this.textAlign, this.maxLines, this.overflow});

  final String data;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => AppText.titleMedium(
        data,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        textAlign: textAlign ?? TextAlign.center,
        maxLines: maxLines,
        overflow: overflow,
      );
}
