import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/connections/http_request.dart';

class ProductImagesScreen extends StatefulWidget {
  const ProductImagesScreen({super.key});

  @override
  State<ProductImagesScreen> createState() => _ProductImagesScreenState();
}

class _ProductImagesScreenState extends State<ProductImagesScreen> {
  HttpRequest httpRequest = HttpRequest();
  CarouselSliderController slideCtrl = CarouselSliderController();
  int currentSlide = 0;
  bool getCurrentSlide = true;
  double slideWidth = 0;
  double slideHeight = 0;
  Color slideColor = Colors.black;
  List<Widget> itemSlider = [];
  List<String> imageList = [];
  bool imageItemVis = true;

  getProductImages() async {
    setState(() {
      imageList = Get.arguments["images"];
    });

    itemSlider = imageList
        .map(
          (item) => InteractiveViewer(
            panEnabled: false,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 2,
            child: Image.network(
              item,
              fit: BoxFit.contain,
              frameBuilder: (BuildContext context, Widget child, int? frame, bool? wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded!) {
                  return child;
                }
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
            ),
            onInteractionStart: (scaleStartDetails) {
              setState(() {
                imageItemVis = false;
              });
            },
            onInteractionEnd: (scaleEndDetails) {
              setState(() {
                imageItemVis = true;
              });
            },
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    getProductImages();
    if (getCurrentSlide) {
      setState(() {
        currentSlide = Get.arguments["imageIndex"];
        if (kDebugMode) {
          print("imageIndex >>>> $currentSlide");
        }
        getCurrentSlide = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: appBar(),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            items: itemSlider,
            carouselController: slideCtrl,
            disableGesture: true,
            options: CarouselOptions(
              height: height,
              viewportFraction: 1,
              initialPage: currentSlide,
              scrollPhysics: const NeverScrollableScrollPhysics(),
              padEnds: false,
              onPageChanged: (index, reason) {
                setState(() {
                  currentSlide = index;
                });
              },
            ),
          ),
          Visibility(
            visible: imageItemVis,
            child: Container(
              alignment: Alignment.center,
              height: width * 0.25,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: imageList.asMap().entries.map((entry) {
                    circleSlideStyle(width: width, entry: entry);
                    return InkWell(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.all(width * 0.01),
                              width: slideWidth,
                              height: slideHeight,
                              child: Image.network(entry.value, fit: BoxFit.contain),
                            ),
                            Container(
                              width: width * 0.15,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: slideColor,
                                ),
                                borderRadius: BorderRadius.circular(width),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          slideCtrl.animateToPage(
                            entry.key,
                            duration: const Duration(
                              milliseconds: 500,
                            ),
                          );
                        });
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black54),
    );
  }

  circleSlideStyle({required double width, required MapEntry entry}) {
    if (currentSlide == entry.key) {
      slideWidth = width * 0.2;
      slideHeight = width * 0.2;
      slideColor = Colors.red;
    } else {
      slideWidth = width * 0.1;
      slideHeight = width * 0.1;
      slideColor = Colors.transparent;
    }
  }
}
