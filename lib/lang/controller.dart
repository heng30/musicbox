import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/setting_controller.dart';

class LangController extends GetxController {
  final _isZh = true.obs;
  bool get isZh => _isZh.value;
  set isZh(bool v) => _isZh.value = v;

  final settingController = Get.find<SettingController>();

  @override
  void onInit() {
    super.onInit();
    isZh = settingController.isLangZh;
  }

  void changeLang(bool isZhCN) async {
    isZh = isZhCN;
    const zh = Locale('zh', 'CN');
    const en = Locale('en', 'US');
    await Get.updateLocale(isZh ? zh : en);

    settingController.isLangZh = isZh;
    await settingController.save();
  }
}
