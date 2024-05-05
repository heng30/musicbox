import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingController extends GetxController {
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;
  set isDarkMode(bool v) => _isDarkMode.value = v;

  final _isLangZh = true.obs;
  bool get isLangZh => _isLangZh.value;
  set isLangZh(bool v) => _isLangZh.value = v;

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
    } catch (e) {
      log.w("Init path faild. Error: ${e.toString()}");
      return false;
    }

    return true;
  }

  Future<bool> load() async {
    return true;
  }

  Future<bool> save() async {
    return true;
  }
}
