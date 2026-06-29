import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/tools/go_page.dart';

class ProductImageCard extends StatefulWidget {
  const ProductImageCard({super.key, required this.list, this.physics = const AlwaysScrollableScrollPhysics()});

  final ScrollPhysics physics;
  final List<ProductModel> list;

  @override
  State<ProductImageCard> createState() => _ProductImageCardState();
}

class _ProductImageCardState extends State<ProductImageCard> {
  final AppFunction appFun = AppFunction();
  BorderSide borderSideTop = BorderSide.none;
  BorderSide borderSideBottom = BorderSide.none;
  BorderSide borderSideLeft = BorderSide.none;
  BorderSide borderSideRight = BorderSide.none;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: 9,
      scrollDirection: Axis.vertical,
      physics: widget.physics,
      shrinkWrap: true,
      primary: false,
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context, int index) {
        ProductModel product = widget.list[index];
        ProductImage img = product.images![0];
        switch (index) {
          case 0:
          case 2:
          case 3:
          case 5:
            {
              border(borderSideBottom: const BorderSide(color: Colors.black38));
              break;
            }
          case 1:
          case 4:
            {
              border(
                borderSideBottom: const BorderSide(color: Colors.black38),
                borderSideLeft: const BorderSide(color: Colors.black38),
                borderSideRight: const BorderSide(color: Colors.black38),
              );
              break;
            }
          case 7:
            {
              border(
                borderSideLeft: const BorderSide(color: Colors.black38),
                borderSideRight: const BorderSide(color: Colors.black38),
              );
              break;
            }
          case 6:
          case 8:
            {
              border();
              break;
            }
        }
        return InkWell(
          onTap: () => toProduct(product: product),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border(
                top: borderSideTop,
                bottom: borderSideBottom,
                left: borderSideLeft,
                right: borderSideRight,
              ),
            ),
            child: CachedNetworkImage(
              imageUrl: img.src!,
              fit: BoxFit.contain,
              errorWidget: (context, str, dyn) => const Icon(Icons.image, color: Colors.black26, size: 100),
            ),
          ),
        );
      },
    );
  }

  border({
    BorderSide borderSideTop = BorderSide.none,
    BorderSide borderSideBottom = BorderSide.none,
    BorderSide borderSideLeft = BorderSide.none,
    BorderSide borderSideRight = BorderSide.none,
  }) {
    this.borderSideTop = borderSideTop;
    this.borderSideBottom = borderSideBottom;
    this.borderSideLeft = borderSideLeft;
    this.borderSideRight = borderSideRight;
  }
}
