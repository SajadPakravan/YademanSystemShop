import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/screens/search/search_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return InkWell(
      borderRadius: BorderRadius.circular(r.radius(50)),
      onTap: () => Get.to(const SearchScreen(), transition: Transition.upToDown, duration: const Duration(milliseconds: 500)),
      child: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: r.space(12), vertical: r.space(9)),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border, width: 1.4),
          borderRadius: BorderRadius.circular(r.radius(50)),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: colors.textSecondary, size: r.icon(22)),
            SizedBox(width: r.space(7)),
            const AppText.bodyMedium('جستجو در '),
            const AppText.bodyLarge('یادمان سیستم', fontWeight: FontWeight.bold, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
