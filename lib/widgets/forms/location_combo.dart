import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/widgets/forms/app_text_field.dart';

class LocationCombo extends StatefulWidget {
  const LocationCombo({
    super.key,
    required this.code,
    required this.list,
    required this.onChanged,
    required this.title,
    required this.hint,
    required this.icon,
    this.emptyMessage = 'موردی پیدا نشد.',
    this.errorText,
  });

  final String code;
  final List<LocationOptions> list;
  final ValueChanged<String> onChanged;

  final String title;
  final String hint;
  final IconData icon;
  final String emptyMessage;
  final String? errorText;

  @override
  State<LocationCombo> createState() =>
      _LocationComboState();
}

class _LocationComboState extends State<LocationCombo> {
  final LayerLink _anchor = LayerLink();
  final GlobalKey _targetKey = GlobalKey();
  final FocusNode _focus = FocusNode();

  late final TextEditingController _search;

  OverlayEntry? _overlay;

  String _selectedCode = '';
  String? _pendingCodeEcho;

  bool _isEditing = false;
  bool _overlayRefreshScheduled = false;

  int _syncVersion = 0;

  // تبدیل کد گزینه به نام قابل نمایش.
  String _labelFor(String code) {
    for (final item in widget.list) {
      if (item.code == code) {
        return item.name;
      }
    }

    return code;
  }

  @override
  void initState() {
    super.initState();

    _selectedCode = widget.code;

    _search = TextEditingController(
      text: _labelFor(widget.code),
    );

    _focus.addListener(_onFocusChanged);
  }

  // دریافت تغییرات واقعی مدل از ویجت والد.
  @override
  void didUpdateWidget(
      covariant LocationCombo oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    final codeChanged = oldWidget.code != widget.code;
    final listChanged = !identical(
      oldWidget.list,
      widget.list,
    );

    if (!codeChanged && !listChanged) return;

    if (codeChanged) {
      // اگر تغییر، پاسخ والد به انتخاب یا پاک‌سازی
      // خود همین کامبوباکس باشد، متن تایپ‌شده
      // را دوباره بازنویسی نمی‌کنیم.
      final isEcho = _pendingCodeEcho != null &&
          widget.code == _pendingCodeEcho;

      _pendingCodeEcho = null;

      if (!isEcho) {
        _selectedCode = widget.code;
        _isEditing = false;
        _scheduleSearchSync();
      }
    } else if (listChanged && !_isEditing) {
      // اگر لیست گزینه‌ها تغییر کرده باشد،
      // نام نمایشی کد موجود دوباره محاسبه می‌شود.
      _scheduleSearchSync();
    }

    _refreshOverlayAfterFrame();
  }

  // هماهنگ‌سازی متن پس از پایان Build.
  void _scheduleSearchSync() {
    final version = ++_syncVersion;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          version != _syncVersion ||
          _isEditing) {
        return;
      }

      final label = _labelFor(widget.code);

