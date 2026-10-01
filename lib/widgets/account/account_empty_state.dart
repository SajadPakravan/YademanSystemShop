import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class AccountEmptyState extends StatelessWidget {
  const AccountEmptyState({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.pageHorizontalPadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: r.icon(64, min: 54, max: 78), color: colors.textMuted),
            SizedBox(height: r.space(14)),
            AppText.titleMedium(title, fontWeight: FontWeight.w800, textAlign: TextAlign.center),
            SizedBox(height: r.space(8)),
            AppText.bodyMedium(message, color: colors.textSecondary, textAlign: TextAlign.center, height: 1.7),
          ],
        ),
      ),
    );
  }
}
