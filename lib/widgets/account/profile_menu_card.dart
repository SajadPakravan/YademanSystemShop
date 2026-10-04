import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key, required this.title, required this.icon, required this.onTap, this.badgeCount, this.showAlertDot = false});

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool showAlertDot;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(r.radius(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.radius(16)),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(r.radius(16)),
            border: Border.all(color: colors.border),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: context.isDarkMode ? 0.12 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(r.space(10)),
                child: Column(
                  spacing: r.space(10),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: r.percentWidth(0.2, min: 46, max: 66),
                        height: r.percentWidth(0.2, min: 46, max: 66),
                        decoration: BoxDecoration(color: colors.inquiryBackground, shape: BoxShape.circle),
                        child: Center(child: Icon(icon, color: AppColors.primary, size: r.icon(35, min: 24, max: 36))),
                      ),
                    ),
                    AppText.bodySmall(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ],
                ),
              ),
              if ((badgeCount ?? 0) > 0)
                Positioned(
                  top: r.space(7),
                  left: r.space(7),
                  child: Container(
                    constraints: BoxConstraints(minWidth: r.icon(22), minHeight: r.icon(22)),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: r.space(6), vertical: r.space(2)),
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    child: AppText.labelSmall(badgeCount.toString().toPersianDigit(), color: AppColors.onBrand, fontWeight: FontWeight.w800, height: 1),
                  ),
                ),
              if (showAlertDot)
                Positioned(
                  top: r.space(9),
                  right: r.space(9),
                  child: Container(
                    width: r.icon(11),
                    height: r.icon(11),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
