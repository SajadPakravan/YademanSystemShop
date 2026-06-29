import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/views/categories/show_all_view.dart';

class ShowAllScreen extends StatefulWidget {
  const ShowAllScreen({super.key});

  @override
  State<ShowAllScreen> createState() => _ShowAllScreenState();
}

class _ShowAllScreenState extends State<ShowAllScreen> {
  HttpRequest httpRequest = HttpRequest();
  List<ProductModel> productsLst = [];
  String category = Get.arguments['category'];
  String onSale = Get.arguments['onSale'];
  int page = 1;
  bool moreProduct = false;
  int productCount = 0;

  Future<void> getProducts() async {
    if (!moreProduct) {
      setState(() {
        productsLst.clear();
        page = 1;
      });
    }

    dynamic jsonProducts = await httpRequest.getProducts(page: page, category: category, onSale: onSale);
    setState(() => productCount = 0);
    jsonProducts.forEach((p) {
      setState(() {
        productsLst.add(ProductModel.fromJson(p));
        productCount++;
      });
    });
    setState(() => moreProduct = false);
  }

  Future<void> onMoreBtn() async {
    if (!moreProduct) {
      moreProduct = true;
      page++;
      getProducts();
    }
    await Future<void>.delayed(const Duration(seconds: 5));
  }

  Future<void> onRefresh() async {
    getProducts();
    await Future<void>.delayed(const Duration(seconds: 5));
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return ShowAllView(
      context: context,
      onRefresh: onRefresh,
      productsLst: productsLst,
      productCount: productCount,
      onMoreBtn: onMoreBtn,
    );
  }
}
