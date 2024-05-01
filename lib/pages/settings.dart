import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../lang/controller.dart';
import '../theme/controller.dart';
import '../theme/theme.dart';
import '../components/setting_switch.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _buildBody(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView(
        children: [
          const SizedBox(height: 25),
          SettingSwitch(
            title: '黑暗模式'.tr,
            isOn: Get.find<ThemeController>().isDarkMode.value,
            onChanged: (value) {
              Get.find<ThemeController>().changeTheme(value);
            },
          ),
          const SizedBox(height: 25),
          SettingSwitch(
            title: '语言切换'.tr,
            isOn: Get.find<LangController>().isZh.value,
            onChanged: (value) {
              Get.find<LangController>().changeLang(value);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: CTheme.background,
        appBar: AppBar(
          centerTitle: true,
          title: Text("设 置".tr),
          backgroundColor: CTheme.background,
        ),
        body: _buildBody(context),
      ),
    );
  }
}
