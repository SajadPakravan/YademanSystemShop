import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/category_model.dart';
import 'package:yad_sys/models/product_model.dart';

class ShopViewModel with ChangeNotifier {
  HttpRequest httpRequest = HttpRequest();
  List<ProductModel> productsLst = [];
  List<CategoryModel> categoriesLst = [];
  List<int> categoriesId = [];
  List<Map<String, dynamic>> filtersLst = [];
  int filterSelected = 1;
  bool visibleReloadCover = true;
  int page = 1;
  bool moreProduct = false;
  int productCount = 0;

  setFilters() async {
    filtersLst.add({'index': 0, 'name': 'جدیدترین', 'order': 'desc', 'orderby': 'date', 'onSale': 'false', 'select': true});
    filtersLst.add({'index': 1, 'name': 'قدیمی‌ترین', 'order': 'asc', 'orderby': 'date', 'onSale': 'false', 'select': false});
    filtersLst.add({'index': 2, 'name': 'تخفیف خورده', 'order': 'desc', 'orderby': 'date', 'onSale': 'true', 'select': false});
    filtersLst.add({'index': 3, 'name': 'گران‌ترین', 'order': 'desc', 'orderby': 'price', 'onSale': 'false', 'select': false});
    filtersLst.add({'index': 4, 'name': 'ارزان ترین', 'order': 'asc', 'orderby': 'price', 'onSale': 'false', 'select': false});
    filtersLst.add({'index': 5, 'name': 'محبوب‌ترین', 'order': 'desc', 'orderby': 'popularity', 'onSale': 'false', 'select': false});
    filtersLst.add({'index': 6, 'name': 'بالاترین امتیاز', 'order': 'desc', 'orderby': 'rating', 'onSale': 'false', 'select': false});
    dynamic jsonCategories = await httpRequest.getCategories(perPage: 100);
    jsonCategories.forEach((category) {
      categoriesLst.add(CategoryModel.fromJson(category));
      notifyListeners();
    });
    notifyListeners();
  }

  getProducts() async {
    if (!moreProduct) {
      productsLst.clear();
      page = 1;
      notifyListeners();
    }

    for (var filter in filtersLst) {
      if (filter['select']) filterSelected = filter['index'];
    }

    dynamic jsonProducts = await httpRequest.getProducts(
      page: page,
      category: categoriesId.isEmpty ? '' : categoriesId.toString().replaceAll(RegExp(r'[^0-9,]'), ''),
      order: filtersLst[filterSelected]['order'],
      orderBy: filtersLst[filterSelected]['orderby'],
      onSale: filtersLst[filterSelected]['onSale'],
    );
    productCount = 0;
    jsonProducts.forEach((p) {
      productsLst.add(ProductModel.fromJson(p));
      productCount++;
    });
    moreProduct = false;
    notifyListeners();
  }

  onMoreBtn() async {
    if (!moreProduct) {
      moreProduct = true;
      page++;
      getProducts();
    }
    await Future<void>.delayed(const Duration(seconds: 5));
  }
}
