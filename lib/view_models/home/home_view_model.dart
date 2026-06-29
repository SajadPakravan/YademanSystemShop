import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/category_model.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/models/product_variable_model.dart';

class HomeViewModel with ChangeNotifier {
  final HttpRequest _httpRequest = HttpRequest();
  List<ProductModel> discountLst = [];
  List<ProductVariableModel> discountVariableLst = [];
  List<CategoryModel> categoriesLst = [];
  List<ProductModel> laptopLst = [];
  List<ProductVariableModel> laptopVariableLst = [];
  List<ProductModel> speakerLst = [];
  List<ProductVariableModel> speakerVariableLst = [];
  List<ProductModel> computerLst = [];
  List<ProductVariableModel> computerVariableLst = [];
  int _dataNumber = 1;
  bool showContent = false;

  set dataNumber(int number) {
    _dataNumber = number;
    notifyListeners();
  }

  int get dataNumber => _dataNumber;

  Future<void> getProducts({
    String categoryId = '',
    String onSale = '',
    int perPage = 10,
    required List<ProductModel> productsLst,
    required List<ProductVariableModel> productVariableLst,
  }) async {
    dynamic jsonProducts = await _httpRequest.getProducts(category: categoryId, onSale: onSale, perPage: perPage);
    productsLst.clear();
    jsonProducts.forEach((p) {
      productsLst.add(ProductModel.fromJson(p));
      if (onSale == 'true' && p['type'] == 'variable') {
        getProductVariable(id: p['id'], list: productVariableLst);
      }
    });

    _dataNumber++;
    loadData();
    notifyListeners();
  }

  Future<void> getProductVariable({required int id, required List<ProductVariableModel> list}) async {
    dynamic jsonProductVariable = await _httpRequest.getProductVariable(id: id);
    jsonProductVariable.forEach((p) => list.add(ProductVariableModel.fromJson(p)));
  }

  Future<void> getParentCategories() async {
    dynamic jsonCategories = await _httpRequest.getCategories(perPage: 9, include: "55,77,166,170,169,76,68,70,173");
    categoriesLst.clear();
    jsonCategories.forEach((c) => categoriesLst.add(CategoryModel.fromJson(c)));
    _dataNumber++;
    loadData();
    notifyListeners();
  }

  void loadData() {
    switch (_dataNumber) {
      case 1:
        {
          getProducts(onSale: 'true', productsLst: discountLst, productVariableLst: discountVariableLst);
          break;
        }
      case 2:
        {
          getParentCategories();
          break;
        }
      case 3:
        {
          getProducts(categoryId: "55", perPage: 9, productsLst: laptopLst, productVariableLst: laptopVariableLst);
          break;
        }
      case 4:
        {
          getProducts(categoryId: "166", perPage: 9, productsLst: speakerLst, productVariableLst: speakerVariableLst);
          break;
        }
      case 5:
        {
          getProducts(categoryId: "77", perPage: 9, productsLst: computerLst, productVariableLst: computerVariableLst);
          break;
        }
      default:
        {
          showContent = true;
          notifyListeners();
          break;
        }
    }
  }
}
