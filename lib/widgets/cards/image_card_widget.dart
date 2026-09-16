import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/image_item_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/section_action_handler.dart';

class ImageCardWidget extends StatelessWidget {
  const ImageCardWidget({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final items = section.images;
    if (items.isEmpty) return const SizedBox.shrink();

    final r = context.responsive;
    final horizontalPadding = r.space(10, min: 8, max: 16);
    final spacing = r.space(8, min: 6, max: 12);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth ? constraints.maxWidth : r.width;
        final layout = _resolveLayout(
          itemCount: items.length,
          requestedRows: section.layout.rows,
          requestedColumns: section.layout.columns,
        );
        final contentWidth = math.max(0.0, availableWidth - (horizontalPadding * 2));
        final itemWidth = math.max(1.0, (contentWidth - ((layout.columns - 1) * spacing)) / layout.columns);
        final aspectRatio = ((16 / 9) * math.sqrt(layout.rows / layout.columns)).clamp(0.9, 1.9).toDouble();
        final itemHeight = (itemWidth / aspectRatio).clamp(r.space(90), r.isTablet ? 520.0 : 420.0).toDouble();

        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: layout.columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: itemHeight,
          ),
          itemBuilder: (context, index) => _ImageCard(item: items[index]),
        );
      },
    );
  }

  _ResolvedImageLayout _resolveLayout({required int itemCount, required int requestedRows, required int requestedColumns}) {
    final safeItemCount = math.max(1, itemCount);
    final safeRows = math.max(1, requestedRows);
    final safeColumns = math.max(1, requestedColumns);
    late final int columns;

    if (safeItemCount == 1) {
      columns = 1;
    } else if (safeRows > 1 && safeColumns == 1) {
      columns = (safeItemCount / safeRows).ceil();
    } else if (safeColumns > 1) {
      columns = math.min(safeColumns, safeItemCount);
    } else {
      columns = safeItemCount;
    }
    final rows = (safeItemCount / columns).ceil();
    return _ResolvedImageLayout(rows: rows, columns: columns);
  }
}

class _ResolvedImageLayout {
  const _ResolvedImageLayout({required this.rows, required this.columns});

  final int rows;
  final int columns;
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.item});

  final ImageItemModel item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.image.trim();
    final colors = context.appColors;
    final r = context.responsive;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(r.radius(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => SectionActionHandler.handle(context: context, action: item.action),
        child: imageUrl.isEmpty
            ? const _ImageErrorPlaceholder()
            : CachedNetworkImage(
                width: double.infinity,
                height: double.infinity,
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                fadeInDuration: const Duration(milliseconds: 180),
                placeholder: (context, url) => const _ImageLoadingPlaceholder(),
                errorWidget: (context, url, error) => const _ImageErrorPlaceholder(),
              ),
      ),
    );
  }
}

class _ImageLoadingPlaceholder extends StatelessWidget {
  const _ImageLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return ColoredBox(
      color: context.appColors.surfaceVariant,
      child: Center(
        child: SizedBox(
          width: r.icon(24),
          height: r.icon(24),
          child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.appColors.surfaceVariant,
      child: Center(child: Icon(Icons.broken_image_outlined, color: context.appColors.textMuted, size: context.responsive.icon(36))),
    );
  }
}
