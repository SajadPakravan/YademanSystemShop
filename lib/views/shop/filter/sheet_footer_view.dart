import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class SheetFooterView extends StatelessWidget {
  const SheetFooterView({super.key, required this.viewModel, required this.deleteEnabled, required this.onDelete, required this.onApply, this.deleteLabel = 'حذف فیلتر'});

  final ShopViewModel viewModel;
  final bool deleteEnabled;
  final VoidCallback onDelete;
  final VoidCallback onApply;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Container(
      padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(10), r.pageHorizontalPadding, math.max(r.space(10), r.padding.bottom + 4)),
      decoration: BoxDecoration(color: colors.surface, border: Border(top: BorderSide(color: colors.divider))),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: deleteEnabled ? onDelete : null,
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(r.buttonHeight),
                side: BorderSide(color: deleteEnabled ? AppColors.accent : colors.border),
                foregroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.cardRadius)),
              ),
              child: AppText.labelLarge(deleteLabel, color: deleteEnabled ? AppColors.accent : colors.textMuted),
            ),
          ),
          SizedBox(width: r.space(10)),
          Expanded(
            child: AnimatedBuilder(
              animation: viewModel,
              builder: (context, child) {
                return IgnorePointer(
                  ignoring: !viewModel.canApplyPreview,
                  child: FilledButton(
                    onPressed: onApply,
                    style: FilledButton.styleFrom(minimumSize: Size.fromHeight(r.buttonHeight), backgroundColor: AppColors.accent),
                    child: viewModel.isPreviewLoading
                        ? SizedBox(width: r.icon(22), height: r.icon(22), child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.onBrand))
                        : viewModel.previewErrorMessage != null
                            ? const AppText.labelLarge('خطا در محاسبه محصولات', color: AppColors.onBrand)
                            : AppText.labelLarge('مشاهده ${AppFunction.faDigit(viewModel.previewCount)} محصول', color: AppColors.onBrand),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
