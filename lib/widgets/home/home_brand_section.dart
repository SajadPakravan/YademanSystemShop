import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/brand_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/home/section_header.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class HomeBrandSection extends StatelessWidget {
  const HomeBrandSection({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final items = section.brands;
    if (items.isEmpty) return const SizedBox.shrink();

    final rows = section.layout.rows.clamp(1, 3).toInt();
    final columns = section.layout.columns.clamp(2, 6).toInt();
    final r = context.responsive;
    final spacing = r.space(10, min: 7, max: 13);
    final horizontalPadding = r.pageHorizontalPadding;
    final itemWidth = ((r.width - (horizontalPadding * 2) - ((columns - 1) * spacing)) / columns).clamp(64.0, r.isTablet ? 170.0 : 150.0).toDouble();
    final itemHeight = r.space(106, min: 96, max: 126);

    return Padding(
      padding: EdgeInsets.only(bottom: r.sectionVerticalGap),
      child: Column(
        children: [
          SectionHeader(section: section),
          SizedBox(
            height: (itemHeight * rows) + ((rows - 1) * spacing),
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rows,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                mainAxisExtent: itemWidth,
              ),
              itemBuilder: (context, index) => _BrandCard(item: items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.item});

  final BrandModel item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(r.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(r.cardRadius),
        // onTap: () => SectionItemActionHandler.handle(context: context, type: 'brand', title: item.name, destinationId: item.id),
        child: Container(
          padding: EdgeInsets.all(r.space(10)),
          decoration: BoxDecoration(border: Border.all(color: colors.border), borderRadius: BorderRadius.circular(r.cardRadius)),
          child: Column(
            children: [
              Expanded(
                child: item.image.isEmpty
                    ? Icon(Icons.workspace_premium_outlined, color: colors.textMuted, size: r.icon(38))
                    : CachedNetworkImage(
                        imageUrl: item.image,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) => Icon(Icons.workspace_premium_outlined, color: colors.textMuted, size: r.icon(38)),
                      ),
              ),
              SizedBox(height: r.space(6)),
              AppText.bodySmall(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, fontWeight: FontWeight.w600),
            ],
          ),
        ),
      ),
    );
  }
}
