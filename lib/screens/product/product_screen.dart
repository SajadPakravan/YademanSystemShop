import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/view_models/product/product_view_model.dart';
import 'package:yad_sys/views/product/product_view.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final ProductViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductViewModel(id: Get.arguments['id']);
    _viewModel.loadProduct();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _viewModel.handleBack,
      child: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) => ProductView(viewModel: _viewModel),
      ),
    );
  }
}
