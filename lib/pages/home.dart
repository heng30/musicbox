import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../components/home_drawer.dart';
import '../theme/controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildBody(BuildContext context) {
    return Obx(
      () => Container(
        color: Get.find<ThemeController>().isDarkMode.value
            ? ThemeController.dark.colorScheme.background
            : ThemeController.light.colorScheme.background,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("播放列表".tr),
      ),
      drawer: const HomeDrawer(),
      body: _buildBody(context),
    );
  }
}
