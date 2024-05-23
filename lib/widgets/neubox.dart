import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class NeuBox extends StatelessWidget {
  const NeuBox({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CTheme.borderRadius),
          color: CTheme.background,
          boxShadow: [
            BoxShadow(
              color: CTheme.isDarkMode ? Colors.black : Colors.grey.shade500,
              blurRadius: CTheme.blurRadius,
              offset: const Offset(CTheme.margin, CTheme.margin),
            ),
            BoxShadow(
              color: CTheme.isDarkMode ? Colors.grey.shade800 : Colors.white,
              blurRadius: CTheme.blurRadius,
              offset: const Offset(-CTheme.margin, -CTheme.margin),
            ),
          ],
        ),
        padding: const EdgeInsets.all(CTheme.padding * 3),
        child: child,
      ),
    );
  }
}
