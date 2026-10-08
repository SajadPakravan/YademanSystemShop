import 'package:flutter/foundation.dart';

/// ابزار یکپارچه نمایش لاگ‌های پروژه با رنگ‌های ثابت و شرایط قابل تنظیم.
class AppLog {
  /// جلوگیری از ایجاد نمونه؛ تمام متدها به صورت static استفاده می‌شوند.
  AppLog._();

  /// فعال یا غیرفعال کردن تمام لاگ‌های پروژه به صورت سراسری.
  static bool enabled = true;

  /// فعال یا غیرفعال کردن رنگ ANSI در خروجی ترمینال.
  static bool useColors = true;

  /// کدهای رنگ ثابت برای انواع لاگ.
  static const String _blue = '\x1B[34m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _reset = '\x1B[0m';

  /// نمایش لاگ اطلاعات عمومی با رنگ آبی.
  /// [when] شرط اختیاری نمایش و [debugOnly] محدودیت اختیاری حالت Debug است.
  static void info(
    Object? message, {
    bool when = true,
    bool debugOnly = true,
  }) {
    _write('INFO', message, _blue, when: when, debugOnly: debugOnly);
  }

  /// نمایش لاگ خطا با رنگ قرمز.
  /// [when] شرط اختیاری نمایش و [debugOnly] محدودیت اختیاری حالت Debug است.
  static void error(
    Object? message, {
    bool when = true,
    bool debugOnly = true,
  }) {
    _write('ERROR', message, _red, when: when, debugOnly: debugOnly);
  }

  /// نمایش لاگ پاسخ سرور با رنگ سبز.
  /// [when] شرط اختیاری نمایش و [debugOnly] محدودیت اختیاری حالت Debug است.
  static void response(
    Object? message, {
    bool when = true,
    bool debugOnly = true,
  }) {
    _write('RESPONSE', message, _green, when: when, debugOnly: debugOnly);
  }

  /// بررسی تنظیمات و نمایش نهایی لاگ؛ منطق تکراری تمام متدها در اینجا متمرکز است.
  static void _write(
    String type,
    Object? message,
    String color, {
    required bool when,
    required bool debugOnly,
  }) {
    // اگر ثبت لاگ غیرفعال باشد، شرط اختصاصی برقرار نباشد، یا حالت Debug لازم باشد، خروج می‌کنیم.
    if (!enabled || !when || (debugOnly && !kDebugMode)) return;

    // متن خروجی را با برچسب نوع لاگ می‌سازیم.
    final text = '[$type] $message';

    // در صورت پشتیبانی کنسول، رنگ را با ANSI اعمال می‌کنیم و در پایان بازنشانی می‌کنیم.
    debugPrint(useColors ? '$color$text$_reset' : text);
  }
}
