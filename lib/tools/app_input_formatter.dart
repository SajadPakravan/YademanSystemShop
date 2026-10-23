import 'package:flutter/services.dart';

enum AppInputType { englishLetters, sPersianLetters, snPersianLetters, snvPersianLetters, numbers, englishLettersAndNumbers }

class AppInputFormatter {
  AppInputFormatter._();

  static TextInputFormatter allow(AppInputType type) {
    switch (type) {
      case AppInputType.englishLetters:
        return FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'));

      case AppInputType.sPersianLetters:
        return FilteringTextInputFormatter.allow(RegExp(r'[اآأإءؤئبپتثجچحخدذرزژسشصضطظعغفقکگلمنوهیيك \u200C]'));

      case AppInputType.snPersianLetters:
        return FilteringTextInputFormatter.allow(RegExp(r'[اآأإءؤئبپتثجچحخدذرزژسشصضطظعغفقکگلمنوهیيك 0-9۰-۹\u200C]'));

      case AppInputType.snvPersianLetters:
        return FilteringTextInputFormatter.allow(RegExp(r'[اآأإءؤئبپتثجچحخدذرزژسشصضطظعغفقکگلمنوهیيك ،:.؛ 0-9۰-۹\u200C]'));

      case AppInputType.numbers:
        return FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));

      case AppInputType.englishLettersAndNumbers:
        return FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'));
    }
  }

  static List<TextInputFormatter> formatters(AppInputType type, {int? maxLength}) {
    return [allow(type), if (maxLength != null) LengthLimitingTextInputFormatter(maxLength)];
  }
}
