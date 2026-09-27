import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/view_models/categories/categories_view_model.dart';
import 'package:yad_sys/views/categories/categories_view.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = context.read<CategoriesViewModel>();
      if (!viewModel.hasLoadedOnce) viewModel.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesViewModel>(
      builder: (context, viewModel, child) {
        return CategoriesView(
          sections: viewModel.sections,
          isLoading: viewModel.isLoading,
          isRefreshing: viewModel.isRefreshing,
          errorMessage: viewModel.errorMessage,
          onRetry: viewModel.load,
        );
      },
    );
  }
}
