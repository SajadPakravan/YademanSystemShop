import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/category_model.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/search.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            const SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              titleSpacing: 10,
              title: Search(),
            ),
          ],
          body: !showContent
              ? const Loading()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      parentCategories(),
                      subCategories(title: "اسپیکر", list: speakerSubCategoriesLst),
                      subCategories(title: "لوازم جانبی کامپیوتر", list: computerSubCategoriesLst),
                      subCategories(title: "سخت‌افزار کامپیوتر", list: hardwareSubCategoriesLst),
                      subCategories(title: "لوازم جانبی لپ‌تاپ", list: laptopSubCategoriesLst),
                      subCategories(title: "هدفون و هندزفری", list: headphoneSubCategoriesLst),
                      subCategories(title: "تجهیزات ذخیره‌سازی", list: storageSubCategoriesLst),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  parentCategories() {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 300,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 80,
          mainAxisSpacing: 20,
        ),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(10),
        itemCount: parentCategoriesLst.length,
        itemBuilder: (BuildContext context, int index) {
          CategoryModel category = parentCategoriesLst[index];
          CategoryImage img = category.image!;
          return InkWell(
            onTap: () => appFun.onTapShowAll(title: category.name!, category: category.id.toString()),
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: img.src!,
                  errorWidget: (context, str, dyn) => const Icon(Icons.image, color: Colors.black26, size: 100),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: width * 0.2,
                  child: TextBodyMediumView(category.name!, textAlign: TextAlign.center, maxLines: 2),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  subCategories({required String title, required List<CategoryModel> list}) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.all(10),
            child: TextBodyMediumView(title),
          ),
          SizedBox(
            height: 130,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisExtent: 80,
                mainAxisSpacing: 10,
              ),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                CategoryModel category = list[index];
                CategoryImage img = category.image!;
                return InkWell(
                  onTap: () => appFun.onTapShowAll(title: category.name!, category: category.id.toString()),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: img.src!,
                          width: 70,
                          errorWidget: (context, str, dyn) => const Icon(Icons.image, color: Colors.black26, size: 100),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: width * 0.2,
                          child: TextBodyMediumView(category.name!, textAlign: TextAlign.center, fontSize: 12, maxLines: 2),
                        ),
                      ],
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
