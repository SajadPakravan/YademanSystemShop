import 'package:get/get.dart';
import 'package:yad_sys/screens/product/product_images_screen.dart';

class ProductViewModel {

  onTapProductImage({required int imageIndex, required List images}) async => Get.to(
        const ProductImagesScreen(),
        transition: Transition.size,
        duration: const Duration(seconds: 1),
        arguments: {'imageIndex': imageIndex, 'images': images},
      );
}
