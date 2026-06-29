import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';
import 'package:yad_sys/views/shop/shop_view.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => ShopScreenState();
}

class ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
    final shopModel = Provider.of<ShopViewModel>(context, listen: false);
    if (shopModel.productsLst.isEmpty) {
      shopModel.setFilters();
      shopModel.getProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopViewModel>(
      builder: (context, shopModel, child) {
        return ShopView(
          context: context,
          visibleReloadCover: shopModel.visibleReloadCover,
          productsLst: shopModel.productsLst,
          productCount: shopModel.productCount,
          moreProduct: shopModel.moreProduct,
          categoriesLst: shopModel.categoriesLst,
          categoriesId: shopModel.categoriesId,
          getProducts: shopModel.getProducts,
          filtersLst: shopModel.filtersLst,
          filterSelected: shopModel.filterSelected,
          onMoreBtn: shopModel.onMoreBtn,
        );
      },
    );
  }
}
