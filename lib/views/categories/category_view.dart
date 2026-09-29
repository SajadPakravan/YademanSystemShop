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

class _CategoryViewState extends State<CategoryView> with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _headerExpandController;
  late int _lastCategoryId;

  CategoryViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _headerExpandController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500), reverseDuration: const Duration(milliseconds: 500));
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
    _headerExpandController.value = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  @override
  void dispose() {
    viewModel.removeListener(_handleViewModelChange);
    _headerExpandController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(backgroundColor: context.appColors.background, body: _body(context)),
    );
  }

  Future<void> _back(BuildContext context) async {
    final shouldPop = await viewModel.handleBack();
    if (shouldPop && context.mounted) Get.back();
  }

  Future<void> _toggleHeader() async {
    final opening = _headerExpandController.value < 0.5;

    if (opening && _scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
    }

    if (opening) {
      await _headerExpandController.forward();
    } else {
      await _headerExpandController.reverse();
    }
  }

  Widget _body(BuildContext context) {
    final category = viewModel.category;
    final colors = context.appColors;
    final r = context.responsive;

    if (viewModel.isLoading && category == null) {
      return CustomScrollView(
        slivers: [
          _appBar(context),
          const SliverFillRemaining(hasScrollBody: false, child: Loading()),
        ],
      );
    }

    if (viewModel.errorMessage.isNotEmpty || category == null) {
      return CustomScrollView(
        slivers: [
          _appBar(context),
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

    final childrenSection = _childrenSection(category);
    final productSections = _productSections(category);
    final brandSections = _brandSections(category);

    return Stack(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_headerExpandController, _scrollController]),
          builder: (context, child) {
            final expandProgress = Curves.easeInOutCubic.transform(_headerExpandController.value);
            final hasDescription = category.description.trim().isNotEmpty;
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
                _appBar(context),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CategoryHeaderDelegate(
                    category: category,
                    expansion: hasDescription ? expandProgress : 0,
                    collapse: scrollCollapse,
                    colors: colors,
                    r: r,
                  ),
                ),
                if (hasDescription) ...[
                  SliverToBoxAdapter(child: _expandedDescription(context, expandProgress)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _HeaderToggle(progress: expandProgress, onTap: _toggleHeader, height: r.space(25, min: 20, max: 30)),
                  ),
                ],
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

  SliverAppBar _appBar(BuildContext context) {
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

  Widget _expandedDescription(BuildContext context, double progress) {
    final category = viewModel.category;
    final colors = context.appColors;
    final r = context.responsive;
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: progress,
        child: Container(
          color: colors.surface,
          padding: EdgeInsetsDirectional.fromSTEB(r.pageHorizontalPadding, r.space(6), r.pageHorizontalPadding, r.space(18)),
          child: HtmlWidget(
            category!.description,
            textStyle: baseStyle.copyWith(color: colors.textPrimary, height: 1.9, fontSize: r.font((baseStyle.fontSize ?? 14) + 0.5)),
          ),
        ),
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

class _HeaderToggle extends SliverPersistentHeaderDelegate {
  _HeaderToggle({required this.progress, required this.onTap, required this.height});

  final double progress;
  final VoidCallback onTap;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colors = context.appColors;
    final r = context.responsive;

    return Material(
      color: colors.chipBackground,
      borderRadius: BorderRadius.only(bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30)),
      child: InkWell(
        onTap: onTap,
        child: SizedBox.expand(
          child: Transform.rotate(
            angle: 3.141592653589793 * progress,
            child: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary, size: r.icon(25, min: 20, max: 28)),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HeaderToggle oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.height != height;
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  _CategoryHeaderDelegate({required this.category, required this.expansion, required this.collapse, required this.colors, required this.r});

  final CategoryDetailData category;
  final double expansion;
  final double collapse;
  final AppThemeColors colors;
  final AppDimension r;

  double get _compactExtent => r.space(65, min: 60, max: r.isTablet ? 104 : 90);

  double get _closedExtent {
    final hasDescription = category.description.trim().isNotEmpty;
    return r.space(hasDescription ? 130 : 112, min: hasDescription ? 135 : 104, max: r.isTablet ? 220 : 190);
  }

  double get _openedExtent => r.percentHeight(0.15, min: 220, max: r.isTablet ? 430 : 330);

  double get _currentExtent {
    final topExtent = _lerp(_closedExtent, _openedExtent, expansion);
    return _lerp(topExtent, _compactExtent, collapse).clamp(_compactExtent, double.infinity).toDouble();
  }

  @override
  double get minExtent => _currentExtent;

  @override
  double get maxExtent => _currentExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final image = category.image.trim();
    final plainDescription = AppFunction.faDigit(AppFunction.htmlToText(category.description));

    return Material(
      color: colors.surface,
      elevation: overlapsContent || collapse > 0.02 ? 1.5 : 0,
      shadowColor: AppColors.shadow.withValues(alpha: 0.12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final horizontalPadding = r.pageHorizontalPadding;
          final gap = r.space(10);
          final closedImageSize = r.percentWidth(0.24, min: 82, max: r.isTablet ? 150 : 122);
          final openedImageSize = r.percentWidth(0.30, min: 105, max: r.isTablet ? 180 : 145);
          final compactImageSize = r.space(48, min: 44, max: r.isTablet ? 66 : 54);
          final baseImageSize = _lerp(closedImageSize, openedImageSize, expansion);
          final imageSize = _lerp(baseImageSize, compactImageSize, collapse);
          final closedImageLeft = width - horizontalPadding - closedImageSize;
          final openedImageLeft = (width - openedImageSize) / 2;
          final compactImageLeft = width - horizontalPadding - compactImageSize;
          final baseImageLeft = _lerp(closedImageLeft, openedImageLeft, expansion);
          final imageLeft = _lerp(baseImageLeft, compactImageLeft, collapse);
          final closedImageTop = r.space(12);
          final openedImageTop = r.space(10);
          final compactImageTop = math.max(r.space(6), (height - compactImageSize) / 2);
          final baseImageTop = _lerp(closedImageTop, openedImageTop, expansion);
          final imageTop = _lerp(baseImageTop, compactImageTop, collapse);
          final closedTitleLeft = horizontalPadding;
          final closedTitleWidth = math.max(r.space(80), closedImageLeft - gap - horizontalPadding);
          final closedTitleTop = r.space(18);
          final openedTitleLeft = horizontalPadding;
          final openedTitleWidth = width - (horizontalPadding * 2);
          final openedTitleTop = openedImageTop + openedImageSize + r.space(8);
          final compactTitleLeft = horizontalPadding;
          final compactTitleWidth = math.max(r.space(80), compactImageLeft - gap - horizontalPadding);
          final compactTitleTop = math.max(r.space(8), (height - r.space(42, min: 36, max: 48)) / 2);
          final baseTitleLeft = _lerp(closedTitleLeft, openedTitleLeft, expansion);
          final baseTitleWidth = _lerp(closedTitleWidth, openedTitleWidth, expansion);
          final baseTitleTop = _lerp(closedTitleTop, openedTitleTop, expansion);
          final titleLeft = _lerp(baseTitleLeft, compactTitleLeft, collapse);
          final titleWidth = _lerp(baseTitleWidth, compactTitleWidth, collapse);
          final titleTop = _lerp(baseTitleTop, compactTitleTop, collapse);
          final titleScale = _lerp(1.0, 0.90, collapse);
          final summaryFactor = ((1 - expansion) * (1 - collapse)).clamp(0.0, 1.0).toDouble();
          final summaryTop = r.space(56);
          final summaryMaxHeight = math.max(0.0, _closedExtent - summaryTop - r.space(10));
          final summaryHeight = summaryMaxHeight * summaryFactor;

          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: imageLeft,
                top: imageTop,
                width: imageSize,
                height: imageSize,
                child: _CategoryHeaderImage(imageUrl: image),
              ),
              Positioned(
                left: titleLeft,
                top: titleTop,
                width: titleWidth,
                height: r.space(46, min: 40, max: 56),
                child: Align(
                  alignment: Alignment(_lerp(1.0, 0.0, expansion * (1 - collapse)), 0),
                  child: Transform.scale(
                    scale: titleScale,
                    alignment: Alignment.centerRight,
                    child: AppText.titleMedium(
                      category.name,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              if (plainDescription.isNotEmpty && summaryHeight > 0)
                Positioned(
                  left: horizontalPadding,
                  top: summaryTop,
                  width: closedTitleWidth,
                  height: summaryHeight,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: AppText.bodySmall(plainDescription, color: colors.textSecondary, maxLines: 3, overflow: TextOverflow.ellipsis, height: 1.65),
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
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return oldDelegate.category.id != category.id ||
        oldDelegate.category.name != category.name ||
        oldDelegate.category.description != category.description ||
        oldDelegate.category.image != category.image ||
        oldDelegate.expansion != expansion ||
        oldDelegate.collapse != collapse ||
        oldDelegate.colors != colors ||
        oldDelegate.r.width != r.width ||
        oldDelegate.r.height != r.height;
  }
}

class _CategoryHeaderImage extends StatelessWidget {
  const _CategoryHeaderImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final url = imageUrl.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(r.radius(16)),
      child: NetImage(imageUrl: url),
    );
  }
}

double _lerp(double a, double b, double t) => a + ((b - a) * t);
