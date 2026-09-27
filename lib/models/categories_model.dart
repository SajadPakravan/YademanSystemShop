import 'package:yad_sys/models/section_model.dart';

class CategoriesModel {
  const CategoriesModel({required this.success, required this.sections});

  final bool success;
  final List<SectionModel> sections;

  factory CategoriesModel.fromJson(Map<String, dynamic> json) {
    return CategoriesModel(success: json['success'], sections: List.castFrom(json['sections']).map((item) => SectionModel.fromJson(item)).toList());
  }
}