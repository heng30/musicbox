import 'package:get/get.dart';

import '../pages/home.dart';
import '../pages/nofound.dart';
import '../pages/settings.dart';

class AppPage {
  static final nofound = GetPage(
    name: "/nofound",
    page: () => const NoFound(),
  );

  static final routes = [
    GetPage(
      name: "/",
      page: () => const HomePage(),
    ),
    GetPage(
      name: "/settings",
      page: () => const SettingsPage(),
    ),
  ];
}
