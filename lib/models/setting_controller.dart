import 'dart:io';
import 'package:get/get.dart';
import 'package:toml/toml.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../lang/translation_service.dart';

enum ProxyType {
  youtube,
  bilibili,
}

class Proxy implements TomlEncodableValue {
  Proxy({
    this.httpUrl = "127.0.0.1",
    this.httpPort = 3128,
    this.socks5Url = "127.0.0.1",
    this.socks5Port = 1080,
    bool enableYoutubeHttp = false,
    bool enableYoutubeSocks5 = false,
    bool enableBilibiliHttp = false,
    bool enableBilibiliSocks5 = false,
  })  : _enableYoutubeHttp = enableYoutubeHttp.obs,
        _enableYoutubeSocks5 = enableYoutubeSocks5.obs,
        _enableBilibiliHttp = enableBilibiliHttp.obs,
        _enableBilibiliSocks5 = enableBilibiliSocks5.obs;

  @override
  dynamic toTomlValue() {
    return {
      'httpUrl': httpUrl,
      'httpPort': httpPort,
      'socks5Url': httpUrl,
      'socks5Port': socks5Port,
      'enableYoutubeHttp': enableYoutubeHttp,
      'enableYoutubeSocks5': enableYoutubeSocks5,
      'enableBilibiliHttp': enableBilibiliHttp,
      'enableBilibiliSocks5': enableBilibiliSocks5,
    };
  }

  void fromMap(Map<String, dynamic> m) {
    httpUrl = m['httpUrl'] ?? "127.0.0.1";
    httpPort = m['httpPort'] ?? 3128;
    socks5Url = m['socks5Url'] ?? "127.0.0.1";
    socks5Port = m['socks5Port'] ?? 1080;
    enableYoutubeHttp = m['enableYoutubeHttp'] ?? false;
    enableYoutubeSocks5 = m['enableYoutubeSocks5'] ?? false;
    enableBilibiliHttp = m['enableBilibiliHttp'] ?? false;
    enableBilibiliSocks5 = m['enableBilibiliSocks5'] ?? false;
  }

  String httpUrl;
  int httpPort;

  String socks5Url;
  int socks5Port;

  final RxBool _enableYoutubeHttp;
  final RxBool _enableYoutubeSocks5;
  final RxBool _enableBilibiliHttp;
  final RxBool _enableBilibiliSocks5;

  bool get enableYoutubeHttp => _enableYoutubeHttp.value;
  set enableYoutubeHttp(bool v) => _enableYoutubeHttp.value = v;

  bool get enableYoutubeSocks5 => _enableYoutubeSocks5.value;
  set enableYoutubeSocks5(bool v) => _enableYoutubeSocks5.value = v;

  bool get enableBilibiliHttp => _enableBilibiliHttp.value;
  set enableBilibiliHttp(bool v) => _enableBilibiliHttp.value = v;

  bool get enableBilibiliSocks5 => _enableBilibiliSocks5.value;
  set enableBilibiliSocks5(bool v) => _enableBilibiliSocks5.value = v;

  String? url(ProxyType type) {
    switch (type) {
      case ProxyType.youtube:
        if (enableYoutubeHttp) {
          return "http://$httpUrl:$httpPort";
        } else if (enableYoutubeSocks5) {
          return "socks5://$socks5Url:$socks5Port";
        }
        break;
      case ProxyType.bilibili:
        if (enableBilibiliHttp) {
          return "http://$httpUrl:$httpPort";
        } else if (enableBilibiliSocks5) {
          return "socks5://$socks5Url:$socks5Port";
        }
        break;
    }
    return null;
  }
}

class Find implements TomlEncodableValue {
  int searchCount = 10;
  int minSecondLength = 90;
  int maxSecondLength = 600;

  final _enableYoutubeSearch = false.obs;
  bool get enableYoutubeSearch => _enableYoutubeSearch.value;
  set enableYoutubeSearch(bool v) => _enableYoutubeSearch.value = v;

  final _enableBilibiliSearch = true.obs;
  bool get enableBilibiliSearch => _enableBilibiliSearch.value;
  set enableBilibiliSearch(bool v) => _enableBilibiliSearch.value = v;

  final _enableVideoToAudio = false.obs;
  bool get enableVideoToAudio => _enableVideoToAudio.value;
  set enableVideoToAudio(bool v) => _enableVideoToAudio.value = v;

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
      'enableYoutubeSearch': enableYoutubeSearch,
      'enableBilibiliSearch': enableBilibiliSearch,
      'enableVideoToAudio': enableVideoToAudio,
    };
  }

  void fromMap(Map<String, dynamic> m) {
    searchCount = m['searchCount'] ?? 10;
    minSecondLength = m['minSecondLength'] ?? 90;
    maxSecondLength = m['maxSecondLength'] ?? 600;
    enableYoutubeSearch = m['enableYoutubeSearch'] ?? false;
    enableBilibiliSearch = m['enableBilibiliSearch'] ?? true;
    enableVideoToAudio = m['enableVideoToAudio'] ?? false;
  }
}

class SettingController extends GetxController {
  bool isDarkMode = false;
  bool isLangZh = true;
  bool isFirstLaunch = false;
  double playbackSpeed = 1.0;
  String appid = const Uuid().v4();

  Proxy proxy = Proxy();
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
      proxy.fromMap(conf['proxy']);

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
      'proxy': proxy,
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
