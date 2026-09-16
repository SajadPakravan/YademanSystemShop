import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

void bottomSheetPickImage({
  required BuildContext context,
  required Function() onTapCamera,
  required Function() onTapGallery,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    enableDrag: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      final r = context.responsive;
      return Padding(
        padding: EdgeInsets.all(r.space(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _option(context: context, icon: Icons.camera_alt_rounded, title: 'دوربین', onTap: onTapCamera),
            _option(context: context, icon: Icons.photo, title: 'گالری', onTap: onTapGallery),
          ],
        ),
      );
    },
  );
}

Widget _option({
  required BuildContext context,
  required String title,
  required IconData icon,
  required Function() onTap,
}) {
  final r = context.responsive;
  return SizedBox(
    width: r.percentWidth(0.26, min: 92, max: 130),
    height: r.percentWidth(0.26, min: 92, max: 130),
    child: ListTile(
      title: Icon(icon, size: r.icon(52), color: AppColors.primary),
      subtitle: TextBodyMediumView(title, textAlign: TextAlign.center),
      onTap: onTap,
    ),
  );
}
