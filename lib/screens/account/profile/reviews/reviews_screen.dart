import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/profile/reviews_view_model.dart';
import 'package:yad_sys/views/account/profile/reviews/reviews_view.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key, required this.token});

  final String token;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late final ReviewsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ReviewsViewModel(token: widget.token)..load();
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
      builder: (context, _) => ReviewsView(viewModel: _viewModel),
    );
  }
}
