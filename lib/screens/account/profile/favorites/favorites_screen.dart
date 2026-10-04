import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/profile/favorites_view_model.dart';
import 'package:yad_sys/views/account/profile/favorites/favorites_view.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.token});

  final String token;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoritesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FavoritesViewModel(token: widget.token)..load();
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
      builder: (context, _) => FavoritesView(viewModel: _viewModel),
    );
  }
}
