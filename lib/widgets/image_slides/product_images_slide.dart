import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';

// ignore: must_be_immutable
class ProductImagesSlide extends StatelessWidget {
  ProductImagesSlide({
    super.key,
    required this.currentSlide,
    required this.moveSlide,
    required this.json,
  });

  CarouselSliderController slideCtrl = CarouselSliderController();
  Function moveSlide;
  int currentSlide = 0;
  double circleSlideWidth = 0;
  double circleSlideHeight = 0;
  Color circleSlideColor = Colors.black;
  List<Widget> itemSlider = [];
  List<String> imageList = [];
  HttpRequest httpRequest = HttpRequest();
  dynamic json;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    getProductImages();

    return Container(
      color: Colors.blue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CarouselSlider(
            items: itemSlider,
            carouselController: slideCtrl,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.5,
              viewportFraction: 1,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                moveSlide(index);
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: width * 0.2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: imageList.asMap().entries.map((entry) {
                  circleSlideStyle(width: width, entry: entry);
                  return InkWell(
                    child: Container(
                      margin: EdgeInsets.all(width * 0.01),
                      child: CachedNetworkImage(imageUrl: entry.value, fit: BoxFit.contain),
                    ),
                    onTap: () {
                      slideCtrl.animateToPage(1);
                    }
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  circleSlideStyle({required double width, required MapEntry entry}) {
    if (currentSlide == entry.key) {
      circleSlideWidth = width * 0.2;
      circleSlideHeight = width * 0.2;
      circleSlideColor = Colors.black54;
    } else {
      circleSlideWidth = width * 0.1;
      circleSlideHeight = width * 0.1;
      circleSlideColor = Colors.black38;
    }
  }

  getProductImages() async {
    List jsonProductImages = [];
    jsonProductImages = json['images'];
    imageList.clear();
    itemSlider.clear();

    for (var i = 0; i < jsonProductImages.length; i++) {
      imageList.add(jsonProductImages[i]['src']);
    }
    itemSlider = imageList
        .map(
          (item) => CachedNetworkImage(imageUrl: item, fit: BoxFit.contain),
        )
        .toList();
  }
}
