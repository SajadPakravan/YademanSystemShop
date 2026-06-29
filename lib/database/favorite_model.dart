import 'package:hive/hive.dart';

part 'favorite_model.g.dart';

@HiveType(typeId: 1)
class FavoriteModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String image;

  @HiveField(3)
  final int price;

  @HiveField(4)
  final int regularPrice;

  @HiveField(5)
  final bool onSale;

  FavoriteModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.regularPrice,
    required this.onSale,
  });
}
