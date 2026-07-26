import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/view_models/home/home_view_model.dart';
import 'package:yad_sys/views/home/home_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = context.read<HomeViewModel>();
      if (!viewModel.hasLoadedOnce) viewModel.loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return HomeView(
          sections: viewModel.sections,
          isLoading: viewModel.isLoading,
          isRefreshing: viewModel.isRefreshing,
          errorMessage: viewModel.errorMessage,
          onRefresh: () => viewModel.loadHome(refresh: true),
          onRetry: () => viewModel.loadHome(),
        );
      },
    );
  }
}
