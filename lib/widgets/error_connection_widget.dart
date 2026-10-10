import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ErrorConnectionWidget extends StatelessWidget {
  const ErrorConnectionWidget({super.key, required this.errorMessage, required this.onPressed});

  final String errorMessage;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(r.pageHorizontalPadding * 1.5),
              child: Column(
                spacing: r.space(20),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_outlined, color: colors.textMuted, size: r.icon(68)),
                  AppText.bodyMedium(errorMessage, textAlign: TextAlign.center, color: colors.textSecondary, height: 1.7),
                  AppButton(label: 'تلاش دوباره', icon: Icons.refresh_rounded, expand: false, onPressed: () async => await onPressed()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
