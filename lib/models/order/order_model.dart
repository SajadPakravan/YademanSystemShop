import 'package:yad_sys/models/product/products_list_model.dart';

import 'package:yad_sys/models/order/order_item_model.dart';

/// مدل پاسخ این API با صفحه‌بندی مشترک فروشگاه.
class OrdersResponseModel {
  const OrdersResponseModel({required this.success, required this.count, required this.data, required this.pagination});
  final ProductsPaginationModel pagination;

  final bool success;
  final int count;
  final List<OrderModel> data;

  /// تبدیل داده‌های API و صفحه‌بندی اختصاصی به مدل.
  factory OrdersResponseModel.fromJson(Map<String, dynamic> json) {
    return OrdersResponseModel(
      pagination: ProductsPaginationModel.fromJson(json['pagination'], totalKey: 'total_orders', fallbackCount: _asInt(json['count'])),
      success: json['success'] == true,
      count: _asInt(json['count']),
      data: _asList(json['data'])
          .whereType<Map>()
          .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.status,
    required this.date,
    required this.total,
    required this.paymentMethod,
    required this.itemCount,
    required this.items,
  });

  final int id;
  final String status;
  final String date;
  final int total;
  final String paymentMethod;
  final int itemCount;
  final List<OrderItemModel> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final items = _asList(json['items'])
        .whereType<Map>()
        .map((item) => OrderItemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    return OrderModel(
      id: _asInt(json['id']),
      status: _asString(json['status']),
      date: _asString(json['date']),
      total: _asInt(json['total']),
      paymentMethod: _asString(json['payment_method']),
      itemCount: _asInt(json['item_count'], fallback: items.length),
      items: items,
    );
  }

  bool get isOpen {
    final value = status.toLowerCase();
    return value != 'completed' && value != 'cancelled';
  }
}

List<dynamic> _asList(dynamic value) => value is List ? value : const <dynamic>[];
String _asString(dynamic value) => value?.toString() ?? '';

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