      if (_search.text != label) {
        _search.value = TextEditingValue(
          text: label,
          selection: TextSelection.collapsed(
            offset: label.length,
          ),
        );
      }
    });
  }

  // بازسازی امن Overlay بعد از پایان فریم.
  void _refreshOverlayAfterFrame() {
    if (_overlayRefreshScheduled) return;

    _overlayRefreshScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayRefreshScheduled = false;

      if (!mounted) return;

      final entry = _overlay;

      if (entry == null || !entry.mounted) {
        return;
      }

      entry.markNeedsBuild();
    });
  }

  // یکسان‌سازی حروف عربی و فارسی برای جستجو.
  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ي', 'ی')
        .replaceAll('ك', 'ک');
  }

  // استخراج گزینه‌های مطابق متن جستجو.
  List<LocationOptions> _filteredOptions(
      String text,
      ) {
    final query = _normalize(text);

    return widget.list.where((item) {
      return _normalize(item.name).contains(query) ||
          _normalize(item.code).contains(query);
    }).toList(growable: false);
  }

  // مدیریت فوکوس فیلد.
  void _onFocusChanged() {
    if (_focus.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focus.hasFocus) {
          _open();
        }
      });
    } else {
      _close();
      // Incomplete search text is not a selected API code.
      if (_selectedCode.isEmpty && _search.text.isNotEmpty) {
        _search.clear();
        _isEditing = false;
      }
    }
  }

  // تغییر متن جستجو توسط کاربر.
  void _onTyped(String value) {
    _syncVersion++;
    _isEditing = true;

    // متن جستجو هرگز به‌عنوان کد ارسال نمی‌شود.
    // اگر قبلاً گزینه‌ای انتخاب شده بود، آن انتخاب
    // با تایپ جدید نامعتبر می‌شود.
    if (_selectedCode.isNotEmpty) {
      _selectedCode = '';
      _pendingCodeEcho = '';

      widget.onChanged('');
    }

    _open();

    // نیازی به markNeedsBuild مستقیم نیست.
    // ValueListenableBuilder تغییرات _search
    // را دریافت کرده و لیست را به‌روز می‌کند.
  }

  // انتخاب یک گزینه معتبر از لیست.
  void _choose(LocationOptions item) {
    _syncVersion++;
    _isEditing = false;
    _selectedCode = item.code;

    // ابتدا لیست را می‌بندیم.
    _close();
    _focus.unfocus();

    // نمایش نام انتخاب‌شده در فیلد.
    _search.value = TextEditingValue(
      text: item.name,
      selection: TextSelection.collapsed(
        offset: item.name.length,
      ),
    );

    // ارسال فقط کد انتخاب‌شده به والد.
    _pendingCodeEcho = item.code;
    widget.onChanged(item.code);
  }

  // ایجاد Overlay زیر فیلد.
  void _open() {
    if (_overlay != null || !mounted) return;

    final overlayState = Overlay.maybeOf(context);

    if (overlayState == null) return;

    final entry = OverlayEntry(
      builder: (overlayContext) {
        if (!mounted) {
          return const SizedBox.shrink();
        }

        // تغییر متن کنترلر، فقط بخش لیست را
        // بازسازی می‌کند؛ نه کل فرم را.
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: _search,
          builder: (context, searchValue, child) {
            final target =
            _targetKey.currentContext?.findRenderObject();

            if (target is! RenderBox ||
                !target.attached ||
                !target.hasSize) {
              return const SizedBox.shrink();
            }

            final width = target.size.width;
            final fieldHeight = target.size.height;

            final origin = target.localToGlobal(
              Offset.zero,
            );

            final screenHeight =
                MediaQuery.sizeOf(overlayContext).height;

            final keyboardHeight =
                MediaQuery.viewInsetsOf(overlayContext)
                    .bottom;

            // Use the side with room: the city field is often near the
            // keyboard, so a below-only dropdown can become inaccessible.
            final availableBelow = math.max(
              0.0,
              screenHeight - keyboardHeight - origin.dy - fieldHeight - 12,
            );
            final safeTop = MediaQuery.paddingOf(overlayContext).top;
            final availableAbove = math.max(0.0, origin.dy - safeTop - 12);
            final showAbove = availableBelow < 130 && availableAbove > availableBelow;
            final availableSpace = showAbove ? availableAbove : availableBelow;

            if (availableSpace < 52) {
              return const SizedBox.shrink();
            }

            final options = _filteredOptions(searchValue.text);
            final maxHeight = math.min(390.0, availableSpace);
            final height = math.min(
              maxHeight,
              math.max(52.0, options.length * 52.0),
            );

            return Positioned(
              top: 0,
              left: 0,
              width: width,
              child: CompositedTransformFollower(
                link: _anchor,
                showWhenUnlinked: false,
                offset: Offset(
                  0,
                  showAbove ? -height - 4 : fieldHeight + 4,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Material(
                    elevation: 8,
                    color: Theme.of(overlayContext)
                        .colorScheme
                        .surface,
                    borderRadius:
                    BorderRadius.circular(14),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: height,
                      child: options.isEmpty
                          ? Center(
                        child: Text(
                          widget.emptyMessage,
                        ),
                      )
                          : ListView.builder(
                        key: ValueKey(
                          _normalize(searchValue.text),
                        ),
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (
                            itemContext,
                            index,
                            ) {
                          final item = options[index];

                          return ListTile(
                            key: ValueKey(item.code),
                            dense: true,
                            title: Text(item.name),
                            trailing:
                            _selectedCode == item.code
                                ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                            )
                                : null,
                            onTap: () => _choose(item),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    _overlay = entry;
    overlayState.insert(entry);
  }

  // بستن و آزادسازی Overlay.
  void _close() {
    final entry = _overlay;

    if (entry == null) return;

    _overlay = null;

    entry.remove();
    entry.dispose();
  }

  @override
  void dispose() {
    _syncVersion++;

    _close();

    _focus.removeListener(_onFocusChanged);
    _focus.dispose();

    _search.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _anchor,
      child: KeyedSubtree(
        key: _targetKey,
        child: AppTextField(
          controller: _search,
          focusNode: _focus,
          onTap: _open,
          onChanged: _onTyped,
          title: widget.title,
          hint: widget.hint,
          icon: widget.icon,
          errorText: widget.errorText,
          textInputAction: TextInputAction.next,
        ),
      ),
    );
  }
}