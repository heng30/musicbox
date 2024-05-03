import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../models/player_controller.dart';
import '../models/playlist_controller.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();
    final playerController = Get.find<PlayerController>();

    return Drawer(
      child: Padding(
        padding: EdgeInsets.only(
            left: CTheme.padding * 5, right: CTheme.padding * 5),
        child: Column(
          children: [
            DrawerHeader(
              child: Center(
                child: Image.asset(
                  CIcons.favicon,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              title: Text("主 页".tr),
              leading: const Icon(Icons.home),
              onTap: () => Get.back(),
            ),
            ListTile(
              title: Text(
                "搜 索".tr,
              ),
              leading: const Icon(
                Icons.search,
              ),
              onTap: () => Get.offAndToNamed('/search'),
            ),
            ListTile(
              title: Text(
                "管 理".tr,
              ),
              leading: const Icon(
                Icons.manage_history_sharp,
              ),
              onTap: () async {
                await Get.offAndToNamed('/manage');
                playerController.playingSong = playlistController.playingSong();
              },
            ),
            ListTile(
              title: Text(
                "设 置".tr,
              ),
              leading: const Icon(
                Icons.settings,
              ),
              onTap: () => Get.offAndToNamed('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}
