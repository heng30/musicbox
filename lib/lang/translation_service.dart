import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'en.dart';
import 'zh.dart';

class TranslationService extends Translations {
  static Locale? get locale => Get.deviceLocale;
  static const fallbackLocal = Locale("zh", "CN");

  @override
  Map<String, Map<String, String>> get keys => {'en_US': en, 'zh_CN': zh};
}
