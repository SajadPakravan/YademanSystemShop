import 'package:flutter/material.dart';
import 'package:yad_sys/screens/account/profile/addresses/billing_screen.dart';
import 'package:yad_sys/screens/account/profile/addresses/shipping_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/view_models/account/profile/addresses_view_model.dart';
import 'package:yad_sys/widgets/error_connection_widget.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

/// The parent owns tabs and shared API data only; each child owns its form state.
class AddressesView extends StatelessWidget {
  const AddressesView({super.key, required this.viewModel});
  final AddressesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (viewModel.addresses == null) {
      if (viewModel.isLoading) return const Loading();
      return ErrorConnectionWidget(
        errorMessage: viewModel.errorMessage.isNotEmpty ? viewModel.errorMessage : 'دریافت آدرس‌ها انجام نشد.',
        onPressed: () => viewModel.load(refresh: true),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            centerTitle: true,
            title: const AppText.titleMedium('آدرس‌ها', fontWeight: FontWeight.w700),
            actions: [
              IconButton(
                tooltip: 'دریافت مجدد آدرس‌ها',
                icon: viewModel.isRefreshing
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh_rounded),
                onPressed: viewModel.isRefreshing || viewModel.anySaving ? null : () => viewModel.load(refresh: true),
              ),
            ],
            bottom: TabBar(
              onTap: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              tabs: const [Tab(text: 'صورتحساب'), Tab(text: 'ارسال')],
            ),
          ),
          body: Column(
            children: [
              if (viewModel.errorMessage.isNotEmpty)
                MaterialBanner(
                  content: Text(viewModel.errorMessage),
                  actions: [TextButton(onPressed: () => viewModel.load(refresh: true), child: const Text('تلاش مجدد'))],
                ),
              Expanded(
                child: NotificationListener<ScrollStartNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.axis == Axis.horizontal) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    return false;
                  },
                  child: TabBarView(
                    children: [
                      BillingScreen(key: const ValueKey('billing_address_tab'), addressesViewModel: viewModel),
                      ShippingScreen(key: const ValueKey('shipping_address_tab'), addressesViewModel: viewModel),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
