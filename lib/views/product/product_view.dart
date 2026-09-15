import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_detail_model.dart';
import 'package:yad_sys/screens/product/product_info_screen.dart';
import 'package:yad_sys/screens/profile/cart/cart_screen.dart';
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/view_models/product/product_view_model.dart';
import 'package:yad_sys/widgets/cards/related_product_card.dart';
import 'package:yad_sys/widgets/image_slides/product_slide.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_large_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_small_view.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key, required this.viewModel});

  final ProductViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: NestedScrollView(floatHeaderSlivers: true, headerSliverBuilder: (context, innerBoxIsScrolled) => [_appBar(context)], body: _body(context)),
        bottomNavigationBar: viewModel.product == null || viewModel.isLoading ? null : _cartPrice(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (viewModel.isLoading && viewModel.product == null) {
      return const Loading();
    }

    if (viewModel.product == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 52, color: Colors.black38),
              const SizedBox(height: 12),
              Text(viewModel.errorMessage.isEmpty ? 'اطلاعات محصول در دسترس نیست.' : viewModel.errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => viewModel.loadProduct(forceRefresh: true), child: const Text('تلاش دوباره')),
            ],
          ),
        ),
      );
    }

    final product = viewModel.product!;

    return SingleChildScrollView(
      child: Column(
        children: [
          ProductSlide(
            images: viewModel.product!.gallery,
            slideIndex: viewModel.slideIndex,
            onSlideChange: viewModel.onSlideChange,
            onImageTap: viewModel.onTapProductImage,
          ),
          const SizedBox(height: 12),
          _productDetails(product, context),
          const SizedBox(height: 18),
          _reviewForm(context),
          if (viewModel.product!.relatedProducts.isNotEmpty) ...[const SizedBox(height: 20), _relatedProducts()],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  SliverAppBar _appBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.black54),
      title: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () async {
                if (viewModel.authError) {
                  SnackBarView.show(context, 'برای نمایش سبد خرید لطفا وارد حساب کاربری شوید');
                  return;
                }

                await Get.to(const CartScreen(), transition: Transition.upToDown, duration: const Duration(milliseconds: 300));
                await viewModel.refreshCartState();
              },
            ),
            IconButton(
              icon: Icon(viewModel.isFavorite ? Icons.favorite : Icons.favorite_border, color: viewModel.isFavorite ? Colors.red : Colors.black87),
              onPressed: () => viewModel.addRemoveFavorite(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productDetails(ProductDetail product, BuildContext context) {
    final categories = product.categories.map((item) => item.name).join('، ');
    final visibleAttributes = product.attributes.where((item) => item.visible).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (categories.isNotEmpty) TextBodySmallView('دسته‌بندی: $categories', color: Colors.blue.shade900),
          if (product.brand.name.isNotEmpty) ...[const SizedBox(height: 4), TextBodySmallView('برند: ${product.brand.name}', color: Colors.black54)],
          const SizedBox(height: 14),
          if (product.description.isNotEmpty) _infoBtn(title: 'معرفی محصول', content: 1, product: product),
          if (visibleAttributes.isNotEmpty) _infoBtn(title: 'مشخصات محصول', content: 2, product: product),
          if (viewModel.product!.reviews.isNotEmpty) _infoBtn(title: 'دیدگاه‌ها', content: 3, product: product),
        ],
      ),
    );
  }

  Widget _infoBtn({required String title, required int content, required ProductDetail product}) {
    return InkWell(
      onTap: () => rightToPage(
        const ProductInfoScreen(),
        arguments: <String, dynamic>{'content': content, 'description': product.description, 'attributes': product.attributes, 'reviews': product.reviews},
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextBodyMediumView(title),
            const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _reviewForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: viewModel.reviewController,
            style: ThemeData.light().textTheme.bodyMedium,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'دیدگاه خود را بنویسید',
              hintStyle: ThemeData.light().textTheme.bodyMedium!.copyWith(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 16),
          const TextBodyMediumView('لطفا به محصول امتیاز دهید:'),
          const SizedBox(height: 5),
          RatingBar.builder(
            initialRating: viewModel.rating.toDouble(),
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 5),
            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: viewModel.onRatingUpdate,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.18),
            child: EasyButton(
              idleStateWidget: const TextBodyMediumView('ثبت دیدگاه', color: Colors.white),
              loadingStateWidget: const Padding(
                padding: EdgeInsets.all(5),
                child: Loading(color: Colors.white),
              ),
              borderRadius: 10,
              buttonColor: ColorStyle.blueFav,
              onPressed: () => viewModel.createReview(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _relatedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: TextBodyMediumView('محصولات مرتبط', fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RelatedProductCard(list: viewModel.product!.relatedProducts),
      ],
    );
  }

  Widget _cartPrice(BuildContext context) {
    final product = viewModel.product!;
    final hasDiscount = product.discountPercent > 0 && product.regularPrice > product.price;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12, width: 2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: viewModel.existCart
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBodyMediumView(
                          '${viewModel.quantity.toString().toPersianDigit()} عدد در سبد خرید شما',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Get.to(const CartScreen(), transition: Transition.downToUp, duration: const Duration(milliseconds: 300));
                              await viewModel.refreshCartState();
                            },
                            child: const Text('رفتن به سبد خرید'),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: product.stockQuantity > 0 && product.price > 0 ? () => viewModel.addCart(context) : null,
                        child: Text(product.stockQuantity > 0 && product.price > 0 ? 'افزودن به سبد خرید' : 'استعلام قیمت و موجودی'),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasDiscount)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          '٪${product.discountPercent.toString().toPersianDigit()}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.regularPrice.toString().toPersianDigit().seRagham(),
                        style: const TextStyle(color: Colors.black38, decoration: TextDecoration.lineThrough, fontSize: 12),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                TextBodyLargeView('${product.price.toString().toPersianDigit().seRagham()} تومان', fontWeight: FontWeight.bold),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
