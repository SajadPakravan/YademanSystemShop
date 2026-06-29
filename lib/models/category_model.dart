import 'package:flutter/material.dart';

class CategoryModel with ChangeNotifier {
  CategoryModel({
    int? id,
    String? name,
    int? parent,
    CategoryImage? image,
    int? count,
    bool? select,
  }) {
    _id = id;
    _name = name;
    _parent = parent;
    _image = image;
    _count = count;
    _select = select ?? false;
  }

  int? _id;
  String? _name;
  int? _parent;
  CategoryImage? _image;
  int? _count;
  bool? _select;

  int? get id => _id;

  String? get name => _name;

  int? get parent => _parent;

  CategoryImage? get image => _image;

  int? get count => _count;

  bool? get getSelect => _select;

  set setSelect(bool value) {
    _select = value;
    notifyListeners();
  }

  CategoryModel.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _parent = json['parent'];
    _image = json['image'] != null ? CategoryImage.fromJson(json['image']) : null;
    _count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['parent'] = _parent;
    if (_image != null) map['image'] = _image?.toJson();
    map['count'] = _count;
    return map;
  }
}

class CategoryImage {
  CategoryImage({String? src}) {
    _src = src;
  }

  CategoryImage.fromJson(dynamic json) {
    _src = json['src'];
  }

  String? _src;

  String? get src => _src;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['src'] = _src;
    return map;
  }
}
