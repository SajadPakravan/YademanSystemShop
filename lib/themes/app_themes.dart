import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yad_sys/themes/text_styles.dart';
import 'package:yad_sys/tools/app_colors.dart';

class AppThemes {
  const AppThemes._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final semantic = isDark ? AppThemeColors.dark : AppThemeColors.light;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: semantic.surface,
    ).copyWith(
      onSurface: semantic.textPrimary,
      outline: semantic.border,
      outlineVariant: semantic.divider,
      surfaceContainerHighest: semantic.surfaceVariant,
    );

    final textTheme = AppTextStyles.textTheme(semantic.textPrimary, semantic.textSecondary).apply(fontFamily: 'IranYekan');

    final overlay = SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: semantic.surface,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: semantic.divider,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'IranYekan',
      scaffoldBackgroundColor: semantic.background,
      canvasColor: semantic.background,
      cardColor: semantic.surface,
      dividerColor: semantic.divider,
      disabledColor: semantic.textMuted.withValues(alpha: 0.45),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[semantic],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: semantic.surface,
        foregroundColor: semantic.textPrimary,
        surfaceTintColor: AppColors.transparent,
        systemOverlayStyle: overlay,
        titleTextStyle: textTheme.titleMedium,
        iconTheme: IconThemeData(color: semantic.textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: semantic.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: semantic.textMuted,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: semantic.surface,
        indicatorColor: AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(color: states.contains(WidgetState.selected) ? AppColors.primary : semantic.textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelSmall?.copyWith(color: states.contains(WidgetState.selected) ? AppColors.primary : semantic.textMuted);
        }),
      ),
      cardTheme: CardThemeData(
        color: semantic.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: semantic.border)),
      ),
      dividerTheme: DividerThemeData(color: semantic.divider, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: semantic.textSecondary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semantic.surfaceVariant,
        hintStyle: textTheme.bodyMedium?.copyWith(color: semantic.textMuted),
        labelStyle: textTheme.bodySmall?.copyWith(color: semantic.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: semantic.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: semantic.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onBrand,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onBrand,
          elevation: 0,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: semantic.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: textTheme.labelLarge),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: semantic.chipBackground,
        selectedColor: semantic.chipActiveBackground,
        side: BorderSide(color: semantic.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        labelStyle: textTheme.bodySmall?.copyWith(color: semantic.textPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: semantic.surface,
        surfaceTintColor: AppColors.transparent,
        modalBackgroundColor: semantic.surface,
        modalBarrierColor: semantic.overlay,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        showDragHandle: true,
        dragHandleColor: semantic.border,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: semantic.surface,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.primary : semantic.textMuted),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.primary.withValues(alpha: 0.35) : semantic.border),
      ),
    );
  }
}
