import 'package:flutter/material.dart';

/// اندازه‌های پایه تایپوگرافی. اندازه نهایی در AppText متناسب با صفحه Scale می‌شود.
class AppTextSizes {
  const AppTextSizes._();

  static const double display = 24;
  static const double titleLarge = 20;
  static const double titleMedium = 17;
  static const double titleSmall = 15;
  static const double bodyLarge = 15;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
  static const double labelLarge = 14;
  static const double labelMedium = 12;
  static const double labelSmall = 10.5;
}

class AppTextStyles {
  const AppTextStyles._();

  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      displaySmall: TextStyle(fontSize: AppTextSizes.display, fontWeight: FontWeight.w900, color: primary, height: 1.35),
      titleLarge: TextStyle(fontSize: AppTextSizes.titleLarge, fontWeight: FontWeight.w800, color: primary, height: 1.4),
      titleMedium: TextStyle(fontSize: AppTextSizes.titleMedium, fontWeight: FontWeight.w700, color: primary, height: 1.45),
      titleSmall: TextStyle(fontSize: AppTextSizes.titleSmall, fontWeight: FontWeight.w600, color: primary, height: 1.45),
      bodyLarge: TextStyle(fontSize: AppTextSizes.bodyLarge, fontWeight: FontWeight.w400, color: primary, height: 1.65),
      bodyMedium: TextStyle(fontSize: AppTextSizes.bodyMedium, fontWeight: FontWeight.w400, color: primary, height: 1.6),
      bodySmall: TextStyle(fontSize: AppTextSizes.bodySmall, fontWeight: FontWeight.w400, color: secondary, height: 1.55),
      labelLarge: TextStyle(fontSize: AppTextSizes.labelLarge, fontWeight: FontWeight.w700, color: primary, height: 1.35),
      labelMedium: TextStyle(fontSize: AppTextSizes.labelMedium, fontWeight: FontWeight.w600, color: secondary, height: 1.35),
      labelSmall: TextStyle(fontSize: AppTextSizes.labelSmall, fontWeight: FontWeight.w600, color: secondary, height: 1.3),
    );
  }
}

// Compatibility for old imports.
class TextStylesLight {
  static const TextStyle blackF12 = TextStyle(fontSize: 12);
  static const TextStyle blackF14 = TextStyle(fontSize: 14);
  static const TextStyle blackF16 = TextStyle(fontSize: 16);
  static const TextStyle blackF18 = TextStyle(fontSize: 18);
  static const TextStyle blackF20 = TextStyle(fontSize: 20);
  static const TextStyle blackF25 = TextStyle(fontSize: 25);
}
