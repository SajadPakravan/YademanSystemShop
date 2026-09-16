import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/post_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class PostHorizontalCardWidget extends StatelessWidget {
  const PostHorizontalCardWidget({
    super.key,
    required this.post,
    required this.rows,
    required this.length,
    required this.index,
  });

  final PostModel post;
  final int rows;
  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : r.width;
        final padding = (cardWidth * 0.03).clamp(r.space(8), r.space(13)).toDouble();
        final gap = (cardWidth * 0.028).clamp(r.space(7), r.space(12)).toDouble();

        return InkWell(
          borderRadius: _borderRadius,
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.border),
              borderRadius: _borderRadius,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 44,
                        child: CachedNetworkImage(
                          imageUrl: post.image,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: r.icon(23),
                              height: r.icon(23),
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: colors.textMuted,
                              size: r.icon(46),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        flex: 56,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppText.titleSmall(
                              post.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                            SizedBox(height: r.space(8)),
                            AppText.bodySmall(
                              post.excerpt,
                              color: colors.textSecondary,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              height: 1.6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: r.space(10)),
                Row(
                  children: [
                    Expanded(
                      child: AppText.labelSmall(
                        post.categories.map((item) => item.name).join('، '),
                        color: colors.textMuted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: r.space(8)),
                    AppText.labelSmall(
                      AppFunction.faDigit(post.date),
                      color: colors.textMuted,
                      maxLines: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BorderRadius get _borderRadius {
    final i = index + 1;

    if (rows > 1) {
      if (i <= rows) {
        if (i == 1) return const BorderRadius.only(topRight: Radius.circular(12));
        if (rows - i == 0) return const BorderRadius.only(bottomRight: Radius.circular(12));
      }
      if (i >= length - (rows - 1)) {
        if (i - (length - (rows - 1)) == 0) return const BorderRadius.only(topLeft: Radius.circular(12));
        if (i == length) return const BorderRadius.only(bottomLeft: Radius.circular(12));
      }
    } else {
      if (i == 1) return const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12));
      if (i == length) return const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12));
    }

    return BorderRadius.zero;
  }
}
