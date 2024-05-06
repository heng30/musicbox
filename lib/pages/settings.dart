import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/controller.dart';
import '../lang/controller.dart';
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
            title: '主题切换'.tr,
            isOn: Get.find<ThemeController>().isDarkMode,
            icon: Get.find<ThemeController>().isDarkMode
                ? Icons.dark_mode
                : Icons.light_mode,
            onChanged: Get.find<ThemeController>().changeTheme,
          ),
          const SizedBox(height: 25),
          SettingSwitch(
            title: '语言切换'.tr,
            isOn: Get.find<LangController>().isZh,
            icon: Icons.translate,
            onChanged: Get.find<LangController>().changeLang,
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
