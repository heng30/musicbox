import 'package:get/get.dart';

import '../pages/home.dart';
import '../pages/nofound.dart';
import '../pages/settings.dart';
import '../pages/song.dart';
import '../pages/search.dart';
import '../pages/manage.dart';
import "../pages/about.dart";
import "../pages/donate.dart";
import "../pages/feedback.dart";

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
      name: "/song",
      page: () => const SongPage(),
    ),
    GetPage(
      name: "/search",
      page: () => const SearchPage(),
    ),
    GetPage(
      name: "/manage",
      page: () => const ManagePage(),
    ),
    GetPage(
      name: "/settings",
      page: () => const SettingsPage(),
    ),
    GetPage(
      name: "/about",
      page: () => const AboutPage(),
    ),
    GetPage(
      name: "/donate",
      page: () => const DonatePage(),
    ),
    GetPage(
      name: "/feedback",
      page: () => const FeedbackPage(),
    ),
  ];
}
