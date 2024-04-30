import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'pages/home.dart';
import 'routes/routes.dart';
import 'binding/binding.dart';
import 'theme/controller.dart';
import 'lang/translation_service.dart';

void main() {
  initGlobalController();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeController.light,
      darkTheme: ThemeController.dark,
      themeMode: ThemeMode.light,

      initialBinding: InitControllerBinding(),
      home: const HomePage(),

      // routes
      initialRoute: "/",
      getPages: AppPage.routes,
      unknownRoute: AppPage.nofound,
      defaultTransition: Transition.rightToLeft,

      // TranslationService
      locale: const Locale('zh', 'CN'),
      fallbackLocale: TranslationService.fallbackLocal,
      translations: TranslationService(),
    );
  }
}
