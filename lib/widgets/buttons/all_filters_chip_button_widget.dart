import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class AllFiltersChipButtonWidget extends StatelessWidget {
  const AllFiltersChipButtonWidget({super.key, required this.title, required this.onTap, this.badgeCount = 0, this.icon});

  final String title;
  final int badgeCount;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: colors.surface,
          borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(r.radius(8)), bottomEnd: Radius.circular(r.radius(8))),
          child: InkWell(
            onTap: onTap,
            // borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(r.radius(8)), bottomEnd: Radius.circular(r.radius(8))),
            child: Container(
              height: r.space(95, min: 88, max: 108),
              padding: EdgeInsets.all(r.space(10)),
              decoration: BoxDecoration(
                border: Border.all(color: colors.border, width: 1.4),
                borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(r.radius(8)), bottomEnd: Radius.circular(r.radius(8))),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: r.icon(18), color: colors.textSecondary),
                    SizedBox(height: r.space(3)),
                  ],
                  AppText.bodySmall(title, maxLines: 1, overflow: TextOverflow.ellipsis, color: colors.textPrimary),
                  Icon(Icons.keyboard_arrow_down_rounded, size: r.icon(18), color: colors.textSecondary),
                ],
              ),
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -r.space(10),
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                constraints: BoxConstraints(minWidth: r.icon(20), minHeight: r.icon(20)),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: r.space(5)),
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: AppText.labelSmall(AppFunction.faDigit(badgeCount), color: AppColors.onBrand, fontWeight: FontWeight.w800, responsive: false),
              ),
            ),
          ),
      ],
    );
  }
}
