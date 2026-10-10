import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/profile/addresses_view_model.dart';
import 'package:yad_sys/view_models/account/profile/shipping_view_model.dart';
import 'package:yad_sys/views/account/profile/addresses/address_form_view.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key, required this.addressesViewModel});
  final AddressesViewModel addressesViewModel;

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> with AutomaticKeepAliveClientMixin<ShippingScreen> {
  late final ShippingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ShippingViewModel(addressesViewModel: widget.addressesViewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) => AddressFormView(viewModel: _viewModel),
    );
  }
}
