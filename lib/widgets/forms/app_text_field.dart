import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.title,
    required this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.textDirection = TextDirection.rtl,
    this.errorText,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String title;
  final String hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextDirection textDirection;
  final String? errorText;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final hasError = errorText != null && errorText!.trim().isNotEmpty;

    return Column(
      spacing: r.space(5),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText.labelMedium(title, color: context.appColors.textSecondary, fontWeight: FontWeight.w700),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textDirection: textDirection,
          readOnly: readOnly,
          maxLines: obscureText ? 1 : maxLines,
          inputFormatters: maxLength == null ? null : [LengthLimitingTextInputFormatter(maxLength)],
          autofocus: autofocus,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(hintText: hint, hintTextDirection: TextDirection.rtl, prefixIcon: icon == null ? null : Icon(icon)),
        ),
        if (hasError) AppText.bodySmall(errorText!, color: AppColors.error),
      ],
    );
  }
}
