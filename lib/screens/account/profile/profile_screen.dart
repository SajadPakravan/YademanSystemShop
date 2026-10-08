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
  late final ProfileViewModel profileViewModel;

  @override
  void initState() {
    super.initState();
    profileViewModel = ProfileViewModel(token: widget.viewModel.token!)..load();
  }

  @override
  void dispose() {
    profileViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: profileViewModel,
    builder: (context, child) => ProfileView(viewModel: profileViewModel, logout: widget.viewModel.logout),
  );
}
