import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/view_models/account/account_view_model.dart';
import 'package:yad_sys/views/account/auth/login/login_view.dart';
import 'package:yad_sys/views/account/auth/register/register_view.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key, required this.viewModel});

  final AccountViewModel viewModel;

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: PageView(
            controller: widget.viewModel.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              LoginView(viewModel: widget.viewModel),
              RegisterView(viewModel: widget.viewModel),
            ],
          ),
        ),
      ),
    );
  }
}
