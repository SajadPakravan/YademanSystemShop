import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/screens/account/auth/auth_screen.dart';
import 'package:yad_sys/screens/account/profile/profile_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/view_models/account/account_view_model.dart';
import 'package:yad_sys/widgets/loading.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.initializing) return Scaffold(backgroundColor: context.appColors.background, body: const Loading());

        if (viewModel.loggedIn) return ProfileScreen(viewModel: viewModel);

        return AuthScreen(viewModel: viewModel);
      },
    );
  }
}
