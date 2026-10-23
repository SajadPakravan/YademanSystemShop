import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_input_formatter.dart';
import 'package:yad_sys/widgets/forms/app_text_field.dart';

class LocationCombo<T> extends StatefulWidget {
  const LocationCombo({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.options,
    required this.labelOf,
    required this.onSelected,
    required this.onChanged,
    required this.title,
    required this.hint,
    required this.icon,
    this.emptyMessage = 'موردی پیدا نشد',
    this.errorText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;
  final ValueChanged<String>? onChanged;
  final String title;
  final String hint;
  final IconData icon;
  final String emptyMessage;
  final String? errorText;

  @override
  State<LocationCombo<T>> createState() => _LocationComboState<T>();
}

class _LocationComboState<T> extends State<LocationCombo<T>> {
  final LayerLink _anchor = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  OverlayEntry? _overlay;
  bool _openingScheduled = false;

  /// افزودن Listener فقط یک بار در طول عمر ویجت.
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onMainFocusChanged);
    _searchCtrl.addListener(_refreshOverlay);
  }

  /// هماهنگ‌سازی پنل باز در صورت عوض‌شدن فهرست شهرها یا FocusNode.
  @override
  void didUpdateWidget(covariant LocationCombo<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onMainFocusChanged);
      widget.focusNode.addListener(_onMainFocusChanged);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!identical(oldWidget.options, widget.options)) _searchCtrl.clear();
      _refreshOverlay();
    });
  }

  /// فوکوس گرفتن فیلد اصلی، پنل را باز می‌کند؛ خروج فوکوس هنگام ورود به جستجو، آن را نمی‌بندد.
  void _onMainFocusChanged() {
    if (widget.focusNode.hasFocus) _scheduleOpen();
  }

  /// قرار دادن فیلد در محدوده دید پیش از بازشدن پنل زیر آن.
  void _scheduleOpen() {
    if (_overlay != null || _openingScheduled) return;
    _openingScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _openingScheduled = false;
        return;
      }

      await Scrollable.ensureVisible(context, alignment: 0.08, duration: Duration.zero);
      if (!mounted) return;

      _openingScheduled = false;
      _open();
    });
  }

  /// یکسان‌سازی حروف فارسی و عربی برای جستجوی دقیق‌تر.
  String _normalize(String text) => text.trim().toLowerCase().replaceAll('ي', 'ی').replaceAll('ك', 'ک');

  /// استخراج گزینه‌ها فقط با متن جستجوی داخل پنل، نه متن فیلد اصلی.
  List<T> _filteredOptions() {
    final query = _normalize(_searchCtrl.text);
    if (query.isEmpty) return widget.options;

    return widget.options.where((item) => _normalize(widget.labelOf(item)).contains(query)).toList(growable: false);
  }

  /// بازسازی پنل با تغییر متن جستجو یا فهرست گزینه‌ها.
  void _refreshOverlay() {
    if (_overlay?.mounted ?? false) _overlay?.markNeedsBuild();
  }

  /// نمایش پنل جستجو و گزینه‌ها در لایه‌ای شناور زیر فیلد اصلی.
  void _open() {
    if (!mounted || _overlay != null) return;
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    // هر بار بازشدن، تمام گزینه‌های استان/شهر را نشان می‌دهیم.
    _searchCtrl.clear();

    _overlay = OverlayEntry(
      builder: (overlayContext) {
        final box = _fieldKey.currentContext?.findRenderObject();
        if (box is! RenderBox || !box.attached || !box.hasSize) {
          return const SizedBox.shrink();
        }

        // محاسبه فضای آزاد زیر فیلد با درنظرگرفتن صفحه‌کلید.
        final media = MediaQuery.of(overlayContext);
        final fieldTop = box.localToGlobal(Offset.zero).dy;
        final availableBelow = math.max(0.0, media.size.height - media.viewInsets.bottom - fieldTop - box.size.height - 8.0);

        if (availableBelow < 96.0) return const SizedBox.shrink();

        final options = _filteredOptions();
        final desiredHeight = 68.0 + math.max(1, options.length) * 48.0;
        final panelHeight = math.min(math.min(400.0, availableBelow), desiredHeight);

        return Stack(
          children: [
            // لمس بیرون از پنل، آن را بدون تغییر مقدار انتخاب‌شده می‌بندد.
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _close, child: const SizedBox.expand()),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: CompositedTransformFollower(
                link: _anchor,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                showWhenUnlinked: false,
                offset: const Offset(0, 4),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SizedBox(
                    width: box.size.width,
                    height: panelHeight,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(overlayContext).colorScheme.surface,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              controller: _searchCtrl,
                              focusNode: _searchFocus,
                              autofocus: true,
                              inputFormatters: AppInputFormatter.formatters(AppInputType.sPersianLetters),
                              decoration: const InputDecoration(hintText: 'جستجو در فهرست...', prefixIcon: Icon(Icons.search), isDense: true),
                            ),
                          ),
                          Expanded(
                            child: options.isEmpty
                                ? Center(child: Text(widget.emptyMessage))
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemExtent: 48,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final item = options[index];
                                      return ListTile(dense: true, title: Text(widget.labelOf(item)), onTap: () => _choose(item));
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlayState.insert(_overlay!);
  }

  void _choose(T item) {
    _close();
    widget.onSelected(item);
  }

  /// حذف ایمن پنل و پایان فوکوس جستجوی موقت.
  void _close() {
    if (_searchFocus.hasFocus) _searchFocus.unfocus();
    final entry = _overlay;
    _overlay = null;
    entry?.remove();
    entry?.dispose();
  }

  /// آزادسازی منابع داخلی؛ کنترلر و FocusNode اصلی فقط در ViewModel آزاد می‌شوند.
  @override
  void dispose() {
    widget.focusNode.removeListener(_onMainFocusChanged);
    _searchCtrl.removeListener(_refreshOverlay);
    _close();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// فیلد اصلی فقط خواندنی است و با لمس آن فهرست باز می‌شود.
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      key: _fieldKey,
      link: _anchor,
      child: AppTextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        readOnly: true,
        title: widget.title,
        hint: widget.hint,
        icon: widget.icon,
        errorText: widget.errorText,
        onTap: _scheduleOpen,
        onChanged: widget.onChanged,
      ),
    );
  }
}
