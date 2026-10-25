import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shop_theme.dart';

/// Reusable styled text field matching the signup_screen.dart input style.
///
/// Supports label, hint, prefix icon, suffix icon, error text, keyboard type,
/// input formatters, obscure text, validator, and controller.
class ShopTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final IconData? icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;

  const ShopTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.onTap,
    this.readOnly = false,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(label, style: ShopTheme.labelStyle),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: ShopTheme.bodyMainStyle,
          decoration: ShopTheme.inputDecoration(
            hintText: hintText,
            prefixIcon: icon,
            suffixIcon: suffixIcon,
          ),
          validator: validator,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          onTap: onTap,
          readOnly: readOnly,
          maxLines: obscureText ? 1 : maxLines,
        ),
      ],
    );
  }
}
