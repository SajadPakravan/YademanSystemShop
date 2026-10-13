import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/profile/address/addresses_view_model.dart';
import 'package:yad_sys/view_models/account/profile/address/billing_view_model.dart';
import 'package:yad_sys/views/account/profile/addresses/billing_view.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key, required this.addressVM});

  final AddressesViewModel addressVM;

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  late final BillingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BillingViewModel(token: widget.addressVM.token, billing: widget.addressVM.billing!, provinces: widget.addressVM.provinces);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) => BillingView(viewModel: _viewModel),
    );
  }
}
