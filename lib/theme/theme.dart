import 'package:get/get.dart';
import 'package:flutter/material.dart';

import './controller.dart';

class CTheme {
  static bool get isDarkMode => Get.find<ThemeController>().isDarkMode;

  static Color get background => Get.find<ThemeController>().isDarkMode
      ? ThemeController.dark.colorScheme.background
      : ThemeController.light.colorScheme.background;

  static Color get primary => Get.find<ThemeController>().isDarkMode
      ? ThemeController.dark.colorScheme.primary
      : ThemeController.light.colorScheme.primary;

  static Color get secondary => Get.find<ThemeController>().isDarkMode
      ? ThemeController.dark.colorScheme.secondary
      : ThemeController.light.colorScheme.secondary;

  static Color get inversePrimary => Get.find<ThemeController>().isDarkMode
      ? ThemeController.dark.colorScheme.inversePrimary
      : ThemeController.light.colorScheme.inversePrimary;

  static Color get bottomPlayerBackground =>
      Get.find<ThemeController>().isDarkMode
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFDADADA);

  static Color get favorite => Get.find<ThemeController>().isDarkMode
      ? Colors.red.shade200
      : Colors.red.shade200;

  static Color get aduioProcessBar => Get.find<ThemeController>().isDarkMode
      ? Colors.green.shade800
      : Colors.green.shade300;

  static double get blurRadius =>
      Get.find<ThemeController>().isDarkMode ? margin * 2 : margin * 3;

  static Color brand = const Color(0xFF0000B8);
  static Color secondaryBrand = const Color(0xFF3F51B5);

  static const double windowWidth = 380.0;
  static const double windowHeight = 800.0;
  static const double faviconSize = 80.0;
  static const double searchBarHeight = 32.0;

  static const double borderRadius = 8.0;
  static const double padding = 4.0;
  static const double margin = 4.0;
  static const double iconSize = 24.0;
}

class CIcons {
  static const String favicon = "assets/icons/favicon.png";
  static const String wechat = "assets/icons/wechat-light.svg";
  static const String metamask = "assets/icons/metamask-light.svg";
}

class CImages {
  static const String wechatPay = "assets/images/wechat-pay.png";
  static const String metamaskPay = "assets/images/metamask-pay.png";

  static const String landingPlayer = "assets/images/landing-player.svg";
  static const String landingDownload = "assets/images/landing-download.svg";
  static const String landingWelcome = "assets/images/landing-welcome.svg";
}

class IconFonts {
  static const IconData nodata = IconData(
    0xe60e,
    fontFamily: "iconfont",
    matchTextDirection: true,
  );
  static const IconData send = IconData(
    0xe7f7,
    fontFamily: "iconfont",
    matchTextDirection: true,
  );
  static const IconData donate = IconData(
    0xefa1,
    fontFamily: "iconfont",
    matchTextDirection: true,
  );
  static const IconData github = IconData(
    0xe632,
    fontFamily: "iconfont",
    matchTextDirection: true,
  );
}
