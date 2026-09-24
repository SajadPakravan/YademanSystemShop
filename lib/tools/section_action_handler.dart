import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/models/section_item_action_model.dart';
import 'package:yad_sys/screens/web_screen.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/tools/main_navigation_controller.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';

class SectionActionHandler {
  const SectionActionHandler._();

  static Future<void> openShop({required BuildContext context, required SectionItemActionModel action}) async {
    final shopViewModel = context.read<ShopViewModel>();

    MainNavigationController.instance.openShop();

    final navigator = Get.key.currentState;
    if (navigator != null && navigator.canPop()) {
      Get.until((route) => route.isFirst);
    }

    await shopViewModel.applySectionAction(action);
  }

  static void _openUrl(BuildContext context, String? url, String title) {
    final uri = Uri.tryParse(url ?? '');
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
