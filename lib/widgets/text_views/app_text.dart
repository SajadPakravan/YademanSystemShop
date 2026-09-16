import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_dimension.dart';

enum AppTextType { display, titleLarge, titleMedium, titleSmall, bodyLarge, bodyMedium, bodySmall, labelLarge, labelMedium, labelSmall }

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.type = AppTextType.bodyMedium,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap,
    this.textDirection,
    this.responsive = true,
  });

  final String data;
  final AppTextType type;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final bool? softWrap;
  final TextDirection? textDirection;
  final bool responsive;

  const AppText.display(
    this.data, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap,
    this.textDirection,
    this.responsive = true,
  }) : type = AppTextType.display;

  const AppText.titleLarge(
    this.data, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap,
    this.textDirection,
    this.responsive = true,
  }) : type = AppTextType.titleLarge;

  const AppText.titleMedium(
    this.data, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap,
    this.textDirection,
    this.responsive = true,
  }) : type = AppTextType.titleMedium;

  const AppText.titleSmall(
    this.data, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap,
    this.textDirection,
    this.responsive = true,
  }) : type = AppTextType.titleSmall;

  const AppText.bodyLarge(
    this.data, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap,
    this.textDirection,
    this.responsive = true,
  }) : type = AppTextType.bodyLarge;

  const AppText.bodyMedium(
    this.data, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap,
    this.textDirection,
    this.responsive = true,
  }) : type = AppTextType.bodyMedium;

  const AppText.bodySmall(
    this.data, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap,
    this.textDirection,
    this.responsive = true,
  }) : type = AppTextType.bodySmall;

  const AppText.labelLarge(
    this.data, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap,
    this.textDirection,
    this.responsive = true,
  }) : type = AppTextType.labelLarge;

  const AppText.labelMedium(
    this.data, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap,
    this.textDirection,
    this.responsive = true,
  }) : type = AppTextType.labelMedium;

  const AppText.labelSmall(
    this.data, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap,
    this.textDirection,
    this.responsive = true,
  }) : type = AppTextType.labelSmall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final base =
        switch (type) {
          AppTextType.display => theme.displaySmall,
          AppTextType.titleLarge => theme.titleLarge,
          AppTextType.titleMedium => theme.titleMedium,
          AppTextType.titleSmall => theme.titleSmall,
          AppTextType.bodyLarge => theme.bodyLarge,
          AppTextType.bodyMedium => theme.bodyMedium,
          AppTextType.bodySmall => theme.bodySmall,
          AppTextType.labelLarge => theme.labelLarge,
          AppTextType.labelMedium => theme.labelMedium,
          AppTextType.labelSmall => theme.labelSmall,
        } ??
        const TextStyle();

    final baseSize = fontSize ?? base.fontSize;
    final resolvedSize = baseSize == null || !responsive ? baseSize : context.responsive.font(baseSize);

    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      style: base.copyWith(color: color, fontSize: resolvedSize, fontWeight: fontWeight, height: height, decoration: decoration),
    );
  }
}
