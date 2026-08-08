import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/category_item_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_item_action_handler.dart';
import 'package:yad_sys/widgets/home/section_header.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key, required this.section});

  final SectionModel section;

  static const double _horizontalPadding = 10;
  static const double _mainAxisSpacing = 10;
  static const double _crossAxisSpacing = 12;

  @override
  Widget build(BuildContext context) {
    final items = section.categories;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final rows = section.layout.rows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(section: section),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.hasBoundedWidth ? constraints.maxWidth : MediaQuery.sizeOf(context).width;
            final requestedColumns = section.layout.columns;
            final actualHorizontalColumns = (items.length / rows).ceil();
            final visibleColumns = math.max(1, math.min(requestedColumns, actualHorizontalColumns));
            final contentWidth = math.max(1.0, availableWidth - (_horizontalPadding * 2));
            final calculatedWidth = (contentWidth - ((visibleColumns - 1) * _mainAxisSpacing)) / visibleColumns;
            final itemWidth = calculatedWidth.clamp(82.0, 148.0).toDouble();
            final imageSize = (itemWidth * 0.72).clamp(62.0, 98.0).toDouble();
            final titleHeight = itemWidth < 94 ? 43.0 : 48.0;
            final cardVerticalPadding = itemWidth < 94 ? 4.0 : 6.0;
            final itemHeight = cardVerticalPadding + imageSize + 8 + titleHeight + cardVerticalPadding;
            final sectionHeight = (itemHeight * rows) + (_crossAxisSpacing * (rows - 1));

            return SizedBox(
              height: sectionHeight,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                scrollDirection: Axis.horizontal,
                primary: false,
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rows,
                  mainAxisSpacing: _mainAxisSpacing,
                  crossAxisSpacing: _crossAxisSpacing,
                  mainAxisExtent: itemWidth,
                ),
                itemBuilder: (context, index) {
                  return _CategoryCard(
                    item: items[index],
                    imageSize: imageSize,
                    titleHeight: titleHeight,
                    verticalPadding: cardVerticalPadding,
                    compact: itemWidth < 94,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item, required this.imageSize, required this.titleHeight, required this.verticalPadding, required this.compact});

  final CategoryItemModel item;
  final double imageSize;
  final double titleHeight;
  final double verticalPadding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => SectionItemActionHandler.handle(context: context, type: 'category', title: item.name, destinationId: item.id),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3, vertical: verticalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: imageSize,
                child: Center(
                  child: SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: _CategoryImage(imageUrl: item.image),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: titleHeight,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    strutStyle: StrutStyle(fontSize: compact ? 10.5 : 11.5, height: 1.45, forceStrutHeight: true),
                    style: TextStyle(fontSize: compact ? 10.5 : 11.5, height: 1.45, fontWeight: FontWeight.w600, color: const Color(0xff20242a)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();

    return CachedNetworkImage(
      width: double.infinity,
      height: double.infinity,
      imageUrl: url,
      fit: BoxFit.contain,
      fadeInDuration: const Duration(milliseconds: 160),
      placeholder: (context, url) => const Center(
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff0353a4))),
      ),
      errorWidget: (context, url, error) => const _CategoryImageFallback(),
    );
  }
}

class _CategoryImageFallback extends StatelessWidget {
  const _CategoryImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xffeef6ff),
      child: Center(child: Icon(Icons.category_outlined, color: Color(0xff7b92a8), size: 42)),
    );
  }
}
