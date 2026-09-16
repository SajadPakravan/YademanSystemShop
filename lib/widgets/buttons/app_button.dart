import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

enum AppButtonType { filled, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.filled,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.expand = true,
    this.foregroundColor,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool loading;
  final bool enabled;
  final bool expand;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final action = enabled && !loading ? onPressed : null;
    final content = loading
        ? SizedBox(
            width: context.responsive.icon(20),
            height: context.responsive.icon(20),
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: context.responsive.icon(19)),
                SizedBox(width: context.responsive.space(7)),
              ],
              Flexible(child: AppText.labelLarge(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          );

    final buttonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(expand ? double.infinity : 64, context.responsive.buttonHeight)),
      foregroundColor: foregroundColor == null ? null : WidgetStatePropertyAll(foregroundColor),
      backgroundColor: backgroundColor == null ? null : WidgetStatePropertyAll(backgroundColor),
    );

    return switch (type) {
      AppButtonType.filled => FilledButton(onPressed: action, style: buttonStyle, child: content),
      AppButtonType.outlined => OutlinedButton(onPressed: action, style: buttonStyle, child: content),
      AppButtonType.text => TextButton(onPressed: action, style: buttonStyle, child: content),
    };
  }
}
