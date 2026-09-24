import 'package:flutter/material.dart';
import 'package:yad_sys/screens/web_screen.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';

class SectionItemActionHandler {
  const SectionItemActionHandler._();

  static void _openUrl(BuildContext context, String? url, String title) {
    final uri = Uri.tryParse(url!);
    if (uri == null || !uri.hasScheme || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      _showUnavailable(context);
      return;
    }

    zoomToPage(WebScreen(url: uri.toString(), title: title));
  }

  static void _showUnavailable(BuildContext context) {
    SnackBarView.show(context, 'این بخش هنوز به صفحه مقصد متصل نشده است');
  }
}
