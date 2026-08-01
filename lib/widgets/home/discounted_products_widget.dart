import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/product/product_vertical_card_widget.dart';
import 'package:yad_sys/widgets/cards/view_all_widget.dart';

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
  static const double _mainAxisSpacing = 3;
  static const double _horizontalPadding = 20;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.section.layout.rows.clamp(1, 3).toInt();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth * 0.35).clamp(150.0, 220.0).toDouble();
    final contentHeight = (_cardHeight * rows) + (_rowSpacing * (rows - 1));
    final hasViewAll = widget.section.viewAll != null;
    final logoSpacerCount = rows;
    final itemCount = logoSpacerCount + widget.products.length + (hasViewAll ? 1 : 0);

    if (widget.products.isEmpty && !hasViewAll) {
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            right: _horizontalPadding,
            width: cardWidth,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  final progress = _logoCoverProgress(cardWidth: cardWidth);
                  return _AmazingLogo(progress: progress);
                },
              ),
            ),
          ),
          GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: rows,
              mainAxisSpacing: _mainAxisSpacing,
              crossAxisSpacing: _rowSpacing,
              mainAxisExtent: cardWidth,
            ),
            itemBuilder: (context, index) {
              if (index < logoSpacerCount) {
                return const SizedBox.expand();
              }

              final contentIndex = index - logoSpacerCount;

              if (contentIndex < widget.products.length) {
                return ProductVerticalCardWidget(product: widget.products[contentIndex], rows: rows, length: widget.products.length, index: contentIndex);
              }

              final viewAll = widget.section.viewAll!;

              return ViewAllWidget(
                title: viewAll.title,
                onTap: () => SectionActionHandler.handle(context: context, action: viewAll.action),
                foregroundColor: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  double _logoCoverProgress({required double cardWidth}) {
    if (!_scrollController.hasClients) {
      return 0;
    }

    final position = _scrollController.position;
    final coverDistance = cardWidth + _mainAxisSpacing;
    final traveledDistance = (position.pixels - position.minScrollExtent).abs();
    return (traveledDistance / coverDistance).clamp(0.0, 1.0).toDouble();
  }
}

class _AmazingLogo extends StatelessWidget {
  const _AmazingLogo({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0).toDouble();
    final scale = 1.0 - (0.14 * normalizedProgress);
    final opacity = 1.0 - (0.62 * normalizedProgress);
    final saturation = 1.0 - normalizedProgress;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(_saturationMatrix(saturation)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: CachedNetworkImage(
              imageUrl: 'https://yademansystem.ir/wp-content/uploads/2023/02/amazings.png',
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              ),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.bolt_rounded, color: Colors.white, size: 54)),
            ),
          ),
        ),
      ),
    );
  }

  static List<double> _saturationMatrix(double saturation) {
    final s = saturation.clamp(0.0, 1.0).toDouble();
    const red = 0.2126;
    const green = 0.7152;
    const blue = 0.0722;

    return <double>[
      red + ((1 - red) * s),
      green - (green * s),
      blue - (blue * s),
      0,
      0,
      red - (red * s),
      green + ((1 - green) * s),
      blue - (blue * s),
      0,
      0,
      red - (red * s),
      green - (green * s),
      blue + ((1 - blue) * s),
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}
