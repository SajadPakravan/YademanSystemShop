import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/post_model.dart';

class PostHorizontalCardWidget extends StatelessWidget {
  const PostHorizontalCardWidget({super.key, required this.post, required this.rows, required this.length, required this.index});

  final PostModel post;
  final int rows;
  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        final padding = (cardWidth * 0.03).clamp(8.0, 13.0).toDouble();
        final gap = (cardWidth * 0.028).clamp(7.0, 12.0).toDouble();
        final titleFontSize = (cardWidth * 0.05).clamp(12.0, 15.0).toDouble();
        final excerptFontSize = (cardWidth * 0.035).clamp(12.0, 15.0).toDouble();

        return InkWell(
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: (cardHeight * 0.01).clamp(0.02, 5.0).toDouble()),
                          child: CachedNetworkImage(
                            width: double.infinity,
                            height: double.infinity,
                            imageUrl: post.image,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(child: SizedBox(width: 23, height: 23, child: CircularProgressIndicator(strokeWidth: 2))),
                            errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.black26, size: 46)),
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
                            Text(
                              post.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: titleFontSize, height: 1.45, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: (cardHeight * 1).clamp(6.0, 20.0).toDouble()),
                            Text(
                              post.excerpt,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: excerptFontSize, height: 1.45, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (cardHeight * 1).clamp(6.0, 20.0).toDouble()),
                Text(
                  post.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: excerptFontSize, height: 1.45, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BorderRadius get _borderRadius {
    int i = index + 1;

    if (rows > 1) {
      if (i <= rows) {
        if (i == 1) {
          return const BorderRadius.only(topRight: Radius.circular(12));
        }
        if (rows - i == 0) {
          return const BorderRadius.only(bottomRight: Radius.circular(12));
        }
      }

      if (i >= length - (rows - 1)) {
        if (i - (length - (rows - 1)) == 0) {
          return const BorderRadius.only(topLeft: Radius.circular(12));
        } else if(i == length) {
          return const BorderRadius.only(bottomLeft: Radius.circular(12));
        }
      }
    } else {
      if (i == 1) {
        return const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12));
      }
      if (i == length) {
        return const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12));
      }
    }

    return BorderRadius.zero;
  }
}
