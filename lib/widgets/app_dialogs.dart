import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class AppDialogs {
  const AppDialogs();

  Future<T?> editeValue<T>({
    required BuildContext context,
    required String value,
    required String title,
    required TextEditingController controller,
    required String hint,
    TextInputType textInputType = TextInputType.name,
    TextDirection textDirection = TextDirection.rtl,
    required VoidCallback onPressed,
  }) {
    final r = context.responsive;
    final colors = context.appColors;

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: colors.overlay,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, animation, _, _) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ScaleTransition(
            scale: curved,
            child: Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: r.isTablet ? 520 : 430),
                child: Padding(
                  padding: EdgeInsets.all(r.space(18)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppText.titleMedium(title, fontWeight: FontWeight.w800, textAlign: TextAlign.center),
                      SizedBox(height: r.space(18)),
                      TextFormField(
                        controller: controller,
                        keyboardType: textInputType,
                        autofocus: true,
                        textDirection: textDirection,
                        decoration: InputDecoration(hintText: hint),
                      ),
                      SizedBox(height: r.space(20)),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'ثبت',
                              icon: Icons.check_rounded,
                              onPressed: () {
                                controller.text = controller.text.trim();
                                onPressed();
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ),
                          SizedBox(width: r.space(10)),
                          Expanded(
                            child: AppButton(
                              label: 'بستن',
                              type: AppButtonType.outlined,
                              icon: Icons.close_rounded,
                              onPressed: () {
                                controller.text = value;
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
