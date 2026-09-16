import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_detail_model.dart';
import 'package:yad_sys/screens/product/product_info_screen.dart';
import 'package:yad_sys/screens/profile/cart/cart_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/view_models/product/product_view_model.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/cards/related_product_card.dart';
import 'package:yad_sys/widgets/image_slides/product_slide.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';
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
    final r = context.responsive;
    final colors = context.appColors;

    if (viewModel.isLoading && viewModel.product == null) return const Loading();

    if (viewModel.product == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(r.pageHorizontalPadding * 1.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: r.icon(52), color: colors.textMuted),
              SizedBox(height: r.space(12)),
              AppText.bodyMedium(
                viewModel.errorMessage.isEmpty ? 'اطلاعات محصول در دسترس نیست.' : viewModel.errorMessage,
                textAlign: TextAlign.center,
                color: colors.textSecondary,
              ),
              SizedBox(height: r.space(16)),
              SizedBox(
                width: r.percentWidth(0.48, min: 160, max: 230),
                child: AppButton(label: 'تلاش دوباره', icon: Icons.refresh, onPressed: () => viewModel.loadProduct(forceRefresh: true)),
              ),
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
            images: product.gallery,
            slideIndex: viewModel.slideIndex,
            onSlideChange: viewModel.onSlideChange,
            onImageTap: viewModel.onTapProductImage,
          ),
          SizedBox(height: r.space(12)),
          _productDetails(product, context),
          SizedBox(height: r.space(18)),
          _reviewForm(context),
          if (product.relatedProducts.isNotEmpty) ...[SizedBox(height: r.space(20)), _relatedProducts(context)],
          SizedBox(height: r.space(20)),
        ],
      ),
    );
  }

  SliverAppBar _appBar(BuildContext context) {
    final colors = context.appColors;
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: colors.surface,
      surfaceTintColor: AppColors.transparent,
      elevation: 1,
      iconTheme: IconThemeData(color: colors.textSecondary),
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
              icon: Icon(viewModel.isFavorite ? Icons.favorite : Icons.favorite_border, color: viewModel.isFavorite ? colors.favorite : colors.textPrimary),
              onPressed: () => viewModel.addRemoveFavorite(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productDetails(ProductDetail product, BuildContext context) {
    final r = context.responsive;
    final visibleAttributes = product.attributes.where((item) => item.visible).toList(growable: false);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
      child: Column(
        spacing: r.space(10),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          detailHeader(product, context),
          if (product.description.isNotEmpty) descriptionView(product, context),
          if (visibleAttributes.isNotEmpty) attributesView(product, context),
          if (product.reviews.isNotEmpty) _infoBtn(context: context, title: 'دیدگاه‌ها', content: 3, product: product),
        ],
      ),
    );
  }

  Widget detailHeader(ProductDetail product, BuildContext context) {
    final r = context.responsive;
    final pR = product.reviews[0];
    final reviews = pR.data;
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      padding: EdgeInsets.only(bottom: r.space(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          brandCategory(product, context),
          SizedBox(height: r.space(8)),
          AppText.bodyLarge(product.name, maxLines: 3, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, color: colors.textPrimary),
          if (reviews.isNotEmpty) ...[SizedBox(height: r.space(8)), ratingReview(product, context)],
        ],
      ),
    );
  }

  Widget descriptionView(ProductDetail product, BuildContext context) {
    final r = context.responsive;
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      padding: EdgeInsets.only(bottom: r.space(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: r.space(10),
        children: [
          TextBodyMediumView('معرفی کالا', fontWeight: FontWeight.bold),
          ClipRect(
            child: SizedBox(
              height: r.font(baseStyle.fontSize ?? 14) * 1.5 * 3,
              child: HtmlWidget(
                product.description.toString().toPersianDigit(),
                textStyle: baseStyle.copyWith(color: context.appColors.textPrimary, height: 1.5, fontSize: r.font(baseStyle.fontSize ?? 14)),
              ),
            ),
          ),
          moreDetailBtn(context, 'مشاهده ادامه معرفی'),
        ],
      ),
    );
  }

  Widget attributesView(ProductDetail product, BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      padding: EdgeInsets.only(bottom: r.space(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: r.space(10),
        children: [
          TextBodyMediumView('ویژگی‌های کالا', fontWeight: FontWeight.bold),
          SizedBox(
            height: 115,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: product.attributes.length > 3 ? 3 : product.attributes.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: colors.divider),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final attribute = product.attributes[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: r.space(10),
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(color: AppThemeColorsContext(context).isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400),
                        child: AppText.bodyMedium(attribute.name.replaceAll('-', ' '), color: colors.textPrimary),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: AppText.bodyMedium(attribute.options.join('، ').toPersianDigit(), color: colors.textPrimary),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          moreDetailBtn(context, 'مشاهده ادامه ویژگی‌ها'),
        ],
      ),
    );
  }

  Widget moreDetailBtn(BuildContext context, String title) {
    final r = context.responsive;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.width * 0.25),
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppThemeColorsContext(context).isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(r.width),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: r.space(5),
            children: [
              TextBodyMediumView(title),
              Icon(Icons.arrow_forward_ios_rounded, size: r.icon(12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget brandCategory(ProductDetail product, BuildContext context) {
    final categories = product.categories.map((item) => item.name).join('، ');
    final brand = product.brand.name;
    final r = context.responsive;

    return Row(
      spacing: r.space(5),
      children: [
        if (brand.isNotEmpty) ...[TextBodySmallView(brand, fontWeight: FontWeight.bold), Icon(Icons.arrow_forward_ios_rounded, size: r.icon(10))],
        TextBodySmallView(categories, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget ratingReview(ProductDetail product, BuildContext context) {
    final pR = product.reviews[0];
    final reviews = pR.data;
    final r = context.responsive;

    String reviewStr() {
      return '${product.averageRating} (${reviews.length.toString()})'.toPersianDigit();
    }

    return Row(
      children: [
        Icon(Icons.star_rounded, color: Colors.yellow.shade700),
        TextBodySmallView(reviewStr(), fontWeight: FontWeight.bold),
        SizedBox(width: r.space(10)),
        InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppThemeColorsContext(context).isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(r.width),
            ),
            child: Row(
              spacing: r.space(5),
              children: [
                TextBodySmallView('${reviews.length.toString().toPersianDigit()} دیدگاه', fontWeight: FontWeight.bold),
                Icon(Icons.arrow_forward_ios_rounded, size: r.icon(12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoBtn({required BuildContext context, required String title, required int content, required ProductDetail product}) {
    final r = context.responsive;
    final colors = context.appColors;

    return InkWell(
      onTap: () => rightToPage(
        const ProductInfoScreen(),
        arguments: <String, dynamic>{'content': content, 'description': product.description, 'attributes': product.attributes, 'reviews': product.reviews},
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: r.space(18)),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextBodyMediumView(title),
            Icon(Icons.arrow_forward_ios, color: colors.textSecondary, size: r.icon(18)),
          ],
        ),
      ),
    );
  }

  Widget _reviewForm(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return Container(
      padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(4), r.pageHorizontalPadding, r.space(12)),
      margin: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(r.cardRadius),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: viewModel.reviewController,
            style: AppThemeColorsContext(context).textTheme.bodyMedium,
            maxLines: 3,
            minLines: 1,
            decoration: const InputDecoration(hintText: 'دیدگاه خود را بنویسید'),
          ),
          SizedBox(height: r.space(16)),
          const TextBodyMediumView('لطفا به محصول امتیاز دهید:'),
          SizedBox(height: r.space(5)),
          RatingBar.builder(
            initialRating: viewModel.rating.toDouble(),
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: r.space(5)),
            itemBuilder: (context, _) => const Icon(Icons.star, color: AppColors.star),
            onRatingUpdate: viewModel.onRatingUpdate,
          ),
          SizedBox(height: r.space(16)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.percentWidth(0.18, min: 28, max: 90)),
            child: EasyButton(
              idleStateWidget: const TextBodyMediumView('ثبت دیدگاه', color: AppColors.onBrand),
              loadingStateWidget: const Padding(
                padding: EdgeInsets.all(5),
                child: Loading(color: AppColors.onBrand),
              ),
              borderRadius: r.cardRadius,
              buttonColor: AppColors.primary,
              onPressed: () => viewModel.createReview(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _relatedProducts(BuildContext context) {
    final r = context.responsive;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
          child: const TextBodyMediumView('محصولات مرتبط', fontWeight: FontWeight.bold),
        ),
        SizedBox(height: r.space(8)),
        RelatedProductCard(list: viewModel.product!.relatedProducts),
      ],
    );
  }

  Widget _cartPrice(BuildContext context) {
    final product = viewModel.product!;
    final hasDiscount = product.discountPercent > 0 && product.regularPrice > product.price;
    final r = context.responsive;
    final colors = context.appColors;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.all(r.space(10)),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.divider, width: 1.5)),
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
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: r.space(6)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Get.to(const CartScreen(), transition: Transition.downToUp, duration: const Duration(milliseconds: 300));
                              await viewModel.refreshCartState();
                            },
                            child: const AppText.labelLarge('رفتن به سبد خرید', color: AppColors.onBrand),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: product.stockQuantity > 0 && product.price > 0
                          ? ElevatedButton(
                              onPressed: () => viewModel.addCart(context),
                              child: AppText.labelLarge(
                                product.stockQuantity > 0 && product.price > 0 ? 'افزودن به سبد خرید' : 'استعلام قیمت و موجودی',
                                color: AppColors.onBrand,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {},
                              child: AppText.labelLarge('استعلام قیمت و موجودی', color: AppColors.onBrand),
                            ),
                    ),
            ),
            if (product.stockQuantity > 0 && product.price > 0) ...[
              SizedBox(width: r.space(14)),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasDiscount)
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: r.space(8), vertical: r.space(4)),
                          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(r.radius(20))),
                          child: AppText.labelSmall(
                            '٪${product.discountPercent.toString().toPersianDigit()}',
                            color: AppColors.onBrand,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: r.space(6)),
                        AppText.bodySmall(
                          product.regularPrice.toString().toPersianDigit().seRagham(),
                          color: colors.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ],
                    ),
                  SizedBox(height: r.space(4)),
                  TextBodyLargeView('${product.price.toString().toPersianDigit().seRagham()} تومان', fontWeight: FontWeight.bold),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
