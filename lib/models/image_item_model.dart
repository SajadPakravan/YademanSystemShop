import 'package:yad_sys/models/section_item_action_model.dart';

class ImageItemModel {
  const ImageItemModel({required this.title, required this.subtitle, required this.image, required this.action});

  final String title;
  final String subtitle;
  final String image;
  final SectionItemActionModel action;

  factory ImageItemModel.fromJson(Map<String, dynamic> json) {
    return ImageItemModel(title: json['title'], subtitle: json['subtitle'], image: json['image'], action: SectionItemActionModel.fromJson(json['action']));
  }
}
