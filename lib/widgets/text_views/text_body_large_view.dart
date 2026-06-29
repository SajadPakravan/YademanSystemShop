import 'package:flutter/material.dart';

class TextBodyLargeView extends StatelessWidget {
  const TextBodyLargeView(this.data, {super.key, this.color, this.fontSize, this.fontWeight, this.height, this.textAlign});

  final String data;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: color, fontSize: fontSize, fontWeight: fontWeight, height: height),
    );
  }
}
