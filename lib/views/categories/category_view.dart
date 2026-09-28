import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/models/category/category_detail_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/screens/search/search_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/view_models/categories/category_view_model.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/home/home_brand_section.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/sections/category_section.dart';
import 'package:yad_sys/widgets/sections/products_section.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key, required this.viewModel});

  final CategoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surface,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: colors.textSecondary),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.search, color: colors.textPrimary),
                  onPressed: () => Get.to(const SearchScreen(), transition: Transition.upToDown, duration: const Duration(milliseconds: 500)),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: colors.textPrimary),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => _back(context)),
        ),
        body: _body(context),
      ),
    );
  }

  Future<void> _back(BuildContext context) async {
    final shouldPop = await viewModel.handleBack();
    if (shouldPop && context.mounted) Get.back();
  }

  Widget _body(BuildContext context) {
    final category = viewModel.category;
    final colors = context.appColors;
    final r = context.responsive;

    if (viewModel.isLoading && category == null) const Loading();

    if (viewModel.errorMessage.isNotEmpty && category == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(r.pageHorizontalPadding * 1.5),
        children: [
          SizedBox(height: r.percentHeight(0.16, min: 80, max: 160)),
          Icon(Icons.cloud_off_outlined, color: colors.textMuted, size: r.icon(72, min: 56, max: 82)),
          SizedBox(height: r.space(18)),
          AppText.bodyMedium(viewModel.errorMessage, textAlign: TextAlign.center, height: 1.8, color: colors.textSecondary),
          SizedBox(height: r.space(18)),
          Center(
            child: SizedBox(
              width: r.percentWidth(0.46, min: 150, max: 220),
              child: AppButton(label: 'تلاش دوباره', icon: Icons.refresh, onPressed: () => viewModel.loadCategory(forceRefresh: true)),
            ),
          ),
        ],
      );
    }

    if (category == null) return const SizedBox.shrink();

    final childrenSection = _childrenSection(category);
    final productSections = _productSections(category);
    final brandSections = _brandSections(category);

    return Stack(
      children: [
        ListView(
          key: PageStorageKey<int>(viewModel.currentCategoryId),
          padding: EdgeInsets.only(bottom: r.space(24)),
          children: [
            header(context),
            if (childrenSection != null) ...[
              SizedBox(height: r.sectionVerticalGap),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.symmetric(horizontal: BorderSide(color: colors.divider)),
                ),
                child: CategorySection(section: childrenSection, onCategoryTap: viewModel.openChildCategory),
              ),
            ],
            for (final section in productSections) ...[
              SizedBox(height: r.sectionVerticalGap),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.symmetric(horizontal: BorderSide(color: colors.divider)),
                ),
                child: ProductsSection(section: section),
              ),
            ],
            for (final section in brandSections) ...[
              SizedBox(height: r.sectionVerticalGap),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.symmetric(horizontal: BorderSide(color: colors.divider)),
                ),
                child: HomeBrandSection(section: section),
              ),
            ],
          ],
        ),
        if (viewModel.isLoading && category != null)
          Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: r.space(2, min: 2, max: 3))),
      ],
    );
  }

  Widget header(BuildContext context) {
    final category = viewModel.category;
    final colors = context.appColors;
    final r = context.responsive;
    final image = category!.image.trim();
    final description = category.description.trim();

    if (image.isEmpty && description.isEmpty) const SizedBox.shrink();

    return Container(
      color: colors.surface,
      padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding, vertical: r.space(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: r.space(10),
        children: [
          SizedBox(
            width: r.percentWidth(0.24, min: 82, max: 132),
            height: r.percentWidth(0.24, min: 82, max: 132),
            child: CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              errorWidget: (context, url, error) => Icon(Icons.category_outlined, color: colors.textMuted, size: r.icon(42)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: r.space(10),
              children: [
                AppText.titleMedium(category.name, fontWeight: FontWeight.w800, color: colors.textPrimary, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (description.isNotEmpty)
                  AppText.bodySmall(description, color: colors.textSecondary, maxLines: 3, overflow: TextOverflow.ellipsis, height: 1.7),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SectionModel? _childrenSection(CategoryDetailData category) {
    if (category.children.isEmpty) return null;

    return SectionModel(
      id: 'category_detail_children_${category.id}',
      type: 'category',
      position: 0,
      title: 'دسته‌بندی‌های ${category.name}',
      subtitle: '',
      layout: const SectionLayout(direction: 'horizontal', rows: 1, columns: 3),
      data: category.children,
    );
  }

  List<SectionModel> _productSections(CategoryDetailData category) {
    final result = <SectionModel>[];

    for (var index = 0; index < category.products.length; index++) {
      final group = category.products[index];
      if (group.data.isEmpty) continue;

      result.add(
        SectionModel(
          id: 'category_detail_products_${category.id}_$index',
          type: 'products',
          position: index + 1,
          title: index == 0 ? 'محصولات ${category.name}' : 'محصولات',
          subtitle: '',
          layout: const SectionLayout(direction: 'horizontal', rows: 1, columns: 1),
          data: group.data,
          viewAll: group.viewAll,
        ),
      );
    }

    return result;
  }

  List<SectionModel> _brandSections(CategoryDetailData category) {
    final result = <SectionModel>[];

    for (var index = 0; index < category.brands.length; index++) {
      final group = category.brands[index];
      if (group.data.isEmpty) continue;

      result.add(
        SectionModel(
          id: 'category_detail_brands_${category.id}_$index',
          type: 'brand',
          position: category.products.length + index + 1,
          title: index == 0 ? 'برندهای ${category.name}' : 'برندها',
          subtitle: '',
          layout: const SectionLayout(direction: 'horizontal', rows: 1, columns: 4),
          data: group.data,
          viewAll: group.viewAll,
        ),
      );
    }

    return result;
  }
}
