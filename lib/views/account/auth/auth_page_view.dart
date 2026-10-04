import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.formKey,
    required this.children,
    required this.apiError,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final String apiError;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsetsDirectional.fromSTEB(r.pageHorizontalPadding, r.space(22), r.pageHorizontalPadding, r.space(24) + keyboard),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.isTablet ? 540 : 500, minHeight: mathMax(0, constraints.maxHeight - r.space(46))),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: r.icon(94, min: 82, max: 116),
                        height: r.icon(94, min: 82, max: 116),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.surfaceVariant,
                          border: Border.all(color: colors.border),
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: AppColors.primary.withValues(alpha: 0.10), blurRadius: r.space(22), spreadRadius: r.space(2)),
                          ],
                        ),
                        child: Icon(icon, color: AppColors.primary, size: r.icon(48, min: 42, max: 60)),
                      ),
                    ),
                    SizedBox(height: r.space(18)),
                    AppText.titleLarge(title, textAlign: TextAlign.center, fontWeight: FontWeight.w800, color: colors.textPrimary),
                    SizedBox(height: r.space(8)),
                    AppText.bodySmall(subtitle, textAlign: TextAlign.center, color: colors.textSecondary, height: 1.8),
                    SizedBox(height: r.space(24)),
                    if (apiError.isNotEmpty) ...<Widget>[
                      Container(
                        padding: EdgeInsets.all(r.space(12)),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: context.isDarkMode ? 0.16 : 0.08),
                          borderRadius: BorderRadius.circular(r.radius(12)),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.28)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error_outline_rounded, color: AppColors.error, size: r.icon(21)),
                            SizedBox(width: r.space(8)),
                            Expanded(child: AppText.bodySmall(apiError, color: colors.textPrimary, height: 1.7)),
                          ],
                        ),
                      ),
                      SizedBox(height: r.space(14)),
                    ],
                    ..._spaced(children, r.space(14)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static List<Widget> _spaced(List<Widget> children, double spacing) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) result.add(SizedBox(height: spacing));
      result.add(children[i]);
    }
    return result;
  }

  static double mathMax(double a, double b) => a > b ? a : b;
}
