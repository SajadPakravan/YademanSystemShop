import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/database/favorite_model.dart';
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Box<FavoriteModel> favoritesBox = Hive.box<FavoriteModel>('favoritesBox');

  deleteFavorite({required int id}) async {
    final fav = favoritesBox.values.firstWhere((element) => element.id == id);
    fav.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppBarView(title: 'علاقه‌مندی‌ها'),
        body: ValueListenableBuilder(
          valueListenable: favoritesBox.listenable(),
          builder: (context, Box<FavoriteModel> box, _) {
            if (box.isEmpty) return const Center(child: TextBodyMediumView('لیست علاقه‌مندی‌های شما خالی است'));
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                FavoriteModel favorite = box.getAt(index)!;

                int price = favorite.price;
                int regularPrice = favorite.regularPrice;
                int percent = 0;
                String toman = ' تومان';
                Color textColor = Colors.black87;
                double fontSize = 14;

                if (favorite.onSale) {
                  textColor = Colors.black45;
                  fontSize = 12;
                  toman = '';
                  percent = (((price - regularPrice) / regularPrice) * 100).roundToDouble().toInt();
                }
                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Flexible(flex: 1, child: CachedNetworkImage(imageUrl: favorite.image, fit: BoxFit.contain)),
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextBodyMediumView(favorite.name, fontWeight: FontWeight.bold, textAlign: TextAlign.center, maxLines: 1),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Visibility(
                                    visible: favorite.onSale,
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(color: Colors.red.shade600),
                                      child: TextBodyMediumView(
                                        "${percent.toString().replaceAll('-', '').toPersianDigit()}%",
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    children: [
                                      Visibility(
                                        visible: favorite.onSale,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          margin: const EdgeInsets.only(bottom: 5),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextBodyMediumView(
                                                '${price.toString().toPersianDigit().seRagham()} تومان',
                                                textAlign: TextAlign.left,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextBodyMediumView(
                                              regularPrice.toString().toPersianDigit().seRagham(),
                                              textAlign: TextAlign.left,
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontSize,
                                              color: textColor,
                                            ),
                                            TextBodyMediumView(toman, fontWeight: FontWeight.bold),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.open_in_browser, color: ColorStyle.blueFav, size: 40),
                                    onPressed: () => toProduct(id: favorite.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: ColorStyle.blueFav, size: 40),
                                    onPressed: () => deleteFavorite(id: favorite.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
