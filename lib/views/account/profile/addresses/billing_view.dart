import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/profile/address/address_form_view_model.dart';
import 'package:yad_sys/views/account/profile/addresses/address_form_view.dart';

class BillingView extends StatelessWidget {
  const BillingView({super.key, required this.viewModel});

  final AddressFormViewModel viewModel;

  @override
  Widget build(BuildContext context) => AddressFormView(viewModel: viewModel);
}
