import 'package:flutter/material.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class SnackBarView {
  static void show(BuildContext context, String content) {
    final snackBar = SnackBar(
      backgroundColor: Colors.black,
      content: Center(child: TextBodyMediumView(content, color: Colors.white,height: 2)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
