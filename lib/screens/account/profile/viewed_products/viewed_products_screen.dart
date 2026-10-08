import 'package:flutter/material.dart';
import 'package:yad_sys/widgets/account/account_pagination.dart';
import 'package:yad_sys/view_models/account/profile/viewed_products_view_model.dart';
import 'package:yad_sys/views/account/profile/viewed_products/viewed_products_view.dart';

class ViewedProductsScreen extends StatefulWidget {
  const ViewedProductsScreen({super.key, required this.token});

  final String token;

  @override
  State<ViewedProductsScreen> createState() => _ViewedProductsScreenState();
}

class _ViewedProductsScreenState extends State<ViewedProductsScreen> {
  late final ViewedProductsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewedProductsViewModel(token: widget.token)..load();
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
      builder: (context, _) => AccountPagination(viewModel: _viewModel, child: ViewedProductsView(viewModel: _viewModel)),
    );
  }
}
