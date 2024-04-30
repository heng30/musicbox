import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LangController extends GetxController {
  final isZh = true.obs;

  void changeLang(bool isZh) {
    this.isZh.value = isZh;
    const zh = Locale('zh', 'CN');
    const en = Locale('en', 'US');
    Get.updateLocale(this.isZh.value ? zh : en);
  }
}
