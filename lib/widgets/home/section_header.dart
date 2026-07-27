import 'package:flutter/material.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.section, this.textColor = Colors.black87});

  final SectionModel section;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final hasTitle = section.title.isNotEmpty || section.subtitle.isNotEmpty;
    final hasViewAll = section.viewAll != null;
    if (!hasTitle && !hasViewAll) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.title.isNotEmpty)
                Text(
                  section.title,
                  style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              if (section.subtitle.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(section.subtitle, style: TextStyle(color: textColor.withValues(alpha: 0.75), fontSize: 12)),
              ],
            ],
          ),
        ),
        if (hasViewAll)
          TextButton(
            onPressed: () => SectionActionHandler.handle(context: context, action: section.viewAll!.action),
            style: TextButton.styleFrom(foregroundColor: textColor),
            child: Text(section.viewAll!.title),
          ),
      ],
    );
  }
}
