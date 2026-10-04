import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/profile/cart_view_model.dart';
import 'package:yad_sys/views/account/profile/cart/cart_view.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.token});

  final String token;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CartViewModel(token: widget.token)..load();
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
      builder: (context, _) => CartView(viewModel: _viewModel),
    );
  }
}
