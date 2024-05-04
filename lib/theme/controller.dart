import 'package:get/get.dart';
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade300,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    inversePrimary: Colors.grey.shade900,
  ),
);

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade600,
    secondary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade300,
  ),
);

class ThemeController extends GetxController {
  final isDarkMode = false.obs;

  static final light = lightMode;
  static final dark = darkMode;

  void changeTheme(bool isDarkMode) {
    this.isDarkMode.value = isDarkMode;
    Get.changeTheme(
        this.isDarkMode.value ? ThemeData.dark() : ThemeData.light());
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
  }
}
