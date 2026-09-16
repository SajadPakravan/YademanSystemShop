import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/category_item_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/section_item_action_handler.dart';
import 'package:yad_sys/widgets/home/section_header.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final items = section.categories;
    if (items.isEmpty) return const SizedBox.shrink();

    final rows = section.layout.rows.clamp(1, 3).toInt();
    final r = context.responsive;
    final horizontalPadding = r.pageHorizontalPadding;
    final mainSpacing = r.space(10, min: 7, max: 13);
    final crossSpacing = r.space(12, min: 9, max: 15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(section: section),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.hasBoundedWidth ? constraints.maxWidth : r.width;
            final requestedColumns = section.layout.columns.clamp(1, 8).toInt();
            final actualHorizontalColumns = (items.length / rows).ceil();
            final visibleColumns = math.max(1, math.min(requestedColumns, actualHorizontalColumns));
            final contentWidth = math.max(1.0, availableWidth - (horizontalPadding * 2));
            final calculatedWidth = (contentWidth - ((visibleColumns - 1) * mainSpacing)) / visibleColumns;
            final itemWidth = calculatedWidth.clamp(76.0, r.isTablet ? 170.0 : 148.0).toDouble();
            final imageSize = (itemWidth * 0.72).clamp(58.0, r.isTablet ? 112.0 : 98.0).toDouble();
            final titleHeight = r.space(itemWidth < 94 ? 42 : 48, min: 40, max: 58);
            final verticalPadding = r.space(itemWidth < 94 ? 4 : 6, min: 3, max: 8);
            final itemHeight = verticalPadding + imageSize + r.space(8) + titleHeight + verticalPadding;
            final sectionHeight = (itemHeight * rows) + (crossSpacing * (rows - 1));

            return SizedBox(
              height: sectionHeight,
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                scrollDirection: Axis.horizontal,
                primary: false,
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rows,
                  mainAxisSpacing: mainSpacing,
                  crossAxisSpacing: crossSpacing,
                  mainAxisExtent: itemWidth,
                ),
                itemBuilder: (context, index) => _CategoryCard(
                  item: items[index],
                  imageSize: imageSize,
                  titleHeight: titleHeight,
                  verticalPadding: verticalPadding,
                  compact: itemWidth < 94,
                ),
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
    final colors = context.appColors;
    final r = context.responsive;

    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(r.radius(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(r.radius(14)),
        onTap: () => SectionItemActionHandler.handle(context: context, type: 'category', title: item.name, destinationId: item.id),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.space(3), vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: imageSize,
                child: Center(child: SizedBox(width: imageSize, height: imageSize, child: _CategoryImage(imageUrl: item.image))),
              ),
              SizedBox(height: r.space(8)),
              SizedBox(
                height: titleHeight,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AppText.bodySmall(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    fontSize: compact ? 10.5 : 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
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
    final colors = context.appColors;
    final r = context.responsive;

    return CachedNetworkImage(
      width: double.infinity,
      height: double.infinity,
      imageUrl: url,
      fit: BoxFit.contain,
      fadeInDuration: const Duration(milliseconds: 160),
      placeholder: (context, url) => Center(
        child: SizedBox(width: r.icon(20), height: r.icon(20), child: const CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => ColoredBox(
        color: colors.surfaceVariant,
        child: Center(child: Icon(Icons.category_outlined, color: colors.textMuted, size: r.icon(42))),
      ),
    );
  }
}
