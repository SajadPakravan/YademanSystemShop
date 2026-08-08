import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/brand_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_item_action_handler.dart';
import 'package:yad_sys/widgets/home/section_header.dart';

class HomeBrandSection extends StatelessWidget {
  const HomeBrandSection({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final items = section.brands;
    if (items.isEmpty) return const SizedBox.shrink();

    final rows = section.layout.rows.clamp(1, 3).toInt();
    final columns = section.layout.columns.clamp(2, 6).toInt();
    final width = MediaQuery.sizeOf(context).width;
    final itemWidth = ((width - 20 - ((columns - 1) * 10)) / columns).clamp(68.0, 150.0).toDouble();
    const itemHeight = 106.0;

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
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rows,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => SectionItemActionHandler.handle(context: context, type: 'brand', title: item.name, destinationId: item.id),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Expanded(
                child: item.image.isEmpty
                    ? const Icon(Icons.workspace_premium_outlined, color: Colors.black26, size: 38)
                    : CachedNetworkImage(
                        imageUrl: item.image,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) => const Icon(Icons.workspace_premium_outlined, color: Colors.black26, size: 38),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                item.name,
                maxLines: 1,
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
