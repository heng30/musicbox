import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class NoData extends StatelessWidget {
  NoData({super.key, String? text, double? size})
      : text = text ?? "没有数据".tr,
        size = size ?? 300.0;

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final appsize = MediaQuery.of(context).size;

    final innerSize = min(
        appsize.height * 0.4,
        min(
          size,
          appsize.width * 0.4,
        ));

    return Obx(
      () => Container(
        color: CTheme.background,
        child: Center(
          child: Opacity(
            opacity: 0.1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  IconFonts.nodata,
                  size: innerSize,
                ),
                const SizedBox(height: CTheme.padding * 2),
                Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
