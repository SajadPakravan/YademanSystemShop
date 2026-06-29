import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/database/cart_model.dart';
import 'package:yad_sys/database/favorite_model.dart';
import 'package:yad_sys/models/product_model.dart';
import 'package:yad_sys/models/review_model.dart';
import 'package:yad_sys/tools/app_cache.dart';
import 'package:yad_sys/views/product/product_view.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  HttpRequest httpRequest = HttpRequest();
  ProductModel product = ProductModel();
  Box<CartModel> cartBox = Hive.box<CartModel>('cartBox');
  Box<FavoriteModel> favoritesBox = Hive.box<FavoriteModel>('favoritesBox');
  List<ReviewModel> reviewsLst = [];
  List<ProductModel> relatedProductsLst = [];
  int? id;
  bool loading = false;
  int dataNumber = 0;
  String name = '';
  String email = '';
  bool authError = false;
  bool personalInfoError = false;
  bool existCart = false;
  int quantity = 0;
  IconData favoriteIcon = Icons.favorite_border;
  Color favoriteIconColor = Colors.black87;
  int slideIndex = 0;
  TextEditingController review = TextEditingController();
  int rating = 0;

  Future<void> loadContent({int? id}) async {
    switch (dataNumber) {
      case 0:
        {
          setState(() => loading = true);
          getProduct(id!);
          break;
        }
      case 1:
        {
          setState(() => loading = true);
          getProductReviews(id!);
          break;
        }
      case 2:
        {
          getRelatedProducts();
          break;
        }
      default:
        {
          await checkLogged();
          checkCart();
          checkFavorites();
          setState(() => loading = false);
          break;
        }
    }
  }

  Future<void> getProduct(int id) async {
    if (product.id == null) {
      dynamic jsonProduct = await httpRequest.getProduct(id: id);
      setState(() => product = ProductModel.fromJson(jsonProduct));
    }
    dataNumber++;
    loadContent(id: id);
  }

  Future<void> getProductReviews(int id) async {
    setState(() => reviewsLst.clear());
    dynamic jsonReviews = await httpRequest.getProductReviews(id: id);
    jsonReviews.forEach((r) => setState(() => reviewsLst.add(ReviewModel.fromJson(r))));
    dataNumber++;
    loadContent();
  }

  Future<void> getRelatedProducts() async {
    setState(() => relatedProductsLst.clear());
    ProductCategory category = product.categories![0];
    dynamic jsonRelatedProducts = await httpRequest.getProducts(perPage: 11, category: category.id.toString());
    jsonRelatedProducts.forEach((p) => setState(() => relatedProductsLst.add(ProductModel.fromJson(p))));
    setState(() => relatedProductsLst.removeWhere((element) => element.id == product.id));
    dataNumber++;
    loadContent();
  }

  Future<void> checkLogged() async {
    AppCache cache = AppCache();
    name = await cache.getString('name') ?? '';
    email = await cache.getString('email') ?? '';
    setState(() {
      authError = email.toString().isEmpty;
      personalInfoError = name.toString().isEmpty;
    });
  }

  void checkCart() {
    setState(() => existCart = false);
    if (!authError && cartBox.isNotEmpty) {
      for (int i = 0; i < cartBox.length; i++) {
        CartModel cart = cartBox.getAt(i)!;
        if (cart.id == product.id) {
          setState(() {
            quantity = cart.quantity;
            existCart = true;
          });
        }
      }
    }
  }

  void checkFavorites() {
    setState(() {
      favoriteIcon = Icons.favorite_border;
      favoriteIconColor = Colors.black87;
    });
    if (!authError && favoritesBox.isNotEmpty) {
      for (int i = 0; i < favoritesBox.length; i++) {
        FavoriteModel favorite = favoritesBox.getAt(i)!;
        if (favorite.id == product.id) {
          setState(() {
            favoriteIcon = Icons.favorite;
            favoriteIconColor = Colors.red;
          });
        }
      }
    }
  }

  onSlideChange(index) => setState(() => slideIndex = index);

  addCart() async {
    if (!authError) {
      ProductImage img = product.images![0];
      setState(() {
        cartBox.add(CartModel(
          id: product.id!,
          name: product.name!,
          image: img.src!,
          price: int.parse(product.price!),
          quantity: 1,
          shippingClass: product.shippingClass!,
        ));
      });
      checkCart();
    } else {
      if (mounted) SnackBarView.show(context, 'برای افزودن محصول به سبد خرید لطفا وارد حساب کاربری شوید');
    }
  }

  addRemoveFavorite() async {
    if (!authError) {
      if (favoriteIconColor == Colors.red) {
        final fav = favoritesBox.values.firstWhere((element) => element.id == product.id);
        fav.delete();
      } else {
        ProductImage img = product.images![0];
        setState(() {
          favoritesBox.add(FavoriteModel(
            id: product.id!,
            name: product.name!,
            image: img.src!,
            price: int.parse(product.price!),
            regularPrice: int.parse(product.regularPrice!),
            onSale: product.onSale!,
          ));
        });
      }
      checkFavorites();
    } else {
      if (mounted) SnackBarView.show(context, 'برای افزودن محصول به لیست علاقه‌مندی‌ها لطفا وارد حساب کاربری شوید');
    }
  }

  relatedProductOnTap(ProductModel p) {
    setState(() {
      dataNumber = 0;
      product = p;
      review.clear();
    });
    loadContent(id: p.id);
  }

  onRatingUpdate(double value) => setState(() => rating = value.toInt());

  createReview() async {
    if (authError) {
      SnackBarView.show(context, 'برای ثبت دیدگاه خود لطفا وارد حساب کاربری شوید و مشخصات فردی را تکمیل کنید');
    } else if (personalInfoError) {
      SnackBarView.show(context, 'برای ثبت دیدگاه خود لطفا مشخصات فردی را تکمیل کنید');
    } else {
      if (review.text.isEmpty || rating == 0) {
        SnackBarView.show(context, 'لطفا دیدگاه و امتیاز خود را وارد کنید');
      } else {
        dynamic jsonReview = await httpRequest.createProductReview(
          context: context,
          id: product.id!,
          review: review.text,
          reviewer: name,
          email: email,
          rating: rating,
        );
        if (jsonReview != false) {
          if (mounted) SnackBarView.show(context, 'دیدگاه شما ثبت شد و در حال بررسی است');
          setState(() {
            review.clear();
            rating = 0;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      product = Get.arguments['product'] ?? ProductModel();
      id = Get.arguments['id'];
    });
    loadContent(id: product.id ?? id);
  }

  @override
  Widget build(BuildContext context) {
    return ProductView(
      context: context,
      product: product,
      reviewsLst: reviewsLst,
      relatedProductsLst: relatedProductsLst,
      loading: loading,
      authError: authError,
      personalInfoError: personalInfoError,
      existCart: existCart,
      quantity: quantity,
      favoriteIcon: favoriteIcon,
      favoriteIconColor: favoriteIconColor,
      slideIndex: slideIndex,
      onSlideChange: onSlideChange,
      addCart: addCart,
      checkCart: checkCart,
      addRemoveFavorite: addRemoveFavorite,
      review: review,
      rating: rating,
      onRatingUpdate: onRatingUpdate,
      createReview: createReview,
      relatedProductOnTap: relatedProductOnTap,
    );
  }
}
