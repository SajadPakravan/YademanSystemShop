import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class AuthSwitch extends StatelessWidget {
  const AuthSwitch({super.key, required this.question, required this.action, required this.onTap});

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: r.space(4),
      children: [
        AppText.bodyMedium(question, color: colors.textSecondary),
        TextButton(
          onPressed: onTap,
          child: AppText.bodyMedium(action, color: context.appColors.inquiryForeground, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
