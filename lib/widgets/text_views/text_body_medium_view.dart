import 'package:flutter/material.dart';

class TextBodyMediumView extends StatelessWidget {
  const TextBodyMediumView(
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
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: color, fontSize: fontSize, fontWeight: fontWeight, height: height),
    );
  }
}
