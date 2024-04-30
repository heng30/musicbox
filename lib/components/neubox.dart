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
              color: CTheme.primary,
              blurRadius: CTheme.blurRadius,
              offset: Offset(CTheme.margin, CTheme.margin),
            ),
            BoxShadow(
              color: CTheme.secondary,
              blurRadius: CTheme.blurRadius,
              offset: Offset(-CTheme.margin, -CTheme.margin),
            ),
          ],
        ),
        padding: EdgeInsets.all(CTheme.padding * 3),
        child: child,
      ),
    );
  }
}
