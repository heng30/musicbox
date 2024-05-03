import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../models/song.dart';
import '../models/playlist_controller.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  void clearPlaylistDialog() {
    Get.defaultDialog(
      title: "提 示".tr,
      middleText: '${"是否删除全部歌曲".tr}?',
      confirm: ElevatedButton(
        onPressed: () {
          Get.find<PlaylistController>().removeAll();
          Get.back();
        },
        child: Obx(
          () => Text("删除全部".tr, style: TextStyle(color: CTheme.inversePrimary)),
        ),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: Obx(
          () => Text("取消".tr, style: TextStyle(color: CTheme.inversePrimary)),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();

    return Obx(
      () => Container(
        color: CTheme.background,
        child: ListView.builder(
          itemCount: Get.find<PlaylistController>().playlist.length,
          itemBuilder: (count, index) {
            final song = playlistController.playlist[index];
            return ListTile(
              title: Text(song.songName),
              subtitle: Text(song.artistName),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(CTheme.borderRadius),
                child: Image.asset(song.albumArtImagePath),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => playlistController.remove(index),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("管 理".tr),
          backgroundColor: CTheme.background,
          actions: [
            IconButton(
              onPressed: () async {
                final songs = await Song.loadLocal();
                playlistController.add(songs);
              },
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: clearPlaylistDialog,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }
}
