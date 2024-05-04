import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class NoData extends StatelessWidget {
  const NoData({super.key});

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
                SizedBox(height: CTheme.padding * 2),
                Text(
                  "没有数据".tr,
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
