import 'package:flutter/material.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.section, this.textColor = Colors.black87, this.backgroundColor = Colors.grey});

  final SectionModel section;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final title = section.title.trim();
    final subtitle = section.subtitle.trim();
    final hasTitle = title.isNotEmpty;
    final hasSubtitle = subtitle.isNotEmpty;
    final hasViewAll = section.viewAll != null;

    if (!hasTitle && !hasViewAll) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = (screenWidth * 0.035).clamp(12.0, 20.0).toDouble();
    final titleFontSize = (screenWidth * 0.043).clamp(16.0, 19.0).toDouble();
    final subtitleFontSize = (screenWidth * 0.031).clamp(11.5, 13.0).toDouble();

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: hasSubtitle ? 68 : 54),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: hasSubtitle ? 9 : 5),
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasTitle)
            Expanded(
              child: hasSubtitle
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textColor, fontSize: titleFontSize, fontWeight: FontWeight.bold, height: 1.25),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textColor.withValues(alpha: 0.72), fontSize: subtitleFontSize, height: 1.25),
                        ),
                      ],
                    )
                  : Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textColor, fontSize: titleFontSize, fontWeight: FontWeight.bold, height: 1.25),
                      ),
                    ),
            )
          else
            const Spacer(),
          if (hasViewAll)
            _ViewAllButton(
              title: section.viewAll!.title,
              textColor: textColor,
              onTap: () => SectionActionHandler.handle(context: context, action: section.viewAll!.action),
            ),
        ],
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({required this.title, required this.textColor, required this.onTap});

  final String title;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 10, end: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title.trim().isEmpty ? 'مشاهده همه' : title.trim(),
                  style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 7),
                Icon(Icons.arrow_forward_ios_rounded, color: textColor, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
