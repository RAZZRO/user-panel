import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSubmitting;
  final Color? backgroundColor;
  final Color? textColor;
  final ButtonStyle? style;
  final Widget? icon;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.isSubmitting,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.style,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استایل پایه از theme فعلی گرفته می‌شود
    final baseStyle = Theme.of(context).elevatedButtonTheme.style;

    // اگر کاربر رنگ خاصی وارد کرده باشد، آن را با تم ترکیب می‌کنیم
    final combinedStyle = baseStyle?.copyWith(
      backgroundColor: backgroundColor != null
          ? WidgetStateProperty.all(backgroundColor)
          : null,
      foregroundColor: textColor != null
          ? WidgetStateProperty.all(textColor)
          : null,
    );

    return ElevatedButton(
      style: style ?? combinedStyle,
      onPressed: isSubmitting ? null : onPressed,
      child: isSubmitting
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: textColor ?? Theme.of(context).colorScheme.onPrimary,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );
  }
}
