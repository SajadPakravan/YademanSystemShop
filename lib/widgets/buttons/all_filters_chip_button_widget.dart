import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_function.dart';

class AllFiltersChipButtonWidget extends StatelessWidget {
  const AllFiltersChipButtonWidget({super.key, required this.title, required this.onTap, this.badgeCount = 0, this.icon});

  final String title;
  final int badgeCount;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            height: 95,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, width: 2),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 18, color: Colors.black54), const SizedBox(height: 3)],
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: const Color(0xff333333), fontWeight: FontWeight.w400),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.black54),
              ],
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
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
    );
  }
}