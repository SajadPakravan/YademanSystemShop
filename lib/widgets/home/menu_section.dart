import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/image_item_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';

class MenuSection extends StatelessWidget {
  const MenuSection({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final items = section.images;
    if (items.isEmpty) return const SizedBox.shrink();
    final rows = section.layout.rows;
    final columns = section.layout.columns == 1 ? 5 : section.layout.columns;
    final width = MediaQuery.sizeOf(context).width;
    final itemWidth = ((width - 40 - ((columns - 1) * 8)) / columns).clamp(76.0, 120.0).toDouble();
    final Color backgroundColor =Colors.grey.shade100;

    return Container(
      height: (rows * 107) + ((rows - 1) * 8),
      margin: EdgeInsets.symmetric(horizontal: 12),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: backgroundColor,border: BoxBorder.all(color: Colors.grey.shade400),borderRadius: BorderRadius.circular(width * 0.08)),
      clipBehavior: Clip.antiAlias,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: rows, mainAxisSpacing: 8, crossAxisSpacing: 8, mainAxisExtent: itemWidth),
        itemBuilder: (context, index) => _MenuCard(item: items[index]),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item});

  final ImageItemModel item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => SectionActionHandler.handle(context: context, action: item.action),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            spacing: 5,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CachedNetworkImage(
                  imageUrl: item.image,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(Icons.apps_rounded, color: Color(0xff0353a4), size: 34),
                ),
              ),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11.5, height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
