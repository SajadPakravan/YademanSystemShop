import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/view_models/account/profile/personal_info_view_model.dart';
import 'package:yad_sys/views/account/profile/personal_info/personal_info_view.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key, required this.customer, required this.token});

  final CustomerModel customer;
  final String token;

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final PersonalInfoViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = PersonalInfoViewModel(customer: widget.customer, token: widget.token)..initialize();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) => PersonalInfoView(viewModel: viewModel),
  );
}
