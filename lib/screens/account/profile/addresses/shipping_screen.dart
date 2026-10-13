import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/view_models/account/profile/address/addresses_view_model.dart';
import 'package:yad_sys/view_models/account/profile/address/shipping_view_model.dart';
import 'package:yad_sys/views/account/profile/addresses/shipping_view.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key, required this.addressesViewModel});

  final AddressesViewModel addressesViewModel;

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShippingViewModel>(
      builder: (context, viewModel, child) {
        return ShippingView(viewModel: viewModel);
      },
    );
  }
}
