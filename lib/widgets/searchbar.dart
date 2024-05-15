import 'package:flutter/material.dart';

import '../theme/theme.dart';

class CSearchBar extends StatelessWidget {
  const CSearchBar({
    super.key,
    required this.height,
    required this.controller,
    required this.onSubmitted,
    this.focusNode,
    this.hintText,
    this.autofocus = true,
  });

  final double height;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? hintText;
  final Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: 1,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: CTheme.primary),
        contentPadding: const EdgeInsets.all(0),
        prefixIcon: IconButton(
          icon: Icon(Icons.search, size: height * 0.6, color: CTheme.primary),
          onPressed: () => onSubmitted(controller.text),
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear, size: height * 0.6, color: CTheme.primary),
          onPressed: () => controller.clear(),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: CTheme.secondary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(CTheme.borderRadius * 4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: CTheme.secondaryBrand,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(CTheme.borderRadius * 4),
        ),
      ),
    );
  }
}
