import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSubmitting;
  final ButtonStyle? style;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.isSubmitting,
    required this.label,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: isSubmitting ? null : onPressed,
      child: isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(label),
    );
  }
}
