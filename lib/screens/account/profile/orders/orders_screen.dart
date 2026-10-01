import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/views/account/profile/orders/orders_view.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, required this.orders});
  final List<CustomerOrderModel> orders;
  @override
  Widget build(BuildContext context) => OrdersView(orders: orders);
}
