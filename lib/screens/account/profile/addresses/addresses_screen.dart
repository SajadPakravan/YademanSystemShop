import 'package:flutter/material.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/view_models/account/profile/addresses_view_model.dart';
import 'package:yad_sys/views/account/profile/addresses/addresses_view.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({
    super.key,
    required this.token,
    this.initialAddresses,
    this.onUpdated,
  });

  final String token;
  final AddressBookModel? initialAddresses;
  final ValueChanged<AddressBookModel>? onUpdated;

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late final AddressesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddressesViewModel(
      token: widget.token,
      initialAddresses: widget.initialAddresses,
      onUpdated: widget.onUpdated,
    );
    _viewModel.load();
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
      builder: (context, child) => AddressesView(viewModel: _viewModel),
    );
  }
}
