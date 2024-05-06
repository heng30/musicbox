import 'dart:io';
import 'package:get/get.dart';
import 'package:toml/toml.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingController extends GetxController {
  bool isDarkMode = false;
  bool isLangZh = true;

  late String configPath;
  late String dbPath;

  Future<bool> init() async {
    final log = Logger();
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final root = await getApplicationSupportDirectory();
      configPath = "${root.path}/${packageInfo.appName}.toml";
      dbPath = "${root.path}/${packageInfo.appName}.db";

      log.d("config path: $configPath");
      log.d("database path: $dbPath");

      await load();
    } catch (e) {
      log.w("Init path faild. Error: ${e.toString()}");
      return false;
    }

    return true;
  }

  Future<bool> load() async {
    final log = Logger();
    try {
      final conf = (await TomlDocument.load(configPath)).toMap();
      isDarkMode = conf['isDarkMode'] ?? false;
      isLangZh = conf['isLangZh'] ?? true;
      log.d(conf.toString());
    } catch (e) {
      log.d("Load configure error: ${e.toString()}");
      return false;
    }

    return true;
  }

  Future<bool> save() async {
    final conf = TomlDocument.fromMap({
      'isDarkMode': isDarkMode,
      'isLangZh': isLangZh,
    }).toString();

    final f = File(configPath);
    try {
      await f.writeAsString(conf);
    } catch (e) {
      Get.snackbar("保存配置失败".tr, e.toString());
      return false;
    }

    return true;
  }
}
