import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/profile/orders_view_model.dart';
import 'package:yad_sys/views/account/profile/orders/orders_view.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.token});

  final String token;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final OrdersViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OrdersViewModel(token: widget.token)..load();
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
      builder: (context, _) => OrdersView(viewModel: _viewModel),
    );
  }
}
