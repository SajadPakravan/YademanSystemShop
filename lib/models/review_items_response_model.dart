import 'package:yad_sys/models/product/products_list_model.dart';

import 'package:yad_sys/models/review_item_model.dart';

/// مدل پاسخ این API با صفحه‌بندی مشترک فروشگاه.
class ReviewItemsResponseModel {
  const ReviewItemsResponseModel({required this.success, required this.count, required this.data, required this.pagination});
  final ProductsPaginationModel pagination;

  final bool success;
  final int count;
  final List<ReviewItemModel> data;

  /// تبدیل داده‌های API و صفحه‌بندی اختصاصی به مدل.
  factory ReviewItemsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] is List ? json['data'] as List : const <dynamic>[];

    return ReviewItemsResponseModel(
      pagination: ProductsPaginationModel.fromJson(json['pagination'], totalKey: 'total_comments', fallbackCount: _asInt(json['count'])),
      success: json['success'] == true,
      count: _asInt(json['count']),
      data: rawData
          .whereType<Map>()
          .map((item) => ReviewItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
