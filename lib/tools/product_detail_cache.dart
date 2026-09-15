import 'package:yad_sys/models/product_detail_model.dart';

class ProductDetailCache {
  ProductDetailCache._();

  static final ProductDetailCache instance = ProductDetailCache._();

  final Map<int, ProductDetailModel> _items = <int, ProductDetailModel>{};

  ProductDetailModel? get(int productId) => _items[productId];

  void save(ProductDetailModel product) {
    _items[product.data.id] = product;
  }

  void remove(int productId) {
    _items.remove(productId);
  }

  void clear() {
    _items.clear();
  }
}
