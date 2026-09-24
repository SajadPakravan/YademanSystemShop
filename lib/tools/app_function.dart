import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:flutter/material.dart';

class AppFunction {
  static String faDigit(Object value) => value.toString().toPersianDigit();

  static String faPrice(int value) => value.toString().toPersianDigit().seRagham();

  static BorderRadius borderRadius(int index, int rows, int length) {
    final i = index + 1;
    if (rows > 1) {
      if (i <= rows) {
        if (i == 1) return const BorderRadius.only(topRight: Radius.circular(12));
        if (rows - i == 0) return const BorderRadius.only(bottomRight: Radius.circular(12));
      }
      if (i >= length - (rows - 1)) {
        if (i - (length - (rows - 1)) == 0) return const BorderRadius.only(topLeft: Radius.circular(12));
        if (i == length) return const BorderRadius.only(bottomLeft: Radius.circular(12));
      }
    } else {
      if (i == 1) return const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12));
      if (i == length) return const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12));
    }
    return BorderRadius.zero;
  }
}
