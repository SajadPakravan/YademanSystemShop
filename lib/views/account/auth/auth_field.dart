import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yad_sys/tools/app_colors.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    required this.keyboardType,
    required this.textInputAction,
    required this.validator,
    required this.onSubmitted,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onSubmitted;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textDirection: TextDirection.ltr,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\x21-\x7E]'))],
      autofillHints: obscureText ? const <String>[AutofillHints.password] : null,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.surface,
      ),
    );
  }
}
