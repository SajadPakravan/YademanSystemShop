import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/cards/view_all_widget.dart';
import 'package:yad_sys/widgets/product/product_vertical_card_widget.dart';

class DiscountedProductsWidget extends StatefulWidget {
  const DiscountedProductsWidget({super.key, required this.section, required this.products});

  final SectionModel section;
  final List<ProductCardModel> products;

  @override
  State<DiscountedProductsWidget> createState() => _DiscountedProductsWidgetState();
}

class _DiscountedProductsWidgetState extends State<DiscountedProductsWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.section.layout.rows.clamp(1, 3).toInt();
    final hasViewAll = widget.section.viewAll != null;
    final logoSpacerCount = rows;
    final itemCount = logoSpacerCount + widget.products.length + (hasViewAll ? 1 : 0);

    if (widget.products.isEmpty && !hasViewAll) return const SizedBox.shrink();

    final metrics = HorizontalGridMetrics.verticalProducts(
      context,
      rows: rows,
      itemCount: itemCount,
    );

    return Container(
      width: double.infinity,
      height: metrics.sectionHeight,
      padding: EdgeInsets.symmetric(vertical: metrics.verticalPadding),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[AppColors.promoBright, AppColors.primaryDark, AppColors.promoDeep],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PositionedDirectional(
            top: 0,
            bottom: 0,
            start: metrics.horizontalPadding,
            width: metrics.cardWidth,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  final progress = _logoCoverProgress(cardWidth: metrics.cardWidth, spacing: metrics.spacing);
                  return _AmazingLogo(progress: progress);
                },
              ),
            ),
          ),
          GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: metrics.rows,
              mainAxisSpacing: metrics.spacing,
              crossAxisSpacing: metrics.spacing,
              mainAxisExtent: metrics.cardWidth,
            ),
            itemBuilder: (context, index) {
              if (index < logoSpacerCount) return const SizedBox.expand();

              final contentIndex = index - logoSpacerCount;
              if (contentIndex < widget.products.length) {
                return ProductVerticalCardWidget(
                  product: widget.products[contentIndex],
                  rows: metrics.rows,
                  length: widget.products.length,
                  index: contentIndex,
                );
              }

              final viewAll = widget.section.viewAll!;
              return ViewAllWidget(
                title: viewAll.title,
                onTap: () => SectionActionHandler.handle(context: context, action: viewAll.action),
                foregroundColor: AppColors.onBrand,
              );
            },
          ),
        ],
      ),
    );
  }

  double _logoCoverProgress({required double cardWidth, required double spacing}) {
    if (!_scrollController.hasClients) return 0;
    final position = _scrollController.position;
    final coverDistance = cardWidth + spacing;
    final traveledDistance = (position.pixels - position.minScrollExtent).abs();
    return (traveledDistance / coverDistance).clamp(0.0, 1.0).toDouble();
  }
}

class _AmazingLogo extends StatelessWidget {
  const _AmazingLogo({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
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
            padding: EdgeInsets.symmetric(vertical: r.space(26, min: 20, max: 34)),
            child: CachedNetworkImage(
              imageUrl: 'https://yademansystem.ir/wp-content/uploads/2023/02/amazings.png',
              fit: BoxFit.contain,
              placeholder: (context, url) => Center(
                child: SizedBox(
                  width: r.icon(24),
                  height: r.icon(24),
                  child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.onBrand),
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Icon(Icons.bolt_rounded, color: AppColors.onBrand, size: r.icon(54)),
              ),
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
      red + ((1 - red) * s), green - (green * s), blue - (blue * s), 0, 0,
      red - (red * s), green + ((1 - green) * s), blue - (blue * s), 0, 0,
      red - (red * s), green - (green * s), blue + ((1 - blue) * s), 0, 0,
      0, 0, 0, 1, 0,
    ];
  }
}
