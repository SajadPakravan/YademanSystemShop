import 'package:flutter/material.dart';
import 'package:yad_sys/screens/categories/see_all_screen.dart';
import 'package:yad_sys/screens/web_screen.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';

class SectionItemActionHandler {
  const SectionItemActionHandler._();

  static Future<void> handle({
    required BuildContext context,
    required String type,
    required String title,
    int? destinationId,
    bool? onSale,
    String? url,
  }) async {
    switch (type) {
      case 'category':
        rightToPage(const ShowAllScreen(), arguments: <String, dynamic>{'title': title, 'category': destinationId, 'onSale': onSale});
        return;

      case 'brand':
        rightToPage(const ShowAllScreen(), arguments: <String, dynamic>{'title': title, 'brand': destinationId, 'onSale': onSale});
        return;

      case 'url':
        _openUrl(context, url, title);
        return;
    }
  }

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
