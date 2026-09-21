import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_detail_model.dart';
import 'package:yad_sys/models/review_card_model.dart';
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
import 'package:yad_sys/widgets/product/product_details_bottom_sheet.dart';
import 'package:yad_sys/widgets/product/product_review_card_widget.dart';
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
        backgroundColor: context.appColors.background,
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
    final reviews = _reviewItems(product);
    final hasRelatedProducts = product.relatedProducts.any((item) => item.data.isNotEmpty);

    return SingleChildScrollView(
      key: ValueKey<int>(viewModel.currentProductId),
      child: Column(
        children: [
          ProductSlide(
            images: viewModel.galleryImages,
            slideIndex: viewModel.slideIndex,
            onSlideChange: viewModel.onSlideChange,
            onImageTap: viewModel.onTapProductImage,
          ),
          SizedBox(height: r.space(12)),
          _productDetails(product, context),
          if (reviews.isNotEmpty) ...[SizedBox(height: r.space(20)), _reviewsSection(product, reviews, context)],
          SizedBox(height: r.space(18)),
          _reviewForm(context),
          if (hasRelatedProducts) ...[SizedBox(height: r.space(22)), _relatedProducts(context)],
          SizedBox(height: r.space(24)),
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
    final visibleAttributes = _visibleAttributes(product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: r.space(18),
      children: [
        detailHeader(product, context),
        if (product.description.trim().isNotEmpty) descriptionView(product, visibleAttributes, context),
        if (visibleAttributes.isNotEmpty) attributesView(product, visibleAttributes, context),
      ],
    );
  }

  Widget detailHeader(ProductDetail product, BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final reviews = _reviewItems(product);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      padding: EdgeInsets.all(r.space(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: r.space(12),
        children: [
          brandCategory(product, context),
          AppText.bodyLarge(product.name, maxLines: 3, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w800, height: 1.65, color: colors.textPrimary),
          if (product.reviewCount > 0 || reviews.isNotEmpty) ratingReview(product, reviews, context),
          if (product.variations.isNotEmpty) variationsView(product.variations, context),
        ],
      ),
    );
  }

  Widget descriptionView(ProductDetail product, List<ProductAttribute> visibleAttributes, BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final plainDescription = _plainText(product.description);

    return _sectionContainer(
      context: context,
      child: Padding(
        padding: EdgeInsets.all(r.space(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.titleSmall('معرفی کالا', fontWeight: FontWeight.w800),
            SizedBox(height: r.space(10)),
            Text(
              plainDescription.toPersianDigit(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: baseStyle.copyWith(color: colors.textPrimary, height: 1.75, fontSize: r.font(baseStyle.fontSize ?? 14)),
            ),
            SizedBox(height: r.space(12)),
            moreDetailBtn(
              context,
              'مشاهده ادامه معرفی',
              onTap: () =>
                  ProductDetailsBottomSheet.show(context: context, description: product.description, attributes: visibleAttributes, initialTabIndex: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget attributesView(ProductDetail product, List<ProductAttribute> visibleAttributes, BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final previewAttributes = visibleAttributes.take(3).toList(growable: false);
    final cardWidth = r.percentWidth(0.3, min: 108, max: r.isTablet ? 210 : 160);
    final cardHeight = r.space(75, min: 75, max: r.isTablet ? 112 : 96);

    return _sectionContainer(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(10)),
            child: Row(
              children: [
                Expanded(child: AppText.titleSmall('مشخصات کالا', fontWeight: FontWeight.w800)),
                if (visibleAttributes.length > 3)
                  InkWell(
                    borderRadius: BorderRadius.circular(r.cardRadius),
                    onTap: () =>
                        ProductDetailsBottomSheet.show(context: context, description: product.description, attributes: visibleAttributes, initialTabIndex: 1),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: r.space(6), vertical: r.space(4)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText.bodySmall('مشاهده همه', fontWeight: FontWeight.w700),
                          SizedBox(width: r.space(4)),
                          Icon(Icons.arrow_forward_ios_rounded, size: r.icon(12), color: colors.textSecondary),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: r.space(10)),
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: previewAttributes.length,
              separatorBuilder: (_, _) => SizedBox(width: r.space(10)),
              padding: EdgeInsets.symmetric(horizontal: r.space(10)),
              itemBuilder: (context, index) {
                final attribute = previewAttributes[index];
                return Container(
                  width: cardWidth,
                  padding: EdgeInsets.all(r.space(10)),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(r.cardRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: r.space(5),
                    children: [
                      AppText.labelSmall(attribute.name.replaceAll('-', ' '), color: colors.textSecondary, maxLines: 1, overflow: TextOverflow.ellipsis),
                      AppText.bodyMedium(
                        attribute.options.join('، ').toPersianDigit(),
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (visibleAttributes.length > 3) ...[
            SizedBox(height: r.space(12)),
            moreDetailBtn(
              context,
              'مشاهده ادامه ویژگی‌ها',
              onTap: () =>
                  ProductDetailsBottomSheet.show(context: context, description: product.description, attributes: visibleAttributes, initialTabIndex: 1),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionContainer({required BuildContext context, required Widget child}) {
    final r = context.responsive;
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: r.space(16)),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: child,
    );
  }

  Widget moreDetailBtn(BuildContext context, String title, {required VoidCallback onTap}) {
    final r = context.responsive;
    final colors = context.appColors;

    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.radius(30)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: r.space(16), vertical: r.space(8)),
          decoration: BoxDecoration(color: colors.chipBackground, borderRadius: BorderRadius.circular(r.radius(30))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.bodySmall(title, fontWeight: FontWeight.w700),
              SizedBox(width: r.space(6)),
              Icon(Icons.arrow_forward_ios_rounded, size: r.icon(11), color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget brandCategory(ProductDetail product, BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
    final categories = product.categories.map((item) => item.name).where((item) => item.trim().isNotEmpty).toList(growable: false);
    final brand = product.brand.name.trim();

    return Wrap(
      spacing: r.space(6),
      runSpacing: r.space(4),
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (brand.isNotEmpty) ...[
          TextBodySmallView(brand, fontWeight: FontWeight.bold, color: colors.textSecondary),
          Icon(Icons.arrow_forward_ios_rounded, size: r.icon(9), color: colors.textMuted),
        ],
        if (categories.isNotEmpty) TextBodySmallView(categories.join('، '), fontWeight: FontWeight.bold, color: colors.textSecondary),
      ],
    );
  }

  Widget ratingReview(ProductDetail product, List<ReviewCardModel> reviews, BuildContext context) {
    final r = context.responsive;
    final reviewCount = product.reviewCount > 0 ? product.reviewCount : reviews.length;

    return Row(spacing: r.space(10), children: [ratingChip(product), _smallInfoChip(context, '${reviewCount.toString().toPersianDigit()} دیدگاه')]);
  }

  Widget ratingChip(ProductDetail product) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: AppColors.star),
        TextBodySmallView(product.averageRating.toPersianDigit(), fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _smallInfoChip(BuildContext context, String title) {
    final r = context.responsive;
    final colors = context.appColors;
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.space(10), vertical: r.space(5)),
        decoration: BoxDecoration(
          color: colors.chipBackground,
          borderRadius: BorderRadius.circular(r.radius(24)),
          border: Border.all(color: colors.textSecondary),
        ),
        child: Row(
          spacing: r.space(5),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.bodySmall(title, fontWeight: FontWeight.w700, color: colors.textSecondary),
            Icon(Icons.arrow_forward_ios_rounded, size: r.icon(11), color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget variationsView(List<ProductVariation> variations, BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: variations
          .map((variation) {
            final selected = viewModel.selectedOptionFor(variation);
            return Padding(
              padding: EdgeInsets.only(bottom: r.space(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.titleSmall(selected == null ? variation.name : '${variation.name}: ${selected.name}', fontWeight: FontWeight.w800),
                  SizedBox(height: r.space(10)),
                  SizedBox(
                    height: r.chipHeight + r.space(8),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: variation.options.length,
                      separatorBuilder: (_, _) => SizedBox(width: r.space(8)),
                      itemBuilder: (context, index) {
                        final option = variation.options[index];
                        return _variationOptionCard(context, variation, option);
                      },
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }

  Widget _variationOptionCard(BuildContext context, ProductVariation variation, ProductVariationOption option) {
    final r = context.responsive;
    final colors = context.appColors;
    final selected = viewModel.isVariationOptionSelected(variation, option);

    return InkWell(
      onTap: () => viewModel.selectVariationOption(variation, option),
      borderRadius: BorderRadius.circular(r.cardRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: r.space(10), vertical: r.space(6)),
        decoration: BoxDecoration(
          color: selected ? colors.chipActiveBackground : colors.surface,
          border: Border.all(color: selected ? colors.textPrimary.withAlpha(80) : colors.border, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(r.cardRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.bodyMedium(option.name, fontWeight: selected ? FontWeight.w800 : FontWeight.w500),
            SizedBox(width: r.space(7)),
            _variationIndicator(context, option, selected),
          ],
        ),
      ),
    );
  }

  Widget _variationIndicator(BuildContext context, ProductVariationOption option, bool selected) {
    final r = context.responsive;
    final colors = context.appColors;
    final size = r.icon(28, min: 24, max: 34);
    final color = _colorForOption(option);

    Widget indicator;
    if (option.image.trim().isNotEmpty) {
      indicator = ClipOval(
        child: CachedNetworkImage(
          imageUrl: option.image,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => ColoredBox(color: _colorForOption(option)),
        ),
      );
    } else {
      indicator = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _colorForOption(option),
          border: Border.all(color: colors.border),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        indicator,
        if (selected)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Icon(
              Icons.check_rounded,
              size: r.icon(18),
              fontWeight: FontWeight.bold,
              color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? AppColors.onBrand : AppColors.shadow,
            ),
          ),
      ],
    );
  }

  Color _colorForOption(ProductVariationOption option) {
    final raw = option.color.trim();
    if (raw.isNotEmpty) {
      final hex = raw.replaceFirst('#', '');
      if (hex.length == 6) {
        final value = int.tryParse('FF$hex', radix: 16);
        if (value != null) return Color(value);
      }
      if (hex.length == 8) {
        final value = int.tryParse(hex, radix: 16);
        if (value != null) return Color(value);
      }
    }
    return AppColors.neutralOption;
  }

  Widget _reviewsSection(ProductDetail product, List<ReviewCardModel> reviews, BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final totalCount = product.reviewCount > 0 ? product.reviewCount : reviews.length;
    final cardHeight = r.space(220, min: 205, max: r.isTablet ? 280 : 240);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: r.space(18)),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.symmetric(horizontal: BorderSide(color: colors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
            child: Row(
              children: [
                Expanded(child: AppText.titleSmall('دیدگاه کاربران', fontWeight: FontWeight.w800)),
                InkWell(
                  onTap: () => _openReviewsPage(product),
                  borderRadius: BorderRadius.circular(r.cardRadius),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.space(4), vertical: r.space(5)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText.bodySmall('مشاهده ${totalCount.toString().toPersianDigit()} دیدگاه', fontWeight: FontWeight.w700),
                        SizedBox(width: r.space(5)),
                        Icon(Icons.arrow_forward_ios_rounded, size: r.icon(12), color: colors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: r.space(10)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: AppColors.star),
                SizedBox(width: r.space(4)),
                AppText.titleSmall(product.averageRating.toPersianDigit(), fontWeight: FontWeight.w900),
                SizedBox(width: r.space(6)),
                AppText.bodySmall('(بر اساس ${totalCount.toString().toPersianDigit()} دیدگاه)', color: colors.textSecondary),
              ],
            ),
          ),
          SizedBox(height: r.space(14)),
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              separatorBuilder: (_, _) => SizedBox(width: r.space(10)),
              itemBuilder: (context, index) => ProductReviewCardWidget(review: reviews[index]),
            ),
          ),
        ],
      ),
    );
  }

  void _openReviewsPage(ProductDetail product) {
    rightToPage(
      const ProductInfoScreen(),
      arguments: <String, dynamic>{'content': 3, 'description': product.description, 'attributes': product.attributes, 'reviews': product.reviews},
    );
  }

  Widget _reviewForm(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return Container(
      padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(10), r.pageHorizontalPadding, r.space(14)),
      margin: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
      decoration: BoxDecoration(
        color: colors.surface,
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
          SizedBox(height: r.space(14)),
          const TextBodyMediumView('لطفا به محصول امتیاز دهید:'),
          SizedBox(height: r.space(6)),
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
          SizedBox(height: r.space(14)),
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
        RelatedProductCard(
          list: viewModel.product!.relatedProducts,
          onProductTap: (productId) {
            viewModel.openRelatedProduct(productId);
          },
        ),
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
                              child: const AppText.labelLarge('افزودن به سبد خرید', color: AppColors.onBrand),
                            )
                          : ElevatedButton(
                              onPressed: () {},
                              child: const AppText.labelLarge('استعلام قیمت و موجودی', color: AppColors.onBrand),
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

  List<ProductAttribute> _visibleAttributes(ProductDetail product) {
    return product.attributes.where((item) => item.visible).toList(growable: false);
  }

  List<ReviewCardModel> _reviewItems(ProductDetail product) {
    return product.reviews.expand((group) => group.data).toList(growable: false);
  }

  String _plainText(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }
}
