import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/view_models/categories/category_view_model.dart';
import 'package:yad_sys/views/categories/category_view.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final CategoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CategoryViewModel(id: Get.arguments['id']);
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
      builder: (context, child) {
        return PopScope(
          canPop: !_viewModel.hasCategoryHistory,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPopRoute = await _viewModel.handleBack();
            if (shouldPopRoute && context.mounted) Navigator.of(context).pop(result);
          },
          child: CategoryView(viewModel: _viewModel),
        );
      },
    );
  }
}
