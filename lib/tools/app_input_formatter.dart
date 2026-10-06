import 'package:flutter/services.dart';

enum AppInputType { englishLetters, persianLetters, numbers, englishLettersAndNumbers }

class AppInputFormatter {
  AppInputFormatter._();

  static TextInputFormatter allow(AppInputType type) {
    switch (type) {
      case AppInputType.englishLetters:
        return FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'));

      case AppInputType.persianLetters:
        return FilteringTextInputFormatter.allow(RegExp(r'[اآبپتثجچحخدذرزژسشصضطظعغفقکگلمنوهی]'));

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
