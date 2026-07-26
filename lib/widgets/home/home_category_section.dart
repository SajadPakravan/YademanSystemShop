import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/category_brand_item_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_item_action_handler.dart';
import 'package:yad_sys/widgets/home/section_header.dart';

class HomeCategorySection extends StatelessWidget {
  const HomeCategorySection({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final items = section.categories;
    if (items.isEmpty) return const SizedBox.shrink();

    final rows = section.layout.rows.clamp(1, 3).toInt();
    final columns = section.layout.columns.clamp(2, 6).toInt();
    final width = MediaQuery.sizeOf(context).width;
    final itemWidth = ((width - 20 - ((columns - 1) * 10)) / columns).clamp(68.0, 150.0).toDouble();
    const itemHeight = 142.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          SectionHeader(section: section),
          SizedBox(
            height: (itemHeight * rows) + ((rows - 1) * 10),
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rows,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: itemWidth,
              ),
              itemBuilder: (context, index) => _CategoryCard(item: items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item});

  final CategoryBrandItemModel item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => SectionItemActionHandler.handle(context: context, type: 'category', title: item.name, destinationId: item.id),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: item.image,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(Icons.category_outlined, color: Colors.black26, size: 48),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
