import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class SettingFindPage extends StatefulWidget {
  const SettingFindPage({super.key});

  @override
  State<SettingFindPage> createState() => _SettingFindPageState();
}

class _SettingFindPageState extends State<SettingFindPage> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: CTheme.background,
        appBar: AppBar(
          backgroundColor: CTheme.background,
          title: Text("发 现".tr),
          centerTitle: true,
        ),
      ),
    );
  }
}
