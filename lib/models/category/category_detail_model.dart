import 'package:yad_sys/models/brand_model.dart';
import 'package:yad_sys/models/category/category_item_model.dart';
import 'package:yad_sys/models/product/product_item_model.dart';
import 'package:yad_sys/models/section_model.dart';

class CategoryDetailModel {
  const CategoryDetailModel({required this.success, required this.data});

  final bool success;
  final CategoryDetailData data;

  factory CategoryDetailModel.fromJson(Map<String, dynamic> json) {
    return CategoryDetailModel(success: json['success'] == true, data: CategoryDetailData.fromJson(json['data']));
  }
}

class CategoryDetailData {
  const CategoryDetailData({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.count,
    required this.parents,
    required this.children,
    required this.products,
    required this.brands,
  });

  final int id;
  final String name;
  final String description;
  final String image;
  final int count;
  final List<CategoryItemModel> parents;
  final List<CategoryItemModel> children;
  final List<CategoryDetailProductsGroup> products;
  final List<CategoryDetailBrandsGroup> brands;

  factory CategoryDetailData.fromJson(Map<String, dynamic> json) {
    return CategoryDetailData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      count: json['count'],
      parents: _mapList(json['parents'], CategoryItemModel.fromJson),
      children: _mapList(json['children'], CategoryItemModel.fromJson),
      products: _mapList(json['products'], CategoryDetailProductsGroup.fromJson),
      brands: _mapList(json['brands'], CategoryDetailBrandsGroup.fromJson),
    );
  }
}

class CategoryDetailProductsGroup {
  const CategoryDetailProductsGroup({required this.data, this.viewAll});

  final List<ProductItemModel> data;
  final SectionViewAll? viewAll;

  factory CategoryDetailProductsGroup.fromJson(Map<String, dynamic> json) {
    return CategoryDetailProductsGroup(
      data: _mapList(json['data'], ProductItemModel.fromJson),
      viewAll: json['view_all'] is Map ? SectionViewAll.fromJson(json['view_all']) : null,
    );
  }
}

class CategoryDetailBrandsGroup {
  const CategoryDetailBrandsGroup({required this.data, this.viewAll});

  final List<BrandModel> data;
  final SectionViewAll? viewAll;

  factory CategoryDetailBrandsGroup.fromJson(Map<String, dynamic> json) {
    return CategoryDetailBrandsGroup(
      data: _mapList(json['data'], BrandModel.fromJson),
      viewAll: json['view_all'] is Map ? SectionViewAll.fromJson(json['view_all']) : null,
    );
  }
}

List<T> _mapList<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! List) return <T>[];
  return List<T>.unmodifiable(value.whereType<Map>().map((item) => fromJson(Map<String, dynamic>.from(item))));
}
