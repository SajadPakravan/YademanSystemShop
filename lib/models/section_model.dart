import 'package:yad_sys/models/section_item_action_model.dart';
import 'package:yad_sys/models/category_brand_item_model.dart';
import 'package:yad_sys/models/image_item_model.dart';
import 'package:yad_sys/models/product_card_model.dart';

class SectionModel {
  const SectionModel({
    required this.id,
    required this.type,
    required this.position,
    required this.title,
    required this.subtitle,
    required this.layout,
    required this.data,
    this.viewAll,
  });

  final String id;
  final String type;
  final int position;
  final String title;
  final String subtitle;
  final SectionLayout layout;
  final List<dynamic> data;
  final SectionViewAll? viewAll;

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    final data = <dynamic>[];

    for (final item in json['data']) {
      final map = Map<String, dynamic>.from(item);

      switch (json['type']) {
        case 'image':
          data.add(ImageItemModel.fromJson(map));
          break;
        case 'products':
          data.add(ProductCardModel.fromJson(map));
          break;
        case 'category':
          data.add(CategoryBrandItemModel.fromJson(map));
          break;
        case 'brand':
          data.add(CategoryBrandItemModel.fromJson(map));
          break;
        default:
          data.add(map);
      }
    }

    return SectionModel(
      id: json['id'],
      type: json['type'],
      position: json['position'],
      title: json['title'],
      subtitle: json['subtitle'],
      layout: SectionLayout.fromJson(json['layout']),
      data: data,
      viewAll: json['view_all'] is Map ? SectionViewAll.fromJson(Map<String, dynamic>.from(json['view_all'])) : null,
    );
  }

  List<ImageItemModel> get images => data.whereType<ImageItemModel>().toList();

  List<ProductCardModel> get products => data.whereType<ProductCardModel>().toList();

  List<CategoryBrandItemModel> get categories => data.whereType<CategoryBrandItemModel>().toList();

  List<CategoryBrandItemModel> get brands => data.whereType<CategoryBrandItemModel>().toList();
}

class SectionLayout {
  const SectionLayout({required this.direction, required this.rows, required this.columns});

  final String direction;
  final int rows;
  final int columns;

  factory SectionLayout.fromJson(Map<String, dynamic> json) {
    return SectionLayout(direction: json['direction'], rows: json['rows'], columns: json['columns']);
  }

  bool get isHorizontal => !direction.contains('vertical');
}

class SectionViewAll {
  const SectionViewAll({required this.title, required this.action});

  final String title;
  final SectionItemActionModel action;

  factory SectionViewAll.fromJson(Map<String, dynamic> json) {
    return SectionViewAll(title: json['title'], action: SectionItemActionModel.fromJson(json['action']));
  }
}