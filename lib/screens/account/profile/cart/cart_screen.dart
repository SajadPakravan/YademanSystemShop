import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/views/account/profile/cart/cart_view.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.items});
  final List<CustomerProductItemModel> items;
  @override
  Widget build(BuildContext context) => CartView(items: items);
}
