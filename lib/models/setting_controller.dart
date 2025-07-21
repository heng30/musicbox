import 'dart:io';
import 'package:get/get.dart';
import 'package:toml/toml.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../lang/translation_service.dart';

class Find implements TomlEncodableValue {
  int searchCount = 10;
  int minSecondLength = 90;
  int maxSecondLength = 600;

  Find({
    this.searchCount = 10,
    this.minSecondLength = 90,
    this.maxSecondLength = 600,
  });

  @override
  dynamic toTomlValue() {
    return {
      'searchCount': searchCount,
      'minSecondLength': minSecondLength,
      'maxSecondLength': maxSecondLength,
    };
  }

  void fromMap(Map<String, dynamic> m) {
    searchCount = m['searchCount'] ?? 10;
    minSecondLength = m['minSecondLength'] ?? 90;
    maxSecondLength = m['maxSecondLength'] ?? 600;
  }
}

class SettingController extends GetxController {
  bool isDarkMode = false;
  bool isLangZh = true;
  bool isFirstLaunch = false;
  double playbackSpeed = 1.0;
  String appid = const Uuid().v4();

  Find find = Find();

  late String configPath;
  late String dbPath;
  late String dbName;

  final log = Logger();

  Future<bool> init() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final root = await getApplicationSupportDirectory();
      configPath = "${root.path}/${packageInfo.appName}.toml";
      dbName = "${packageInfo.appName}.db";
      dbPath = "${root.path}/$dbName";

      log.d("config path: $configPath");
      log.d("database path: $dbPath");

      if (!(await load())) {
        return await save();
      }
    } catch (e) {
      log.w("load path faild. Error: ${e.toString()}");
      log.d("save default configure");
      return await save();
    }
    return true;
  }

  Future<bool> load() async {
    isLangZh = TranslationService.locale?.languageCode == 'zh';

    try {
      final conf = (await TomlDocument.load(configPath)).toMap();
      isDarkMode = conf['isDarkMode'] ?? false;
      isLangZh = conf['isLangZh'] ?? isLangZh;
      appid = conf['appid'] ?? const Uuid().v4();
      playbackSpeed = conf['playbackSpeed'] ?? 1.0;
      find.fromMap(conf['find']);

      log.d(conf.toString());
    } catch (e) {
      log.d("Load configure error: ${e.toString()}");
      isFirstLaunch = true;
      return false;
    }

    return true;
  }

  Future<bool> save() async {
    final conf = TomlDocument.fromMap({
      'appid': appid,
      'isDarkMode': isDarkMode,
      'isLangZh': isLangZh,
      'playbackSpeed': playbackSpeed,
      'find': find,
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
