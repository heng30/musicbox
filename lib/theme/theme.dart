import 'package:get/get.dart';
import 'package:flutter/material.dart';

import './controller.dart';

class CTheme {
  static bool get isDarkMode => Get.find<ThemeController>().isDarkMode.value;

  static Color get background => Get.find<ThemeController>().isDarkMode.value
      ? ThemeController.dark.colorScheme.background
      : ThemeController.light.colorScheme.background;

  static Color get primary => Get.find<ThemeController>().isDarkMode.value
      ? ThemeController.dark.colorScheme.primary
      : ThemeController.light.colorScheme.primary;

  static Color get secondary => Get.find<ThemeController>().isDarkMode.value
      ? ThemeController.dark.colorScheme.secondary
      : ThemeController.light.colorScheme.secondary;

  static Color get inversePrimary =>
      Get.find<ThemeController>().isDarkMode.value
          ? ThemeController.dark.colorScheme.inversePrimary
          : ThemeController.light.colorScheme.inversePrimary;

  static Color get favorite => Get.find<ThemeController>().isDarkMode.value
      ? Colors.red.shade300
      : Colors.red.shade300;

  static double get blurRadius =>
      Get.find<ThemeController>().isDarkMode.value ? margin * 2 : margin * 3;

  static double windowWidth = 350;
  static double windowHeight = 800;

  static double borderRadius = 8;
  static double padding = 4;
  static double margin = 4;

  static double soundsliderwidth = 15;
}
