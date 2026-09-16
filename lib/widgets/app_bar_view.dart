import 'package:flutter/material.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class AppBarView extends StatelessWidget implements PreferredSizeWidget {
  const AppBarView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: AppText.titleMedium(title, fontWeight: FontWeight.w700),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
