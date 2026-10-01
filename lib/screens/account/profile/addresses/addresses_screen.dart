import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/views/account/profile/addresses/addresses_view.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) => AddressesView(customer: customer);
}
