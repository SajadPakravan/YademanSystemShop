import 'package:yad_sys/models/product/product_item_model.dart';
import 'package:yad_sys/models/product/products_list_model.dart';

/// مدل پاسخ این API با صفحه‌بندی مشترک فروشگاه.
class ViewedProductsModel {
  ViewedProductsModel({required this.success, required this.count, required this.data, required this.pagination});

  final bool success;
  final int count;
  final List<ProductItemModel> data;
  final ProductsPaginationModel pagination;

  /// تبدیل داده‌های API و صفحه‌بندی اختصاصی به مدل.
  factory ViewedProductsModel.fromJson(Map<String, dynamic> json) {
    final count = int.tryParse(json['count']?.toString() ?? '') ?? 0;
    return ViewedProductsModel(
      success: json['success'] == true,
      count: count,
      pagination: ProductsPaginationModel.fromJson(json['pagination'], totalKey: 'total_viewed_products', fallbackCount: count),
      data: (json['data'] is List ? json['data'] as List : const [])
          .whereType<Map>()
          .map((item) => ProductItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}
