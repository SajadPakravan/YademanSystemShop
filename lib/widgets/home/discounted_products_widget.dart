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
  static const double _cardHeight = 300;
  static const double _verticalPadding = 20;
  static const double _rowSpacing = 10;

  @override
  Widget build(BuildContext context) {
    final rows = widget.section.layout.rows.clamp(1, 3).toInt();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth * 0.35).clamp(150.0, 220.0).toDouble();
    final contentHeight = (_cardHeight * rows) + (_rowSpacing * (rows - 1));
    final hasViewAll = widget.section.viewAll != null;
    final itemCount = widget.products.length + (hasViewAll ? 1 : 0);

    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: contentHeight + (_verticalPadding * 2),
      padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xff0868c7), Color(0xff034b91), Color(0xff022f5f)]),
      ),
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount + 1,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rows,
          mainAxisSpacing: 3,
          crossAxisSpacing: _rowSpacing,
          mainAxisExtent: cardWidth,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _AmazingLogo();
          }

          if (index < itemCount) {
            return ProductCardWidget(product: widget.products[index - 1], length: widget.products.length, index: index - 1);
          }

          final viewAll = widget.section.viewAll!;

          return _ViewAllCard(
            title: viewAll.title,
            onTap: () => SectionActionHandler.handle(context: context, action: viewAll.action),
          );
        },
      ),
    );
  }
}

class _AmazingLogo extends StatelessWidget {
  const _AmazingLogo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: CachedNetworkImage(
        imageUrl: 'https://yademansystem.ir/wp-content/uploads/2023/02/amazings.png',
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        ),
        errorWidget: (context, url, error) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Icon(Icons.bolt_rounded, color: Colors.white, size: 54)],
        ),
      ),
    );
  }
}

class _ViewAllCard extends StatelessWidget {
  const _ViewAllCard({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xff0b74d5), Color(0xff034b91)]),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 31),
                ),
                const SizedBox(height: 18),
                Text(
                  title.isEmpty ? 'مشاهده همه' : title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xff034b91), fontSize: 15, fontWeight: FontWeight.w800, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
