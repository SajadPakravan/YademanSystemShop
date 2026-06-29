import 'package:flutter/material.dart';
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

bottomSheetPickImage({required BuildContext context, required Function() onTapCamera, required Function() onTapGallery}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    enableDrag: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            option(context: context, icon: Icons.camera_alt_rounded, title: 'دوربین', onTap: onTapCamera),
            option(context: context, icon: Icons.photo, title: 'گالری', onTap: onTapGallery),
          ],
        ),
      );
    },
  );
}

option({required BuildContext context, required String title, required IconData icon, required Function() onTap}) {
  return SizedBox(
    width: 100,
    height: 100,
    child: ListTile(
      title: Icon(icon, size: 60, color: ColorStyle.blueFav),
      subtitle: TextBodyMediumView(title, textAlign: TextAlign.center),
      onTap: onTap,
    ),
  );
}
