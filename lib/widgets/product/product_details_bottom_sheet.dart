import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/product_detail_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  const ProductDetailsBottomSheet({
    super.key,
    required this.description,
    required this.attributes,
    required this.initialTabIndex,
  });

  final String description;
  final List<ProductAttribute> attributes;
  final int initialTabIndex;

  static Future<void> show({
    required BuildContext context,
    required String description,
    required List<ProductAttribute> attributes,
    int initialTabIndex = 0,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.appColors.overlay,
      builder: (_) => ProductDetailsBottomSheet(
        description: description,
        attributes: attributes,
        initialTabIndex: initialTabIndex,
      ),
    );
  }

  @override
  State<ProductDetailsBottomSheet> createState() => _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
  late int _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTabIndex.clamp(0, 1).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.60,
        minChildSize: 0.50,
        maxChildSize: 0.96,
        expand: false,
        builder: (context, scrollController) {
          return Material(
            color: colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(r.radius(22))),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SizedBox(height: r.space(8)),
                Container(
                  width: r.percentWidth(0.12, min: 42, max: 62),
                  height: r.space(4, min: 4, max: 5),
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(r.radius(20)),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    r.pageHorizontalPadding,
                    r.space(10),
                    r.pageHorizontalPadding,
                    r.space(6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText.titleMedium(
                          'مشخصات و بررسی کالا',
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      IconButton(
                        tooltip: 'بستن',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                _tabs(context),
                Divider(height: 1, color: colors.divider),
                Expanded(
                  child: _activeTab == 0
                      ? _description(context, scrollController)
                      : _attributes(context, scrollController),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    Widget tab({required int index, required String title}) {
      final selected = _activeTab == index;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _activeTab = index),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: r.space(11)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.bodyMedium(
                  title,
                  color: selected ? colors.textPrimary : colors.textSecondary,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
                SizedBox(height: r.space(8)),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? r.percentWidth(0.22, min: 72, max: 120) : 0,
                  height: 2,
                  color: selected ? colors.textPrimary : AppColors.transparent,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab(index: 0, title: 'معرفی کالا'),
        tab(index: 1, title: 'جدول مشخصات'),
      ],
    );
  }

  Widget _description(BuildContext context, ScrollController controller) {
    final r = context.responsive;
    final colors = context.appColors;
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    if (widget.description.trim().isEmpty) {
      return ListView(
        controller: controller,
        padding: EdgeInsets.all(r.pageHorizontalPadding),
        children: [
          AppText.bodyMedium('برای این کالا معرفی ثبت نشده است.', color: colors.textSecondary),
        ],
      );
    }

    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(
        r.pageHorizontalPadding,
        r.space(18),
        r.pageHorizontalPadding,
        r.space(30),
      ),
      children: [
        HtmlWidget(
          widget.description.toPersianDigit(),
          textStyle: baseStyle.copyWith(
            color: colors.textPrimary,
            height: 1.9,
            fontSize: r.font(baseStyle.fontSize ?? 14),
          ),
        ),
      ],
    );
  }

  Widget _attributes(BuildContext context, ScrollController controller) {
    final r = context.responsive;
    final colors = context.appColors;

    if (widget.attributes.isEmpty) {
      return ListView(
        controller: controller,
        padding: EdgeInsets.all(r.pageHorizontalPadding),
        children: [
          AppText.bodyMedium('مشخصاتی برای این کالا ثبت نشده است.', color: colors.textSecondary),
        ],
      );
    }

    return ListView.separated(
      controller: controller,
      padding: EdgeInsets.fromLTRB(
        r.pageHorizontalPadding,
        r.space(16),
        r.pageHorizontalPadding,
        r.space(30),
      ),
      itemCount: widget.attributes.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: colors.divider),
      itemBuilder: (context, index) {
        final attribute = widget.attributes[index];
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  alignment: AlignmentDirectional.centerStart,
                  padding: EdgeInsets.symmetric(horizontal: r.space(10), vertical: r.space(13)),
                  color: colors.surfaceVariant,
                  child: AppText.bodyMedium(
                    attribute.name.replaceAll('-', ' '),
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  alignment: AlignmentDirectional.centerStart,
                  padding: EdgeInsets.symmetric(horizontal: r.space(10), vertical: r.space(13)),
                  child: AppText.bodyMedium(
                    attribute.options.join('، ').toPersianDigit(),
                    color: colors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
