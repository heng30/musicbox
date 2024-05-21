import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class NoData extends StatelessWidget {
  NoData({super.key, String? text}) : text = text ?? "没有数据".tr;

  final String text;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                  size: min(
                    size.height * 0.4,
                    min(
                      300.0,
                      size.width * 0.4,
                    ),
                  ),
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
