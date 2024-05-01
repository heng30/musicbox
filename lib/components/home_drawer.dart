import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Icon(
                Icons.music_note,
                size: 40,
                color: CTheme.inversePrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 25.0, right: 25.0),
            child: ListTile(
              title: Text("主 页".tr),
              leading: const Icon(
                Icons.home,
              ),
              onTap: () => Get.back(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 0),
            child: ListTile(
              title: Text(
                "搜 索".tr,
              ),
              leading: const Icon(
                Icons.search,
              ),
              onTap: () => Get.offAndToNamed('/search'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 0),
            child: ListTile(
              title: Text(
                "设 置".tr,
              ),
              leading: const Icon(
                Icons.settings,
              ),
              onTap: () => Get.offAndToNamed('/settings'),
            ),
          ),
        ],
      ),
    );
  }
}
