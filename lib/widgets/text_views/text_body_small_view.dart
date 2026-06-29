import 'package:flutter/material.dart';

class TextBodySmallView extends StatelessWidget {
  const TextBodySmallView(
    this.data, {
    super.key,
    this.maxLines,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
  });

  final String data;
  final int? maxLines;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: maxLines,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color, fontSize: fontSize, fontWeight: fontWeight, height: height),
    );
  }
}
