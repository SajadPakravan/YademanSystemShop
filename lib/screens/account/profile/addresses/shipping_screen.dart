import 'package:flutter/material.dart';
import 'package:yad_sys/screens/account/profile/addresses/address_form_screen.dart';
import 'package:yad_sys/view_models/account/profile/address/addresses_view_model.dart';

class ShippingScreen extends StatelessWidget {
  const ShippingScreen({super.key, required this.addressVM});

  final AddressesViewModel addressVM;

  @override
  Widget build(BuildContext context) => AddressFormScreen(addressesViewModel: addressVM, addressKey: 'shipping');
}
