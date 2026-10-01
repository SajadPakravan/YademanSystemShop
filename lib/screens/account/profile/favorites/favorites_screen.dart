import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/views/account/profile/favorites/favorites_view.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.items});
  final List<CustomerProductItemModel> items;
  @override
  Widget build(BuildContext context) => FavoritesView(items: items);
}
