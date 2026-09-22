import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/image_item_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class MenuSection extends StatelessWidget {
  const MenuSection({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final items = section.images;
    if (items.isEmpty) return const SizedBox.shrink();

    final rows = section.layout.rows.clamp(1, 3).toInt();
    final columns = section.layout.columns == 1 ? 5 : section.layout.columns.clamp(2, 6).toInt();
    final r = context.responsive;
    final colors = context.appColors;
    final spacing = r.space(8, min: 6, max: 11);
    final horizontalMargin = r.pageHorizontalPadding;
    final available = r.width - (horizontalMargin * 2) - ((columns - 1) * spacing);
    final itemWidth = (available / columns).clamp(68.0, r.isTablet ? 145.0 : 112.0).toDouble();
    final iconSize = (itemWidth * 0.58).clamp(42.0, 66.0).toDouble();
    final rowHeight = iconSize + r.space(48, min: 42, max: 56);

    return Container(
      height: (rows * rowHeight) + ((rows - 1) * spacing),
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: EdgeInsets.symmetric(vertical: r.space(10)),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(r.radius(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rows,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          mainAxisExtent: itemWidth,
        ),
        itemBuilder: (context, index) => _MenuCard(item: items[index], iconSize: iconSize),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item, required this.iconSize});

  final ImageItemModel item;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(r.cardRadius),
        // onTap: () => SectionActionHandler.handle(context: context, action: item.action),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.space(3)),
          child: Column(
            children: [
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: CachedNetworkImage(
                  imageUrl: item.image,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => Icon(Icons.apps_rounded, color: AppColors.primary, size: r.icon(34)),
                ),
              ),
              SizedBox(height: r.space(5)),
              Expanded(
                child: AppText.bodySmall(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
