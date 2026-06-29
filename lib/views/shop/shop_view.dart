import 'package:flutter/material.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:yad_sys/models/category_model.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/widgets/bottom_sheet/bottom_sheet_select_categories.dart';
import 'package:yad_sys/widgets/bottom_sheet/bottom_sheet_select_filter.dart';
import 'package:yad_sys/widgets/cards/product_card_grid.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/search.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class ShopView extends StatelessWidget {
  const ShopView({
    super.key,
    required this.context,
    required this.visibleReloadCover,
    required this.productsLst,
    required this.productCount,
    required this.moreProduct,
    required this.categoriesLst,
    required this.categoriesId,
    required this.getProducts,
    required this.filtersLst,
    required this.filterSelected,
    required this.onMoreBtn,
  });

  final BuildContext context;
  final bool visibleReloadCover;
  final List<ProductModel> productsLst;
  final int productCount;
  final bool moreProduct;
  final List<CategoryModel> categoriesLst;
  final List<int> categoriesId;
  final List<Map<String, dynamic>> filtersLst;
  final int filterSelected;
  final Function() getProducts;
  final Function onMoreBtn;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          physics: const NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              titleSpacing: 0,
              toolbarHeight: 100,
              title: Column(
                children: [
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Search()),
                  AnimatedOpacity(
                    opacity: categoriesLst.isEmpty ? 0 : 1,
                    duration: const Duration(milliseconds: 500),
                    child: filterBtn(),
                  ),
                ],
              ),
            ),
          ],
          body: productsLst.isEmpty
              ? const Loading()
              : Visibility(
                  visible: visibleReloadCover,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ProductCardGrid(physics: const NeverScrollableScrollPhysics(), list: productsLst),
                        Visibility(
                          visible: !(productCount < 10),
                          child: EasyButton(
                            type: EasyButtonType.text,
                            idleStateWidget: const Icon(Icons.more_horiz, color: Colors.red, size: 40),
                            loadingStateWidget: const Loading(),
                            onPressed: onMoreBtn,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  filterBtn() {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => selectCategories(context: context, categoriesLst: categoriesLst, id: categoriesId, onPressed: getProducts),
            child: const Row(
              children: [TextBodyMediumView('دسته‌بندی‌ها'), Icon(Icons.arrow_drop_down, color: Colors.black54)],
            ),
          ),
          TextButton(
            onPressed: () => selectFilter(context: context, filtersLst: filtersLst, selected: filterSelected, onPressed: getProducts),
            child: Row(
              children: [TextBodyMediumView(filtersLst[filterSelected]['name']), const Icon(Icons.arrow_drop_down, color: Colors.black54)],
            ),
          ),
        ],
      ),
    );
  }
}
