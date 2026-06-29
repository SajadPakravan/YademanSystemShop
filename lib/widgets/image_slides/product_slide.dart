import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/view_models/product_view_model.dart';

class ProductSlide extends StatefulWidget {
  const ProductSlide({super.key, required this.product, required this.slideIndex, required this.onSlideChange});

  final ProductModel product;
  final int slideIndex;
  final Function onSlideChange;

  @override
  State<ProductSlide> createState() => _ProductSlideState();
}

class _ProductSlideState extends State<ProductSlide> {
  final PageController pageCtrl = PageController();

  List<Widget> itemSlider = [];

  @override
  Widget build(BuildContext context) {
    getProductImages();
    return Container(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: PageView(onPageChanged: (index) => widget.onSlideChange(index), controller: pageCtrl, children: itemSlider),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 5, bottom: 10),
            child: SmoothPageIndicator(
              controller: pageCtrl,
              count: widget.product.images!.length,
              effect: const ScrollingDotsEffect(dotHeight: 10, dotWidth: 10, activeDotColor: ColorStyle.blueFav),
            ),
          ),
        ],
      ),
    );
  }

  getProductImages() async {
    List<String> imgLst = [];
    for (var i = 0; i < widget.product.images!.length; i++) {
      ProductImage img = widget.product.images![i];
      imgLst.add(img.src!);
    }
    itemSlider = imgLst
        .map(
          (item) => InkWell(
            child: CachedNetworkImage(imageUrl: item, fit: BoxFit.contain),
            onTap: () {
              ProductViewModel productViewModel = ProductViewModel();
              productViewModel.onTapProductImage(imageIndex: widget.slideIndex, images: imgLst);
            },
          ),
        )
        .toList();
  }
}
