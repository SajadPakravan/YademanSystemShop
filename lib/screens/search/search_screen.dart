import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/view_models/search/search_view_model.dart';
import 'package:yad_sys/views/search/search_view.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchViewModel>(
      create: (_) => SearchViewModel(),
      child: const SearchView(),
    );
  }
}
