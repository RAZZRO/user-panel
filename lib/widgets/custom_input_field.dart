import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int? maxLength;
  final TextInputType keyboardType;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final bool isEditable;
  final bool isPassword; // پارامتر جدید برای تشخیص رمز عبور

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textDirection = TextDirection.rtl,
    this.textAlign = TextAlign.right,
    this.isEditable = true,
    this.isPassword = false,
  });
  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      validator: widget.validator,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
      enabled: widget.isEditable,
      obscureText: widget.isPassword ? _obscureText : false,
    );
  }
}
