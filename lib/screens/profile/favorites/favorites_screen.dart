import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/database/favorite_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Box<FavoriteModel> favoritesBox = Hive.box<FavoriteModel>('favoritesBox');

  Future<void> deleteFavorite({required int id}) async {
    final fav = favoritesBox.values.firstWhere((element) => element.id == id);
    await fav.delete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppBarView(title: 'علاقه‌مندی‌ها'),
        body: ValueListenableBuilder(
          valueListenable: favoritesBox.listenable(),
          builder: (context, Box<FavoriteModel> box, _) {
            if (box.isEmpty) {
              return const Center(child: TextBodyMediumView('لیست علاقه‌مندی‌های شما خالی است'));
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: r.space(6)),
              itemCount: box.length,
              itemBuilder: (context, index) {
                final favorite = box.getAt(index)!;
                final price = favorite.price;
                final regularPrice = favorite.regularPrice;
                final percent = favorite.onSale && regularPrice > 0
                    ? (((price - regularPrice) / regularPrice) * 100).roundToDouble().toInt().abs()
                    : 0;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding, vertical: r.space(6)),
                  padding: EdgeInsets.all(r.space(10)),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(r.cardRadius),
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: CachedNetworkImage(
                          imageUrl: favorite.image,
                          fit: BoxFit.contain,
                          errorWidget: (_, _, _) => Icon(Icons.image_not_supported_outlined, color: colors.textMuted, size: r.icon(42)),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: r.space(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextBodyMediumView(
                                favorite.name,
                                fontWeight: FontWeight.bold,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: r.space(10)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (favorite.onSale) ...[
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(horizontal: r.space(7), vertical: r.space(4)),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(r.radius(10)),
                                      ),
                                      child: TextBodyMediumView(
                                        '${percent.toString().toPersianDigit()}%',
                                        color: AppColors.onBrand,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: r.space(10)),
                                  ],
                                  Column(
                                    children: [
                                      if (favorite.onSale) ...[
                                        TextBodyMediumView(
                                          '${price.toString().toPersianDigit().seRagham()} تومان',
                                          textAlign: TextAlign.left,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        SizedBox(height: r.space(4)),
                                      ],
                                      TextBodyMediumView(
                                        '${regularPrice.toString().toPersianDigit().seRagham()}${favorite.onSale ? '' : ' تومان'}',
                                        textAlign: TextAlign.left,
                                        fontWeight: FontWeight.bold,
                                        fontSize: favorite.onSale ? 12 : 14,
                                        color: favorite.onSale ? colors.textMuted : colors.textPrimary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: r.space(8)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.open_in_browser, color: AppColors.primary, size: r.icon(34)),
                                    onPressed: () => toProduct(id: favorite.id),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline_rounded, color: AppColors.accent, size: r.icon(34)),
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
