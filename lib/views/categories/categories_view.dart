import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/category_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/search.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class CategoriesView extends StatelessWidget {
  CategoriesView({
    super.key,
    required this.context,
    required this.parentCategoriesLst,
    required this.speakerSubCategoriesLst,
    required this.computerSubCategoriesLst,
    required this.hardwareSubCategoriesLst,
    required this.laptopSubCategoriesLst,
    required this.headphoneSubCategoriesLst,
    required this.storageSubCategoriesLst,
    required this.networkSubCategoriesLst,
    required this.showContent,
  });

  final BuildContext context;
  final AppFunction appFun = AppFunction();
  final List<CategoryModel> parentCategoriesLst;
  final List<CategoryModel> speakerSubCategoriesLst;
  final List<CategoryModel> computerSubCategoriesLst;
  final List<CategoryModel> hardwareSubCategoriesLst;
  final List<CategoryModel> laptopSubCategoriesLst;
  final List<CategoryModel> headphoneSubCategoriesLst;
  final List<CategoryModel> storageSubCategoriesLst;
  final List<CategoryModel> networkSubCategoriesLst;
  final bool showContent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: colors.surface,
              surfaceTintColor: AppColors.transparent,
              titleSpacing: r.space(10),
              title: const Search(),
            ),
          ],
          body: !showContent
              ? const Loading()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _parentCategories(context),
                      _subCategories(context, title: 'اسپیکر', list: speakerSubCategoriesLst),
                      _subCategories(context, title: 'لوازم جانبی کامپیوتر', list: computerSubCategoriesLst),
                      _subCategories(context, title: 'سخت‌افزار کامپیوتر', list: hardwareSubCategoriesLst),
                      _subCategories(context, title: 'لوازم جانبی لپ‌تاپ', list: laptopSubCategoriesLst),
                      _subCategories(context, title: 'هدفون و هندزفری', list: headphoneSubCategoriesLst),
                      _subCategories(context, title: 'تجهیزات ذخیره‌سازی', list: storageSubCategoriesLst),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _parentCategories(BuildContext context) {
    final r = context.responsive;
    final cardWidth = r.gridItemWidth(columns: r.width < 380 ? 3 : 4, horizontalPadding: r.pageHorizontalPadding * 2, spacing: r.space(10), min: 82, max: 132);
    final imageSize = (cardWidth * 0.72).clamp(58.0, 92.0).toDouble();
    final rowHeight = imageSize + r.space(58);

    return SizedBox(
      height: (rowHeight * 2) + r.space(14),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: cardWidth,
          mainAxisSpacing: r.space(10),
          crossAxisSpacing: r.space(14),
        ),
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(r.pageHorizontalPadding),
        itemCount: parentCategoriesLst.length,
        itemBuilder: (context, index) {
          final category = parentCategoriesLst[index];
          final imageUrl = category.image?.src ?? '';
          return InkWell(
            borderRadius: BorderRadius.circular(r.cardRadius),
            onTap: () => appFun.onTapShowAll(title: category.name ?? '', category: category.id.toString()),
            child: Column(
              children: [
                SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, _, _) => Icon(Icons.image_outlined, color: context.appColors.textMuted, size: r.icon(46)),
                  ),
                ),
                SizedBox(height: r.space(8)),
                AppText.bodySmall(category.name ?? '', textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _subCategories(BuildContext context, {required String title, required List<CategoryModel> list}) {
    if (list.isEmpty) return const SizedBox.shrink();

    final r = context.responsive;
    final colors = context.appColors;
    final cardWidth = r.percentWidth(0.24, min: 82, max: 118);
    final cardHeight = r.space(132, min: 120, max: 150);

    return Padding(
      padding: EdgeInsets.only(bottom: r.sectionVerticalGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding, vertical: r.space(8)),
            child: AppText.titleSmall(title, fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
              itemCount: list.length,
              separatorBuilder: (_, _) => SizedBox(width: r.space(10)),
              itemBuilder: (context, index) {
                final category = list[index];
                final imageUrl = category.image?.src ?? '';
                return SizedBox(
                  width: cardWidth,
                  child: Material(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(r.cardRadius),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(r.cardRadius),
                      onTap: () => appFun.onTapShowAll(title: category.name ?? '', category: category.id.toString()),
                      child: Padding(
                        padding: EdgeInsets.all(r.space(9)),
                        child: Column(
                          children: [
                            Expanded(
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                errorWidget: (_, _, _) => Icon(Icons.image_outlined, color: colors.textMuted, size: r.icon(42)),
                              ),
                            ),
                            SizedBox(height: r.space(8)),
                            AppText.bodySmall(category.name ?? '', textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
