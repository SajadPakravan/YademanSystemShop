import 'package:yad_sys/models/section_model.dart';

class HomeModel {
  const HomeModel({required this.success, required this.sections});

  final bool success;
  final List<SectionModel> sections;

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(success: json['success'], sections: List.castFrom(json['sections']).map((item) => SectionModel.fromJson(item)).toList());
  }
}