import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/cards/product_card_widget.dart';

class DiscountedProductsWidget extends StatefulWidget {
  const DiscountedProductsWidget({super.key, required this.section, required this.products});

  final SectionModel section;
  final List<ProductCardModel> products;

  @override
  State<DiscountedProductsWidget> createState() => _DiscountedProductsWidgetState();
}

class _DiscountedProductsWidgetState extends State<DiscountedProductsWidget> {
  @override
  Widget build(BuildContext context) {
    final rows = widget.section.layout.rows;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth * 0.46).clamp(168.0, 220.0).toDouble();
    const cardHeight = 304.0;
    final direction = widget.section.layout.isHorizontal ? Axis.horizontal : Axis.vertical;
    final hasViewAll = widget.section.viewAll != null;

    return Container(
      height: (cardHeight * rows) + ((rows - 1) * 10),
      decoration: BoxDecoration(color: Colors.blue),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: direction,
        itemCount: widget.products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: rows, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: cardWidth),
        itemBuilder: (context, index) {
          return SizedBox(
            height: (cardHeight * rows) + ((rows - 1) * 10),
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://yademansystem.ir/wp-content/uploads/2023/02/amazings.png',
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined, color: Colors.black26, size: 56),
                ),
                ProductCardWidget(product: widget.products[index]),
                if (hasViewAll)
                  TextButton(
                    onPressed: () => SectionActionHandler.handle(context: context, action: widget.section.viewAll!.action),
                    child: Text(widget.section.viewAll!.title),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
