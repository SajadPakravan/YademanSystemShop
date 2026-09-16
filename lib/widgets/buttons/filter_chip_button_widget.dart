import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class FilterChipButtonWidget extends StatelessWidget {
  const FilterChipButtonWidget({
    super.key,
    required this.title,
    required this.active,
    required this.onTap,
    this.badgeCount = 0,
    this.icon,
    this.compactMargin = false,
  });

  final String title;
  final bool active;
  final int badgeCount;
  final IconData? icon;
  final VoidCallback onTap;
  final bool compactMargin;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
    final foreground = active ? AppColors.accent : colors.textPrimary;

    return Padding(
      padding: EdgeInsets.only(left: compactMargin ? 0 : r.space(7)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: active ? colors.chipActiveBackground : colors.chipBackground,
            borderRadius: BorderRadius.circular(r.radius(24)),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(r.radius(24)),
              child: Container(
                height: r.chipHeight,
                padding: EdgeInsets.symmetric(horizontal: r.space(13)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r.radius(24)),
                  border: Border.all(color: active ? AppColors.accent.withValues(alpha: 0.25) : colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...<Widget>[
                      Icon(icon, size: r.icon(18), color: active ? AppColors.accent : colors.textSecondary),
                      SizedBox(width: r.space(5)),
                    ],
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: r.percentWidth(0.31, min: 105, max: 150)),
                      child: AppText.bodySmall(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        color: foreground,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: r.space(4)),
                    Icon(Icons.keyboard_arrow_down_rounded, size: r.icon(18), color: active ? AppColors.accent : colors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -r.space(2),
              left: -r.space(3),
              child: Container(
                constraints: BoxConstraints(minWidth: r.icon(20), minHeight: r.icon(20)),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: r.space(5)),
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: AppText.labelSmall(
                  AppFunction.faDigit(badgeCount),
                  color: AppColors.onBrand,
                  fontWeight: FontWeight.w800,
                  responsive: false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
