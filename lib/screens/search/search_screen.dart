import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/widgets/cards/product_card_grid.dart';
import 'package:yad_sys/widgets/loading.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  HttpRequest httpRequest = HttpRequest();
  List<ProductModel> productsLst = [];
  bool loading = false;

  getProducts({required String search}) async {
    setState(() => loading = true);
    dynamic jsonProducts = await httpRequest.getProducts(search: search);
    List<ProductModel> products = [];
    jsonProducts.forEach((p) => products.add(ProductModel.fromJson(p)));
    setState(() {
      productsLst = products;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: loading
          ? const Loading()
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ProductCardGrid(list: productsLst),
            ),
    );
  }

  appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black54),
      centerTitle: true,
      title: Directionality(
        textDirection: TextDirection.rtl,
        child: SearchBar(
          leading: const Icon(Icons.search),
          hintStyle: WidgetStateProperty.all(Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black54)),
          hintText: 'محصول مورد نظر خود را جستجو کنید...',
          elevation: WidgetStateProperty.all(0),
          textStyle: WidgetStateProperty.all(Theme.of(context).textTheme.bodyMedium),
          autoFocus: true,
          onChanged: (value) {
            if (value.isEmpty) setState(() => productsLst.clear());
            if (value.length > 3) getProducts(search: value);
          },
        ),
      ),
    );
  }
}
