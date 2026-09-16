import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ViewAllWidget extends StatelessWidget {
  const ViewAllWidget({super.key, required this.title, required this.onTap, this.foregroundColor});

  final String title;
  final VoidCallback onTap;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final color = foregroundColor ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(r.cardRadius),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: r.icon(58, min: 48, max: 66),
            height: r.icon(58, min: 48, max: 66),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.14)),
            child: Icon(Icons.arrow_forward_rounded, color: color, size: r.icon(30, min: 26, max: 34)),
          ),
          SizedBox(height: r.space(14, min: 10, max: 18)),
          AppText.labelLarge(
            title.isEmpty ? 'مشاهده همه' : title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            color: color,
            fontWeight: FontWeight.w800,
            height: 1.45,
          ),
        ],
      ),
    );
  }
}
