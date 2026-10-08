import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/widgets/forms/app_text_field.dart';

/// کمبوباکس قابل‌تایپ استان که پیشنهادهای آن دقیقاً زیر فیلد باز می‌شود.
class ProvinceCombobox extends StatefulWidget {
  /// متن ورودی نام استان است ولی مقدار ذخیره‌شده در code کد استان خواهد بود.
  const ProvinceCombobox({super.key, required this.code, required this.provinces, required this.onChanged, this.errorText});
  final String code;
  final List<Province> provinces;
  final ValueChanged<String> onChanged;
  final String? errorText;

  /// ایجاد State برای نگهداری جستجو و فهرست بازشونده.
  @override
  State<ProvinceCombobox> createState() => _ProvinceComboboxState();
}

/// مدیریت کنترلر جستجو، اتصال لایه بازشونده و انتخاب استان.
class _ProvinceComboboxState extends State<ProvinceCombobox> {
  final LayerLink _anchor = LayerLink();
  final GlobalKey _targetKey = GlobalKey();
  final FocusNode _focus = FocusNode();
  late final TextEditingController _search;
  OverlayEntry? _overlay;

  /// تبدیل کد ذخیره‌شده به نام قابل نمایش؛ کد ناشناخته حفظ می‌شود.
  String _labelFor(String code) {
    for (final province in widget.provinces) {
      if (province.code == code || province.name == code) return province.name;
    }
    return code;
  }

  /// ایجاد کنترلر جستجو و اتصال تغییر فوکوس به باز/بسته‌شدن لیست.
  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: _labelFor(widget.code));
    _focus.addListener(_onFocusChanged);
  }

  /// هماهنگ‌سازی متن با مقدار جدیدی که پس از refresh آدرس از سرور می‌آید.
  @override
  void didUpdateWidget(covariant ProvinceCombobox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code || oldWidget.provinces != widget.provinces) {
      final value = _labelFor(widget.code);
      if (_search.text != value) {
        _search.value = TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length));
      }
      _overlay?.markNeedsBuild();
    }
  }

  /// تبدیل حروف عربی به فارسی برای جستجوی سازگارتر نام استان‌ها.
  String _normalize(String value) => value.trim().toLowerCase().replaceAll('ي', 'ی').replaceAll('ك', 'ک');

  /// فیلتر همزمان استان‌ها بر اساس کاراکترهای واردشده.
  List<Province> get _options {
    final query = _normalize(_search.text);
    return widget.provinces.where((province) => _normalize(province.name).contains(query) || _normalize(province.code).contains(query)).toList(growable: false);
  }

  /// باز شدن لیست زیر فیلد هنگام دریافت فوکوس و بستن آن با خروج فوکوس.
  void _onFocusChanged() {
    if (_focus.hasFocus) { _open(); } else { _close(); }
  }

  /// ثبت هر کاراکتر در فرم و بازسازی بلافاصله پیشنهادهای فیلترشده.
  void _onTyped(String value) {
    widget.onChanged(value);
    _open();
    _overlay?.markNeedsBuild();
  }

  /// انتخاب استان با نمایش نام و ارسال کد دقیق API به فرم.
  void _choose(Province province) {
    _search.value = TextEditingValue(text: province.name, selection: TextSelection.collapsed(offset: province.name.length));
    widget.onChanged(province.code);
    _close();
    _focus.unfocus();
  }

  /// ایجاد لیست پرارتفاع (حداکثر ۳۹۰ پیکسل) که زیر خود فیلد قرار می‌گیرد.
  void _open() {
    if (_overlay != null || !mounted) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    _overlay = OverlayEntry(builder: (overlayContext) {
      final target = _targetKey.currentContext?.findRenderObject();
      final box = target is RenderBox ? target : null;
      final width = box?.size.width ?? MediaQuery.sizeOf(context).width - 32;
      final fieldHeight = box?.size.height ?? 78;
      final options = _options;
      // صفحه‌کلید و فاصله تا پایین نمایشگر محاسبه می‌شوند تا لیست فقط پایین فیلد دیده شود.
      final origin = box?.localToGlobal(Offset.zero) ?? Offset.zero;
      final availableBelow = MediaQuery.sizeOf(context).height - MediaQuery.viewInsetsOf(context).bottom - origin.dy - fieldHeight - 12;
      final maxHeight = math.min(390.0, math.max(54.0, availableBelow));
      final height = math.min(maxHeight, math.max(54.0, options.length * 52.0));
      return Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _anchor,
          showWhenUnlinked: false,
          offset: Offset(0, fieldHeight + 4),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Material(
              elevation: 8,
              color: Theme.of(overlayContext).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: height,
                child: options.isEmpty
                  ? const Center(child: Text('استانی با این نام پیدا نشد.'))
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (itemContext, index) {
                        final province = options[index];
                        return ListTile(
                          dense: true,
                          title: Text(province.name),
                          trailing: widget.code == province.code ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                          onTap: () => _choose(province),
                        );
                      },
                    ),
              ),
            ),
          ),
        ),
      );
    });
    overlay.insert(_overlay!);
  }

  /// حذف لایه کمبوباکس از Overlay بدون باقی گذاشتن ویجت شناور.
  void _close() { _overlay?.remove(); _overlay?.dispose(); _overlay = null; }

  /// آزادسازی فوکوس و کنترلر و لایه بازشونده هنگام خروج از تب.
  @override
  void dispose() { _close(); _focus.removeListener(_onFocusChanged); _focus.dispose(); _search.dispose(); super.dispose(); }

  /// فیلد ورودی ثابت می‌ماند و فقط فهرست نتایج زیر آن تغییر می‌کند.
  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    link: _anchor,
    child: KeyedSubtree(
      key: _targetKey,
      child: AppTextField(
        controller: _search,
        focusNode: _focus,
        onTap: _open,
        onChanged: _onTyped,
        title: 'استان',
        hint: 'نام استان را بنویسید یا انتخاب کنید',
        icon: Icons.map_outlined,
        errorText: widget.errorText,
        textInputAction: TextInputAction.next,
      ),
    ),
  );
}
