import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/view_models/account/account_view_model.dart';
import 'package:yad_sys/views/account/auth/auth_view.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.viewModel});

  final AccountViewModel viewModel;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) => Consumer<AccountViewModel>(builder: (context, viewModel, child) => AuthView(viewModel: viewModel));
}
