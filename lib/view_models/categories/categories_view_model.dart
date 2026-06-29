import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/category_model.dart';

class CategoriesViewModel with ChangeNotifier {
  HttpRequest httpRequest = HttpRequest();
  List<CategoryModel> parentCategoriesLst = [];
  List<CategoryModel> speakerSubCategoriesLst = [];
  List<CategoryModel> computerSubCategoriesLst = [];
  List<CategoryModel> hardwareSubCategoriesLst = [];
  List<CategoryModel> laptopSubCategoriesLst = [];
  List<CategoryModel> headphoneSubCategoriesLst = [];
  List<CategoryModel> storageSubCategoriesLst = [];
  List<CategoryModel> networkSubCategoriesLst = [];
  int dataNumber = 1;
  bool showContent = false;

  getParentCategories() async {
    dynamic jsonCategories = await httpRequest.getCategories(perPage: 12, include: "57,1818,1809,54,153,158,67,1601,1773,51,1816,151");
    jsonCategories.forEach((c) => parentCategoriesLst.add(CategoryModel.fromJson(c)));
    dataNumber++;
    loadContent();
  }

  getSubCategories({required int parent, required List<CategoryModel> list}) async {
    dynamic jsonCategories = await httpRequest.getCategories(parent: parent, perPage: 100);
    jsonCategories.forEach((c) => list.add(CategoryModel.fromJson(c)));
    dataNumber++;
    loadContent();
  }

  loadContent() {
    switch (dataNumber) {
      case 1:
        {
          getParentCategories();
          break;
        }
      case 2:
        {
          getSubCategories(parent: 153, list: speakerSubCategoriesLst);
          break;
        } //اسپیکر
      case 3:
        {
          getSubCategories(parent: 1809, list: computerSubCategoriesLst);
          break;
        } // لوازم جانبی کامپیوتر
      case 4:
        {
          getSubCategories(parent: 54, list: hardwareSubCategoriesLst);
          break;
        } // سخت افزار کامپیوتر
      case 5:
        {
          getSubCategories(parent: 1818, list: laptopSubCategoriesLst);
          break;
        } // لوازم جانبی لپ تاپ// هدفون و هندزفری
      case 6:
        {
          getSubCategories(parent: 158, list: headphoneSubCategoriesLst);
          break;
        } // هدفون و هندزفری
      case 7:
        {
          getSubCategories(parent: 1601, list: storageSubCategoriesLst);
          break;
        } // تجهیزات ذخیره سازی
      default:
        {
          showContent = true;
          notifyListeners();
          break;
        }
    }
  }
}
