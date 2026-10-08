import 'package:yad_sys/models/product/product_item_model.dart';
import 'package:yad_sys/models/product/products_list_model.dart';

/// مدل پاسخ این API با صفحه‌بندی مشترک فروشگاه.
class FavoritesModel {
  const FavoritesModel({required this.success, required this.count, required this.data, required this.pagination});
  final bool success;
  final int count;
  final List<ProductItemModel> data;
  final ProductsPaginationModel pagination;
  /// تبدیل داده‌های API و صفحه‌بندی اختصاصی به مدل.
  factory FavoritesModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is List ? json['data'] as List : const []).whereType<Map>().map((item) => ProductItemModel.fromJson(Map<String, dynamic>.from(item))).toList();
    final count = int.tryParse(json['count']?.toString() ?? '') ?? data.length;
    return FavoritesModel(success: json['success'] == true, count: count, data: data, pagination: ProductsPaginationModel.fromJson(json['pagination'], totalKey: 'total_favorites', fallbackCount: count));
  }
}
