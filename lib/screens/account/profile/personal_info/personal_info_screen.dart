import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/views/account/profile/personal_info/personal_info_view.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) => PersonalInfoView(customer: customer);
}
