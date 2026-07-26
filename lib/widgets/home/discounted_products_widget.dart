import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/cards/product_card_widget.dart';

class DiscountedProductsWidget extends StatefulWidget {
  const DiscountedProductsWidget({
    super.key,
    required this.section,
    required this.products,
  });

  final SectionModel section;
  final List<ProductCardModel> products;

  @override
  State<DiscountedProductsWidget> createState() => _DiscountedProductsWidgetState();
}

class _DiscountedProductsWidgetState extends State<DiscountedProductsWidget> {
  PageController? _pageController;
  ScrollPosition? _parentScrollPosition;
  Timer? _showHintsTimer;

  double _viewportFraction = 0.5;
  double _currentPage = 0;

  bool _isPointerDown = false;
  bool _isHorizontalScrolling = false;
  bool _isParentScrolling = false;
  bool _allowHints = true;

  bool get _hasViewAll => widget.section.viewAll != null;

  int get _itemCount => 1 + widget.products.length + (_hasViewAll ? 1 : 0);

  int get _lastPageIndex => _itemCount - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final nextViewportFraction = _calculateViewportFraction(screenWidth);

    if (_pageController == null ||
        (nextViewportFraction - _viewportFraction).abs() > 0.001) {
      final previousPage = _currentPage.round().clamp(0, _lastPageIndex).toInt();

      final oldController = _pageController;
      oldController?.removeListener(_handlePageOffset);

      _viewportFraction = nextViewportFraction;
      _pageController = PageController(
        initialPage: previousPage,
        viewportFraction: _viewportFraction,
      )..addListener(_handlePageOffset);

      _currentPage = previousPage.toDouble();

      if (oldController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          oldController.dispose();
        });
      }
    }

    _attachToParentScroll();
  }

  @override
  void didUpdateWidget(covariant DiscountedProductsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_currentPage > _lastPageIndex) {
      _currentPage = _lastPageIndex.toDouble();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !(_pageController?.hasClients ?? false)) return;
        _pageController!.jumpToPage(_lastPageIndex);
      });
    }
  }

  @override
  void dispose() {
    _showHintsTimer?.cancel();

    _parentScrollPosition?.isScrollingNotifier.removeListener(
      _handleParentScrollState,
    );

    _pageController?.removeListener(_handlePageOffset);
    _pageController?.dispose();

    super.dispose();
  }

  double _calculateViewportFraction(double screenWidth) {
    const horizontalPadding = 24.0;
    const pageSpacing = 12.0;

    final availableWidth = (screenWidth - horizontalPadding).clamp(1.0, double.infinity);
    final cardWidth = (screenWidth * 0.46).clamp(164.0, 220.0).toDouble();

    return ((cardWidth + pageSpacing) / availableWidth)
        .clamp(0.18, 0.72)
        .toDouble();
  }

  void _attachToParentScroll() {
    final nextPosition = Scrollable.maybeOf(context, axis: Axis.vertical)?.position;
    if (identical(nextPosition, _parentScrollPosition)) return;

    _parentScrollPosition?.isScrollingNotifier.removeListener(
      _handleParentScrollState,
    );

    _parentScrollPosition = nextPosition;
    _parentScrollPosition?.isScrollingNotifier.addListener(
      _handleParentScrollState,
    );
  }

  void _handleParentScrollState() {
    final isScrolling = _parentScrollPosition?.isScrollingNotifier.value ?? false;
    if (!mounted || isScrolling == _isParentScrolling) return;

    _showHintsTimer?.cancel();

    setState(() {
      _isParentScrolling = isScrolling;
      if (isScrolling) _allowHints = false;
    });

    if (!isScrolling) _scheduleShowHints();
  }

  void _handlePageOffset() {
    final controller = _pageController;
    if (controller == null || !controller.hasClients) return;

    final page = controller.page ?? controller.initialPage.toDouble();
    if ((page - _currentPage).abs() < 0.0001 || !mounted) return;

    setState(() => _currentPage = page);
  }

  bool _handleHorizontalScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _showHintsTimer?.cancel();
      if (!_isHorizontalScrolling || _allowHints) {
        setState(() {
          _isHorizontalScrolling = true;
          _allowHints = false;
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_isHorizontalScrolling) {
        setState(() => _isHorizontalScrolling = false);
      }
      _scheduleShowHints();
    }

    return false;
  }

  void _handlePointerDown(PointerDownEvent event) {
    _showHintsTimer?.cancel();

    setState(() {
      _isPointerDown = true;
      _allowHints = false;
    });
  }

  void _handlePointerUp(PointerUpEvent event) => _finishPointerInteraction();

  void _handlePointerCancel(PointerCancelEvent event) => _finishPointerInteraction();

  void _finishPointerInteraction() {
    if (!_isPointerDown) return;

    setState(() => _isPointerDown = false);
    _scheduleShowHints();
  }

  void _scheduleShowHints() {
    _showHintsTimer?.cancel();

    if (_isPointerDown || _isHorizontalScrolling || _isParentScrolling) return;

    _showHintsTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted || _isPointerDown || _isHorizontalScrolling || _isParentScrolling) {
        return;
      }

      setState(() => _allowHints = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _pageController;
    if (controller == null || widget.products.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = (screenWidth - 24).clamp(1.0, double.infinity);
    final pageExtent = availableWidth * _viewportFraction;
    final cardHeight = (screenWidth * 0.81).clamp(292.0, 320.0).toDouble();
    final sectionHeight = cardHeight + 36;

    final logoCoverProgress = _currentPage.clamp(0.0, 1.0).toDouble();
    final logoOpacity = lerpDouble(1.0, 0.30, logoCoverProgress)!;
    final logoScale = lerpDouble(1.0, 0.87, logoCoverProgress)!;

    final atStart = _currentPage <= 0.02;
    final atEnd = _currentPage >= _lastPageIndex - 0.02;
    final hintsMayBeShown =
        _allowHints && !_isPointerDown && !_isHorizontalScrolling && !_isParentScrolling;

    final showLeftHint = hintsMayBeShown && !atEnd;
    final showRightHint = hintsMayBeShown && !atStart;

    return Container(
      height: sectionHeight,
      margin: const EdgeInsets.only(top: 6, bottom: 18),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xff0868c7),
            Color(0xff034b91),
            Color(0xff022f5f),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _AmazingBackgroundDecoration(),
          PositionedDirectional(
            start: 12,
            top: 18,
            bottom: 18,
            width: (pageExtent - 12).clamp(145.0, 220.0).toDouble(),
            child: RepaintBoundary(
              child: Opacity(
                opacity: logoOpacity,
                child: Transform.scale(
                  scale: logoScale,
                  alignment: Alignment.center,
                  child: _AmazingLogo(
                    title: widget.section.title,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: _handlePointerDown,
              onPointerUp: _handlePointerUp,
              onPointerCancel: _handlePointerCancel,
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleHorizontalScrollNotification,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: PageView.builder(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    padEnds: false,
                    pageSnapping: true,
                    clipBehavior: Clip.hardEdge,
                    physics: const PageScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: _itemCount,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const SizedBox.expand();
                      }

                      final productIndex = index - 1;
                      if (productIndex < widget.products.length) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(end: 12),
                          child: SizedBox(
                            height: cardHeight,
                            child: ProductCardWidget(
                              product: widget.products[productIndex],
                            ),
                          ),
                        );
                      }

                      final viewAll = widget.section.viewAll!;
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12),
                        child: _ViewAllCard(
                          title: viewAll.title,
                          onTap: () => SectionActionHandler.handle(
                            context: context,
                            action: viewAll.action,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: (sectionHeight - 46) / 2,
            child: _GlassScrollHint(
              visible: showLeftHint,
              icon: Icons.arrow_back_ios_new_rounded,
            ),
          ),
          Positioned(
            right: 8,
            top: (sectionHeight - 46) / 2,
            child: _GlassScrollHint(
              visible: showRightHint,
              icon: Icons.arrow_forward_ios_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmazingLogo extends StatelessWidget {
  const _AmazingLogo({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: CachedNetworkImage(
        imageUrl: _DiscountedLogoUrl.value,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 54,
            ),
            const SizedBox(height: 10),
            Text(
              title.isEmpty ? 'پیشنهاد شگفت‌انگیز' : title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountedLogoUrl {
  const _DiscountedLogoUrl._();

  static const String value =
      'https://yademansystem.ir/wp-content/uploads/2023/02/amazings.png';
}

class _AmazingBackgroundDecoration extends StatelessWidget {
  const _AmazingBackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -54,
            left: -42,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.055),
              ),
            ),
          ),
          Positioned(
            bottom: -74,
            right: 42,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightBlueAccent.withOpacity(0.07),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassScrollHint extends StatelessWidget {
  const _GlassScrollHint({required this.visible, required this.icon});

  final bool visible;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: visible ? 1 : 0.86,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.42),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(
                    icon,
                    size: 21,
                    color: Colors.white.withOpacity(0.94),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewAllCard extends StatelessWidget {
  const _ViewAllCard({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.96),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xff0b74d5), Color(0xff034b91)],
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title.isEmpty ? 'مشاهده همه' : title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff034b91),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'همه پیشنهادها',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
