import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_function.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';

class SheetFooterView extends StatelessWidget {
  const SheetFooterView({super.key, required this.viewModel, required this.deleteEnabled, required this.onDelete, required this.onApply, this.deleteLabel = 'حذف فیلتر'});

  final ShopViewModel viewModel;
  final bool deleteEnabled;
  final VoidCallback onDelete;
  final VoidCallback onApply;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, math.max(10, MediaQuery.paddingOf(context).bottom + 4)),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffeeeeee))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: deleteEnabled ? onDelete : null,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: BorderSide(color: deleteEnabled ? AppColors.accent : Colors.black12),
                foregroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(deleteLabel),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedBuilder(
              animation: viewModel,
              builder: (context, child) {
                return IgnorePointer(
                  ignoring: !viewModel.canApplyPreview,
                  child: FilledButton(
                    onPressed: onApply,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: viewModel.isPreviewLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : viewModel.previewErrorMessage != null
                        ? const Text('خطا در محاسبه محصولات')
                        : Text('مشاهده ${AppFunction.faDigit(viewModel.previewCount)} محصول'),
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