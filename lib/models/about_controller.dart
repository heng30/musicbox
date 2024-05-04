import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../theme/theme.dart';

class AboutController extends GetxController {
  final _packageInfo = PackageInfo(
    appName: "musicbox",
    packageName: "musicbox",
    version: "1.0.0",
    buildNumber: "1.0.0",
  ).obs;

  final String logo = CIcons.favicon;
  final String detail =
      "Based on Flutter. Copyright 2022-2030. All rights reserved. The program is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.";

  PackageInfo get packageInfo => _packageInfo.value;

  void init() async {
    try {
      _packageInfo.value = await PackageInfo.fromPlatform();
    } catch (e) {
      Logger().d("$e");
    }
  }
}
