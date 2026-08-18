import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/screens/categories/see_all_screen.dart';

class AppFunction {
  Future<Future<dynamic>?>? onTapShowAll({required String title, String category = '', String onSale = ''}) async => Get.to(
        const ShowAllScreen(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
        arguments: {'title': title, 'category': category, 'onSale': onSale},
      );

  static String faDigit(Object value) => value.toString().toPersianDigit();

  static String faPrice(int value) => value.toString().toPersianDigit().seRagham();
}
