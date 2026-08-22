import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_function.dart';

class FilterChipButtonWidget extends StatelessWidget {
  const FilterChipButtonWidget({super.key, required this.title, required this.active, required this.onTap, this.badgeCount = 0, this.icon, this.compactMargin = false});

  final String title;
  final bool active;
  final int badgeCount;
  final IconData? icon;
  final VoidCallback onTap;
  final bool compactMargin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: compactMargin ? 0 : 7),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: active ? AppColors.activeChipBackground : Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: active ? const Color(0xffffc9d3) : const Color(0xffdddddd)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...<Widget>[Icon(icon, size: 18, color: active ? AppColors.accent : Colors.black54), const SizedBox(width: 5)],
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 125),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: active ? AppColors.accent : const Color(0xff333333),
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: active ? AppColors.accent : Colors.black54),
                  ],
                ),
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 0,
              left: -3,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: Text(
                  AppFunction.faDigit(badgeCount),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }
}