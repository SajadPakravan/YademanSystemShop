import 'package:flutter/material.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/cards/view_all_widget.dart';
import 'package:yad_sys/widgets/home/section_header.dart';
import 'package:yad_sys/widgets/post/post_horizontal_card_widget.dart';

class HomePostsSection extends StatelessWidget {
  const HomePostsSection({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final posts = section.posts;
    if (posts.isEmpty) return const SizedBox.shrink();

    final metrics = HorizontalGridMetrics.posts(context, rows: section.layout.rows, itemCount: posts.length);
    final viewAll = section.viewAll;

    return Column(
      children: [
        SectionHeader(section: section),
        SizedBox(
          width: double.infinity,
          height: metrics.sectionHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                SizedBox(
                  width: metrics.gridWidth,
                  height: metrics.sectionHeight,
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: metrics.horizontalPadding, vertical: metrics.verticalPadding),
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    itemCount: posts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: metrics.rows,
                      mainAxisSpacing: metrics.spacing,
                      crossAxisSpacing: metrics.spacing,
                      mainAxisExtent: metrics.cardWidth,
                    ),
                    itemBuilder: (context, index) => PostHorizontalCardWidget(post: posts[index], rows: metrics.rows, length: posts.length, index: index),
                  ),
                ),
                if (viewAll != null) ...[
                  SizedBox(
                    width: metrics.viewAllWidth,
                    height: metrics.contentHeight,
                    child: ViewAllWidget(title: viewAll.title, onTap: () {}),
                  ),
                  SizedBox(width: metrics.horizontalPadding),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
