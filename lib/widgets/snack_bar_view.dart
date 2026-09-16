import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class SnackBarView {
  const SnackBarView._();

  static void show(BuildContext context, String content) {
    final colors = context.appColors;
    final snackBar = SnackBar(
      backgroundColor: colors.surfaceElevated,
      behavior: SnackBarBehavior.floating,
      content: AppText.bodyMedium(
        content,
        color: colors.textPrimary,
        textAlign: TextAlign.center,
        height: 1.7,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
