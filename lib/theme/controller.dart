import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/setting_controller.dart';

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
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;
  set isDarkMode(bool v) => _isDarkMode.value = v;

  static final light = lightMode;
  static final dark = darkMode;

  final settingController = Get.find<SettingController>();

  @override
  void onInit() {
    super.onInit();
    isDarkMode = settingController.isDarkMode;
  }

  void changeTheme(bool darkMode) async {
    isDarkMode = darkMode;
    Get.changeTheme(isDarkMode ? ThemeData.dark() : ThemeData.light());

    settingController.isDarkMode = isDarkMode;
    await settingController.save();
  }

  void toggleTheme() async {
    isDarkMode = !isDarkMode;
    Get.changeTheme(isDarkMode ? ThemeData.dark() : ThemeData.light());

    settingController.isDarkMode = isDarkMode;
    await settingController.save();
  }
}
