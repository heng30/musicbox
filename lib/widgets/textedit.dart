import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class TextEdit extends StatelessWidget {
  const TextEdit({
    super.key,
    required this.controller,
    required this.onChanged,
    this.focusNode,
    this.hintText,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? hintText;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: CTheme.secondary,
          border: Border.all(
            color: CTheme.inversePrimary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(CTheme.borderRadius),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          minLines: 1,
          maxLines: null,
          autofocus: autofocus,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: CTheme.primary),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(CTheme.borderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(CTheme.borderRadius),
            ),
          ),
        ),
      ),
    );
  }
}
