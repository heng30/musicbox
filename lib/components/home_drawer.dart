import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/theme.dart';
import '../models/player_tile_controller.dart';
import '../models/playlist_controller.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();
    final playerTileController = Get.find<PlayerTileController>();

    Widget buildHeader(BuildContext context) {
      return DrawerHeader(
        child: Center(
          child: Image.asset(
            CIcons.favicon,
            width: CTheme.faviconSize,
            height: CTheme.faviconSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    Widget buildBody(BuildContext context) {
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView(
          children: [
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
                Icons.view_list,
              ),
              onTap: () async {
                await Get.offAndToNamed('/manage');
                playerTileController.playingSong =
                    playlistController.playingSong();
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
            ListTile(
              title: Text(
                "关 于".tr,
              ),
              leading: const Icon(
                Icons.info,
              ),
              onTap: () => Get.offAndToNamed('/about'),
            ),
          ],
        ),
      );
    }

    Widget buildFooter(BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Get.offAndToNamed('/feedback'),
            icon: const Icon(
              IconFonts.send,
            ),
          ),
          SizedBox(width: CTheme.padding),
          IconButton(
            onPressed: () => Get.offAndToNamed('/donate'),
            icon: const Icon(
              IconFonts.donate,
            ),
          ),
          SizedBox(width: CTheme.padding),
          IconButton(
            onPressed: () async {
              final Uri url = Uri.parse('https://github.com/Heng30/musicbox');
              try {
                await launchUrl(url);
              } catch (e) {
                Get.snackbar("提 示".tr, '${"无法访问项目".tr}. $e');
              }
            },
            icon: const Icon(
              IconFonts.github,
            ),
          ),
        ],
      );
    }

    return Drawer(
      child: Padding(
        padding: EdgeInsets.only(
            left: CTheme.padding * 5, right: CTheme.padding * 5),
        child: Column(
          children: [
            buildHeader(context),
            Expanded(
              child: buildBody(context),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: CTheme.padding * 5),
              child: buildFooter(context),
            ),
          ],
        ),
      ),
    );
  }
}
