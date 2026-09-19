import 'dart:math' as math;

import 'package:flutter/material.dart';

/// تمام محاسبات ریسپانسیو پروژه از این کلاس عبور می‌کنند.
/// هدف این است که فرمول‌های MediaQuery/Clamp در ویجت‌های مختلف تکرار نشوند.
class AppDimension {
  AppDimension._(this.context) : size = MediaQuery.sizeOf(context), padding = MediaQuery.paddingOf(context);

  final BuildContext context;
  final Size size;
  final EdgeInsets padding;

  static AppDimension of(BuildContext context) => AppDimension._(context);

  double get width => size.width;

  double get height => size.height;

  double get shortestSide => math.min(width, height);

  bool get isCompact => width < 360 || height < 680;

  bool get isLargePhone => width >= 430;

  bool get isTablet => shortestSide >= 600;

  /// ضریب کنترل‌شده بر اساس عرض طراحی مرجع 390px.
  double get scale => (width / 390.0).clamp(0.88, isTablet ? 1.28 : 1.14).toDouble();

  double font(double base, {double? min, double? max}) {
    final value = base * scale;
    return value.clamp(min ?? base * 0.88, max ?? base * (isTablet ? 1.32 : 1.16)).toDouble();
  }

  double space(double base, {double? min, double? max}) {
    final value = base * scale;
    return value.clamp(min ?? base * 0.82, max ?? base * (isTablet ? 1.35 : 1.18)).toDouble();
  }

  double icon(double base, {double? min, double? max}) => font(base, min: min, max: max);

  double radius(double base) => space(base, min: base * 0.9, max: base * 1.2);

  double percentWidth(double fraction, {double? min, double? max}) {
    final value = width * fraction;
    if (min == null && max == null) return value;
    return value.clamp(min ?? value, max ?? value).toDouble();
  }

  double percentHeight(double fraction, {double? min, double? max}) {
    final value = height * fraction;
    if (min == null && max == null) return value;
    return value.clamp(min ?? value, max ?? value).toDouble();
  }

  double get pageHorizontalPadding => percentWidth(0.035, min: 12, max: isTablet ? 28 : 20);

  double get sectionVerticalGap => space(16, min: 12, max: 22);

  double get controlHeight => space(44, min: 42, max: 52);

  double get buttonHeight => space(52, min: 48, max: 58);

  double get chipHeight => space(40, min: 38, max: 46);

  double get cardRadius => radius(12);

  double gridItemWidth({required int columns, double horizontalPadding = 20, double spacing = 10, double min = 72, double max = 180}) {
    final safeColumns = math.max(1, columns);
    final available = width - horizontalPadding - ((safeColumns - 1) * spacing);
    return (available / safeColumns).clamp(min, max).toDouble();
  }
}

extension AppDimensionContext on BuildContext {
  AppDimension get responsive => AppDimension.of(this);
}

/// متریک مشترک برای سکشن‌های افقی خانه تا محاسبات عرض/ارتفاع در چند ویجت تکرار نشود.
class HorizontalGridMetrics {
  const HorizontalGridMetrics({
    required this.rows,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.spacing,
    required this.cardWidth,
    required this.cardHeight,
    required this.contentHeight,
    required this.sectionHeight,
    required this.gridWidth,
    required this.viewAllWidth,
  });

  final int rows;
  final double horizontalPadding;
  final double verticalPadding;
  final double spacing;
  final double cardWidth;
  final double cardHeight;
  final double contentHeight;
  final double sectionHeight;
  final double gridWidth;
  final double viewAllWidth;

  factory HorizontalGridMetrics.verticalProducts(BuildContext context, {required int rows, required int itemCount}) {
    final r = context.responsive;
    return _build(
      r: r,
      rows: rows,
      itemCount: itemCount,
      cardWidth: r.percentWidth(0.35, min: 145, max: r.isTablet ? 260 : 220),
      cardHeightFactor: 1.7,
      cardHeightMin: 200,
      cardHeightMax: r.isTablet ? 360 : 300,
    );
  }

  factory HorizontalGridMetrics.horizontalProducts(BuildContext context, {required int rows, required int itemCount}) {
    final r = context.responsive;
    return _build(
      r: r,
      rows: rows,
      itemCount: itemCount,
      cardWidth: r.percentWidth(0.72, min: 250, max: r.isTablet ? 520 : 420),
      cardHeightFactor: 0.30,
      cardHeightMin: 125,
      cardHeightMax: r.isTablet ? 250 : 225,
    );
  }

  factory HorizontalGridMetrics.posts(BuildContext context, {required int rows, required int itemCount}) {
    final r = context.responsive;
    return _build(
      r: r,
      rows: rows,
      itemCount: itemCount,
      cardWidth: r.percentWidth(0.92, min: 250, max: r.isTablet ? 560 : 420),
      cardHeightFactor: 0.48,
      cardHeightMin: 125,
      cardHeightMax: r.isTablet ? 280 : 225,
    );
  }

  static HorizontalGridMetrics _build({
    required AppDimension r,
    required int rows,
    required int itemCount,
    required double cardWidth,
    required double cardHeightFactor,
    required double cardHeightMin,
    required double cardHeightMax,
  }) {
    final safeRows = rows.clamp(1, 3).toInt();
    final horizontalPadding = r.percentWidth(0.025, min: 8, max: 12);
    final verticalPadding = r.percentWidth(0.025, min: 8, max: 12);
    final spacing = r.percentWidth(0.005, min: 3, max: 12);
    final cardHeight = (cardWidth * cardHeightFactor).clamp(cardHeightMin, cardHeightMax).toDouble();
    final contentHeight = (cardHeight * safeRows) + (spacing * (safeRows - 1));
    final sectionHeight = contentHeight + (verticalPadding * 2);
    final columnCount = (itemCount / safeRows).ceil();
    final gridWidth = (horizontalPadding * 2) + (columnCount * cardWidth) + (math.max(0, columnCount - 1) * spacing);
    final viewAllWidth = r.percentWidth(0.28, min: 105, max: r.isTablet ? 180 : 150);

    return HorizontalGridMetrics(
      rows: safeRows,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
      spacing: spacing,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      contentHeight: contentHeight,
      sectionHeight: sectionHeight,
      gridWidth: gridWidth,
      viewAllWidth: viewAllWidth,
    );
  }
}
