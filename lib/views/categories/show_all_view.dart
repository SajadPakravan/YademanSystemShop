import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/widgets/cards/product_card_grid.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/text_views/text_title_medium_view.dart';

class ShowAllView extends StatelessWidget {
  const ShowAllView({
    super.key,
    required this.context,
    required this.onRefresh,
    required this.productCount,
    required this.productsLst,
    required this.onMoreBtn,
  });

  final BuildContext context;
  final dynamic onRefresh;
  final List<ProductModel> productsLst;
  final int productCount;
  final Function onMoreBtn;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [appBar()],
          body: RefreshIndicator(
            onRefresh: () => onRefresh(),
            child: productsLst.isEmpty
                ? const Loading()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ProductCardGrid(list: productsLst, physics: const NeverScrollableScrollPhysics()),
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

  SliverAppBar appBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
      title: TextTitleMediumView(Get.arguments['title']),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black54),
    );
  }
}
