import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/models/product_variable_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
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
    required this.productVariableLst,
    required this.onMoreBtn,
  });

  final BuildContext context;
  final dynamic onRefresh;
  final List<ProductModel> productsLst;
  final List<ProductVariableModel> productVariableLst;
  final int productCount;
  final Function onMoreBtn;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [_appBar(context)],
          body: RefreshIndicator(
            onRefresh: () => onRefresh(),
            child: productsLst.isEmpty
                ? const Loading()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ProductCardGrid(productsLst: productsLst, productVariableLst: productVariableLst),
                        Visibility(
                          visible: !(productCount < 10),
                          child: EasyButton(
                            type: EasyButtonType.text,
                            idleStateWidget: Icon(Icons.more_horiz, color: AppColors.accent, size: context.responsive.icon(40)),
                            loadingStateWidget: const Loading(),
                            onPressed: onMoreBtn,
                          ),
                        ),
                        SizedBox(height: context.responsive.space(10)),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _appBar(BuildContext context) {
    final colors = context.appColors;
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: colors.surface,
      surfaceTintColor: AppColors.transparent,
      title: TextTitleMediumView(Get.arguments['title']),
      centerTitle: true,
      iconTheme: IconThemeData(color: colors.textSecondary),
    );
  }
}
