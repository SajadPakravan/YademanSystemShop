import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/profile/addresses_view_model.dart';
import 'package:yad_sys/view_models/account/profile/billing_view_model.dart';
import 'package:yad_sys/views/account/profile/addresses/address_form_view.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key, required this.addressesViewModel});
  final AddressesViewModel addressesViewModel;

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> with AutomaticKeepAliveClientMixin<BillingScreen> {
  late final BillingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BillingViewModel(addressesViewModel: widget.addressesViewModel);
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
