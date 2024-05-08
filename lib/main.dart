import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/util.dart';
import 'pages/home.dart';
import 'routes/routes.dart';
import 'binding/binding.dart';
import 'theme/theme.dart';
import 'theme/controller.dart';
import 'lang/translation_service.dart';
import 'models/setting_controller.dart';
import 'src/rust/frb_generated.dart';
import 'src/rust/api/log.dart' as rustlog;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RustLib.init();
  await rustlog.init();

  await initGlobalController();

  if (isDesktopPlatform()) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      size: Size(CTheme.windowWidth, CTheme.windowHeight),
      center: true,
      fullScreen: false,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return TooltipVisibility(
      visible: false,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,

        initialBinding: InitControllerBinding(),
        home: const HomePage(),

        // routes
        initialRoute: "/",
        getPages: AppPage.routes,
        unknownRoute: AppPage.nofound,
        defaultTransition: Transition.rightToLeft,

        // theme
        theme: ThemeController.light,
        darkTheme: ThemeController.dark,
        themeMode: Get.find<SettingController>().isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,

        // translation
        locale: Get.find<SettingController>().isLangZh
            ? const Locale('zh', 'CN')
            : const Locale('en', 'US'),
        fallbackLocale: TranslationService.fallbackLocal,
        translations: TranslationService(),
        supportedLocales: const <Locale>[
          Locale('en', 'US'),
          Locale('zh', 'CN'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:musicbox/src/rust/api/simple.dart';
// import 'package:musicbox/src/rust/frb_generated.dart';

// Future<void> main() async {
//   await RustLib.init();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
//         body: Center(
//           child: Text(
//               'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
//         ),
//       ),
//     );
//   }
// }
