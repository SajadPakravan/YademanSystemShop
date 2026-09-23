import 'package:flutter/material.dart';

/// رنگ‌های برند و رنگ‌های معنایی اپلیکیشن.
///
/// رنگ‌هایی که باید با Light/Dark تغییر کنند از [AppThemeColors] و
/// `context.appColors` خوانده می‌شوند. رنگ‌های ثابت برند در همین کلاس هستند.
class AppColors {
  const AppColors._();

  // Shared primitives
  static const Color transparent = Color(0x00000000);
  static const Color shadow = Color(0xff000000);

  // Brand
  static const Color primary = Color(0xff0353a4);
  static const Color primaryDark = Color(0xff063a70);
  static const Color secondary = Color(0xff3366cc);
  static const Color accent = Color(0xffe6123f);

  // Status
  static const Color success = Color(0xff159455);
  static const Color warning = Color(0xffd68a00);
  static const Color error = Color(0xffd92d20);
  static const Color info = Color(0xff1976d2);
  static const Color star = Color(0xffffb300);
  static const Color neutralOption = Color(0xff90a4ae);

  // Splash / branded surfaces
  static const Color splashTop = Color(0xff061b33);
  static const Color splashMid = Color(0xff073d6d);
  static const Color splashBottom = Color(0xff05223f);
  static const Color splashInfo = Color(0xff67d9ff);
  static const Color splashWarning = Color(0xffffca5c);
  static const Color splashError = Color(0xffff8d8d);
  static const Color splashSuccess = Color(0xff70e0a1);
  static const Color splashCircuit = Color(0xff70d8ff);
  static const Color onBrand = Color(0xffffffff);

  // Promotional section
  static const Color promoBright = Color(0xff0868c7);
  static const Color promoDeep = Color(0xff022f5f);

  // Light palette
  static const Color lightBackground = Color(0xfff7f9fc);
  static const Color lightSurface = Color(0xffffffff);
  static const Color lightSurfaceVariant = Color(0xfff1f4f8);
  static const Color lightSurfaceElevated = Color(0xffffffff);
  static const Color lightTextPrimary = Color(0xff171b24);
  static const Color lightTextSecondary = Color(0xff5d6675);
  static const Color lightTextMuted = Color(0xff8a93a2);
  static const Color lightBorder = Color(0xffe0e5ec);
  static const Color lightDivider = Color(0xffcbcbcc);
  static const Color lightChip = Color(0xffffffff);
  static const Color lightChipActive = Color(0xfffff0f3);
  static const Color lightOverlay = Color(0x66000000);

  // Dark palette
  static const Color darkBackground = Color(0xff0d1117);
  static const Color darkSurface = Color(0xff151b23);
  static const Color darkSurfaceVariant = Color(0xff1d2530);
  static const Color darkSurfaceElevated = Color(0xff202936);
  static const Color darkTextPrimary = Color(0xfff2f4f7);
  static const Color darkTextSecondary = Color(0xffc0c7d1);
  static const Color darkTextMuted = Color(0xff8993a3);
  static const Color darkBorder = Color(0xff303946);
  static const Color darkDivider = Color(0xff252d38);
  static const Color darkChip = Color(0xff1b222c);
  static const Color darkChipActive = Color(0xff3b1d28);
  static const Color darkOverlay = Color(0x99000000);

  // Backward-compatible names used by existing widgets.
  static const Color activeChipBackground = lightChipActive;

  static Color hex(String color) {
    final hex = color.replaceFirst('#', '');
    if (hex.length == 6) {
      final value = int.tryParse('FF$hex', radix: 16);
      if (value != null) return Color(value);
    }
    if (hex.length == 8) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) return Color(value);
    }
    return AppColors.neutralOption;
  }
}

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.chipBackground,
    required this.chipActiveBackground,
    required this.overlay,
    required this.success,
    required this.warning,
    required this.info,
    required this.favorite,
    required this.inquiryBackground,
    required this.inquiryForeground,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color divider;
  final Color chipBackground;
  final Color chipActiveBackground;
  final Color overlay;
  final Color success;
  final Color warning;
  final Color info;
  final Color favorite;
  final Color inquiryBackground;
  final Color inquiryForeground;

  static const light = AppThemeColors(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceVariant: AppColors.lightSurfaceVariant,
    surfaceElevated: AppColors.lightSurfaceElevated,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    border: AppColors.lightBorder,
    divider: AppColors.lightDivider,
    chipBackground: AppColors.lightChip,
    chipActiveBackground: AppColors.lightChipActive,
    overlay: AppColors.lightOverlay,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    favorite: AppColors.accent,
    inquiryBackground: Color(0xffeef5fd),
    inquiryForeground: AppColors.primary,
  );

  static const dark = AppThemeColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceVariant: AppColors.darkSurfaceVariant,
    surfaceElevated: AppColors.darkSurfaceElevated,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    border: AppColors.darkBorder,
    divider: AppColors.darkDivider,
    chipBackground: AppColors.darkChip,
    chipActiveBackground: AppColors.darkChipActive,
    overlay: AppColors.darkOverlay,
    success: Color(0xff42c67a),
    warning: Color(0xffffc15a),
    info: Color(0xff64b5f6),
    favorite: Color(0xffff5d78),
    inquiryBackground: Color(0xff112b45),
    inquiryForeground: Color(0xff7bc3ff),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? chipBackground,
    Color? chipActiveBackground,
    Color? overlay,
    Color? success,
    Color? warning,
    Color? info,
    Color? favorite,
    Color? inquiryBackground,
    Color? inquiryForeground,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      chipBackground: chipBackground ?? this.chipBackground,
      chipActiveBackground: chipActiveBackground ?? this.chipActiveBackground,
      overlay: overlay ?? this.overlay,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      favorite: favorite ?? this.favorite,
      inquiryBackground: inquiryBackground ?? this.inquiryBackground,
      inquiryForeground: inquiryForeground ?? this.inquiryForeground,
    );
  }

  @override
  AppThemeColors lerp(covariant AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      chipActiveBackground: Color.lerp(chipActiveBackground, other.chipActiveBackground, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      favorite: Color.lerp(favorite, other.favorite, t)!,
      inquiryBackground: Color.lerp(inquiryBackground, other.inquiryBackground, t)!,
      inquiryForeground: Color.lerp(inquiryForeground, other.inquiryForeground, t)!,
    );
  }
}

extension AppThemeColorsContext on BuildContext {
  AppThemeColors get appColors => Theme.of(this).extension<AppThemeColors>() ??
      (Theme.of(this).brightness == Brightness.dark ? AppThemeColors.dark : AppThemeColors.light);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
