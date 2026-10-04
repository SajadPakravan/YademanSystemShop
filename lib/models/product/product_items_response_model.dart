import 'package:yad_sys/models/product/product_item_model.dart';

class ProductItemsResponseModel {
  const ProductItemsResponseModel({required this.success, required this.count, required this.data});

  final bool success;
  final int count;
  final List<ProductItemModel> data;

  factory ProductItemsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] is List ? json['data'] as List : const <dynamic>[];

    return ProductItemsResponseModel(
      success: json['success'] == true,
      count: _asInt(json['count']),
      data: rawData
          .whereType<Map>()
          .map((item) => ProductItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
