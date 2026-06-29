import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/view_models/categories/categories_view_model.dart';
import 'package:yad_sys/views/categories/categories_view.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    final categoriesViewModel = Provider.of<CategoriesViewModel>(context, listen: false);
    if (categoriesViewModel.parentCategoriesLst.isEmpty) categoriesViewModel.loadContent();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesViewModel>(
      builder: (context, categoriesModel, child) {
        return CategoriesView(
          context: context,
          parentCategoriesLst: categoriesModel.parentCategoriesLst,
          speakerSubCategoriesLst: categoriesModel.speakerSubCategoriesLst,
          computerSubCategoriesLst: categoriesModel.computerSubCategoriesLst,
          hardwareSubCategoriesLst: categoriesModel.hardwareSubCategoriesLst,
          laptopSubCategoriesLst: categoriesModel.laptopSubCategoriesLst,
          headphoneSubCategoriesLst: categoriesModel.headphoneSubCategoriesLst,
          storageSubCategoriesLst: categoriesModel.storageSubCategoriesLst,
          networkSubCategoriesLst: categoriesModel.networkSubCategoriesLst,
          showContent: categoriesModel.showContent,
        );
      },
    );
  }
}
