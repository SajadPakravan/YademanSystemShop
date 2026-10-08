import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/account_view_model.dart';
import 'package:yad_sys/view_models/account/profile_view_model.dart';
import 'package:yad_sys/views/account/profile/profile_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.viewModel});

  final AccountViewModel viewModel;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _profileViewModel;

  @override
  void initState() {
    super.initState();
    _profileViewModel = ProfileViewModel(
      token: widget.viewModel.token!,
      initialCustomer: widget.viewModel.customer!,
      onCustomerUpdated: widget.viewModel.applyCustomer,
    );
    // در هر بار ورود به پروفایل تعدادها از API مشتری بازخوانی می‌شوند.
    _profileViewModel.refreshCustomer();
  }

  @override
  void dispose() {
    _profileViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _profileViewModel,
    builder: (context, child) => ProfileView(viewModel: _profileViewModel, logout: widget.viewModel.logout),
  );
}
