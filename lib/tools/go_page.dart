import 'package:get/get.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/screens/product/product_screen.dart';

Future<dynamic>? rightToPage(dynamic page, {dynamic arguments}) {
  return Get.to(page, transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300), arguments: arguments);
}

Future<dynamic>? zoomToPage(dynamic page, {dynamic arguments}) {
  return Get.to(page, transition: Transition.zoom, duration: const Duration(milliseconds: 300), arguments: arguments);
}

dynamic toProduct({ProductModel? product, int? id}) => zoomToPage(const ProductScreen(), arguments: {'product': product, 'id': id});
