import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:yad_sys/models/category/category_detail_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/screens/search/search_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/view_models/categories/category_view_model.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/home/home_brand_section.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/net_image.dart';
import 'package:yad_sys/widgets/sections/category_section.dart';
import 'package:yad_sys/widgets/sections/products_section.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key, required this.viewModel});

  final CategoryViewModel viewModel;

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late final ScrollController _scrollController;
  late int _lastCategoryId;
  bool _descriptionExpanded = false;

  CategoryViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _lastCategoryId = viewModel.currentCategoryId;
    viewModel.addListener(_handleViewModelChange);
  }

  @override
  void didUpdateWidget(covariant CategoryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.removeListener(_handleViewModelChange);
      widget.viewModel.addListener(_handleViewModelChange);
      _lastCategoryId = widget.viewModel.currentCategoryId;
    }
  }

  void _handleViewModelChange() {
    final newId = viewModel.currentCategoryId;
    if (newId == _lastCategoryId) return;

    _lastCategoryId = newId;
    _descriptionExpanded = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  @override
  void dispose() {
    viewModel.removeListener(_handleViewModelChange);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(backgroundColor: context.appColors.background, body: body(context)),
    );
  }

  Future<void> _back(BuildContext context) async {
    final shouldPop = await viewModel.handleBack();
    if (shouldPop && context.mounted) Get.back();
  }

  void _toggleDescription() => setState(() => _descriptionExpanded = !_descriptionExpanded);

  Widget body(BuildContext context) {
    final category = viewModel.category;
    final colors = context.appColors;
    final r = context.responsive;

    if (viewModel.isLoading && category == null) {
      return CustomScrollView(
        slivers: [
          appBar(context),
          const SliverFillRemaining(hasScrollBody: false, child: Loading()),
        ],
      );
    }

    if (viewModel.errorMessage.isNotEmpty || category == null) {
      return CustomScrollView(
        slivers: [
          appBar(context),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.all(r.pageHorizontalPadding * 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_outlined, color: colors.textMuted, size: r.icon(72, min: 56, max: 82)),
                  SizedBox(height: r.space(18)),
                  AppText.bodyMedium(
                    viewModel.errorMessage.isEmpty ? 'اطلاعات دسته‌بندی در دسترس نیست.' : viewModel.errorMessage,
                    textAlign: TextAlign.center,
                    height: 1.8,
                    color: colors.textSecondary,
                  ),
                  SizedBox(height: r.space(18)),
                  SizedBox(
                    width: r.percentWidth(0.46, min: 150, max: 220),
                    child: AppButton(label: 'تلاش دوباره', icon: Icons.refresh, onPressed: () => viewModel.load(forceRefresh: true)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final childrenSection = children(category);
    final productSections = _products(category);
    final brandSections = _brands(category);

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final hasDescription = category.description.isNotEmpty;
            final collapseDistance = r.space(110, min: 90, max: 150);
            double scrollOffset = 0;
            double availableScroll = collapseDistance;

            if (_scrollController.hasClients) {
              scrollOffset = _scrollController.offset.clamp(0.0, double.infinity).toDouble();
              final maxScrollExtent = _scrollController.position.maxScrollExtent;
              if (maxScrollExtent.isFinite && maxScrollExtent > 0) {
                availableScroll = math.min(collapseDistance, maxScrollExtent);
              }
            }

            final rawCollapse = (scrollOffset / math.max(1.0, availableScroll)).clamp(0.0, 1.0).toDouble();
            final scrollCollapse = Curves.easeOutCubic.transform(rawCollapse);

            return CustomScrollView(
              key: PageStorageKey<int>(viewModel.currentCategoryId),
              controller: _scrollController,
              slivers: [
                appBar(context),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: Header(category: category, collapse: scrollCollapse, colors: colors, r: r),
                ),
                if (hasDescription) SliverToBoxAdapter(child: description(context, category)),
                if (childrenSection != null) ...[
                  SliverToBoxAdapter(child: SizedBox(height: r.sectionVerticalGap)),
                  SliverToBoxAdapter(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border.symmetric(horizontal: BorderSide(color: colors.divider)),
                      ),
                      child: CategorySection(section: childrenSection, onCategoryTap: viewModel.openChildCategory),
                    ),
                  ),
                ],
                for (final section in productSections) ...[
                  SliverToBoxAdapter(child: SizedBox(height: r.sectionVerticalGap)),
                  SliverToBoxAdapter(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border.symmetric(horizontal: BorderSide(color: colors.divider)),
                      ),
                      child: ProductsSection(section: section),
                    ),
                  ),
                ],
                for (final section in brandSections) ...[
                  SliverToBoxAdapter(child: SizedBox(height: r.sectionVerticalGap)),
                  SliverToBoxAdapter(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border.symmetric(horizontal: BorderSide(color: colors.divider)),
                      ),
                      child: HomeBrandSection(section: section),
                    ),
                  ),
                ],
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final requiredScrollExtent = constraints.viewportMainAxisExtent + collapseDistance;
                    final missingExtent = math.max(0.0, requiredScrollExtent - constraints.precedingScrollExtent);
                    final tailHeight = math.max(r.space(24), missingExtent);

                    return SliverToBoxAdapter(child: SizedBox(height: tailHeight));
                  },
                ),
              ],
            );
          },
        ),
        if (viewModel.isLoading) Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: r.space(2, min: 2, max: 3))),
      ],
    );
  }

  SliverAppBar appBar(BuildContext context) {
    final colors = context.appColors;

    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: colors.surface,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: colors.textSecondary),
      leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => _back(context)),
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
    );
  }

  Widget description(BuildContext context, CategoryDetailData category) {
    final colors = context.appColors;
    final r = context.responsive;
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final plainDescription = AppFunction.htmlToText(category.description);

    return Container(
      width: double.infinity,
      color: colors.surface,
      padding: EdgeInsetsDirectional.all(r.space(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: r.space(5),
        children: [
          AppText.titleMedium('معرفی دسته‌بندی', fontWeight: FontWeight.w800, color: colors.textPrimary),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            reverseDuration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _descriptionExpanded
                ? HtmlWidget(
                    category.description,
                    textStyle: baseStyle.copyWith(color: colors.textPrimary, height: 1.9, fontSize: r.font((baseStyle.fontSize ?? 14) + 0.5)),
                  )
                : AppText.bodyMedium(plainDescription, color: colors.textSecondary, maxLines: 3, overflow: TextOverflow.ellipsis, height: 1.75),
          ),
          Center(
            child: Material(
              color: colors.surface,
              child: InkWell(
                onTap: _toggleDescription,
                borderRadius: BorderRadius.circular(r.radius(24)),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: r.space(5),
                    children: [
                      AppText.bodySmall(_descriptionExpanded ? 'کمتر' : 'بیشتر', color: colors.textSecondary, fontWeight: FontWeight.w700),
                      AnimatedRotation(
                        turns: _descriptionExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOutCubic,
                        child: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary, size: r.icon(20, min: 18, max: 24)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SectionModel? children(CategoryDetailData category) {
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

  List<SectionModel> _products(CategoryDetailData category) {
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

  List<SectionModel> _brands(CategoryDetailData category) {
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

class Header extends SliverPersistentHeaderDelegate {
  Header({required this.category, required this.collapse, required this.colors, required this.r});

  final CategoryDetailData category;
  final double collapse;
  final AppThemeColors colors;
  final AppDimension r;

  double get _compactExtent => r.space(60, min: 60, max: r.isTablet ? 104 : 90);

  double get _topImageSize => r.percentWidth(0.31, min: 112, max: r.isTablet ? 190 : 150);

  double get _topExtent => _topImageSize + r.space(65, min: 68, max: r.isTablet ? 104 : 90);

  double get _currentExtent => _lerp(_topExtent, _compactExtent, collapse).clamp(_compactExtent, double.infinity).toDouble();

  @override
  double get minExtent => _currentExtent;

  @override
  double get maxExtent => _currentExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final image = category.image;

    return Material(
      color: colors.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final horizontalPadding = r.pageHorizontalPadding;
          final gap = r.space(10);
          final topImageSize = _topImageSize;
          final topImageLeft = (width - topImageSize) / 2;
          final topImageTop = r.space(8);
          final compactImageSize = r.space(48, min: 44, max: r.isTablet ? 66 : 54);
          final compactImageLeft = width - horizontalPadding - compactImageSize;
          final compactImageTop = math.max(r.space(6), (height - compactImageSize) / 2);
          final imageSize = _lerp(topImageSize, compactImageSize, collapse);
          final imageLeft = _lerp(topImageLeft, compactImageLeft, collapse);
          final imageTop = _lerp(topImageTop, compactImageTop, collapse);
          final topTitleLeft = horizontalPadding;
          final topTitleWidth = width - (horizontalPadding * 2);
          final topTitleTop = topImageTop + topImageSize + r.space(6);
          final compactTitleLeft = horizontalPadding;
          final compactTitleWidth = math.max(r.space(80), compactImageLeft - gap - horizontalPadding);
          final compactTitleTop = math.max(r.space(8), (height - r.space(42, min: 36, max: 48)) / 2);
          final titleLeft = _lerp(topTitleLeft, compactTitleLeft, collapse);
          final titleWidth = _lerp(topTitleWidth, compactTitleWidth, collapse);
          final titleTop = _lerp(topTitleTop, compactTitleTop, collapse);
          final titleScale = _lerp(1.0, 0.90, collapse);
          final titleAlignment = Alignment.lerp(Alignment.center, Alignment.centerRight, collapse)!;

          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: imageLeft,
                top: imageTop,
                child: NetImage(imageUrl: image, width: imageSize, height: imageSize),
              ),
              Positioned(
                left: titleLeft,
                top: titleTop,
                width: titleWidth,
                height: r.space(46, min: 40, max: 56),
                child: Align(
                  alignment: titleAlignment,
                  child: Transform.scale(
                    scale: titleScale,
                    alignment: titleAlignment,
                    child: AppText.titleMedium(
                      category.name,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                      textAlign: collapse < 0.5 ? TextAlign.center : TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(covariant Header oldDelegate) {
    return oldDelegate.category.id != category.id ||
        oldDelegate.category.name != category.name ||
        oldDelegate.category.image != category.image ||
        oldDelegate.collapse != collapse ||
        oldDelegate.colors != colors ||
        oldDelegate.r.width != r.width ||
        oldDelegate.r.height != r.height;
  }
}

double _lerp(double a, double b, double t) => a + ((b - a) * t);
