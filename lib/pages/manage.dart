import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';
import '../models/playlist_controller.dart';
import '../widgets/nodata.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final playlistController = Get.find<PlaylistController>();

  void _clearPlaylistDialog() {
    Get.defaultDialog(
      title: "提 示".tr,
      middleText: '${"是否删除全部歌曲".tr}?',
      confirm: ElevatedButton(
        onPressed: () {
          Get.closeAllSnackbars();
          Get.back();
          playlistController.removeAll();
          Get.snackbar("提 示".tr, "已经删除全部歌曲".tr,
              snackPosition: SnackPosition.BOTTOM);
        },
        child: Obx(
          () => Text(
            "删除全部".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: Obx(
          () => Text(
            "取消".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
    );
  }

  void _clearPlaylistOneSongDialog(int index) {
    Get.defaultDialog(
      title: "提 示".tr,
      middleText: '${"是否删除歌曲".tr}?',
      confirm: ElevatedButton(
        onPressed: () {
          Get.closeAllSnackbars();
          Get.back();
          playlistController.remove(index);
          Get.snackbar("提 示".tr, "已经删除歌曲".tr,
              snackPosition: SnackPosition.BOTTOM);
        },
        child: Obx(
          () => Text(
            "删除歌曲".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: Obx(
          () => Text(
            "取消".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, int index) {
    final song = playlistController.playlist[index];
    return Obx(
      () => song.isSelected
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    CImages.lineVoice,
                    width: CTheme.iconSize,
                    height: CTheme.iconSize,
                    colorFilter: ColorFilter.mode(
                      CTheme.secondaryBrand,
                      BlendMode.srcIn,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _clearPlaylistOneSongDialog(index),
                  ),
                ],
              ),
            )
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _clearPlaylistOneSongDialog(index),
            ),
    );
  }

  Widget _buildListTile(int index) {
    final song = playlistController.playlist[index];
    return ListTile(
      contentPadding: const EdgeInsets.only(left: CTheme.padding * 2),
      title: Text(
        song.songName,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artistName,
        overflow: TextOverflow.ellipsis,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(CTheme.borderRadius),
        child: Image.asset(song.albumArtImagePath),
      ),
      trailing: _buildTrailing(context, index),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() => playlistController.playlist.isNotEmpty
        ? Obx(
            () => ListView.builder(
              itemCount: playlistController.playlist.length,
              itemBuilder: (context, index) {
                return _buildListTile(index);
              },
            ),
          )
        : const NoData());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: CTheme.background,
        appBar: AppBar(
          centerTitle: true,
          title: Text("管 理".tr),
          backgroundColor: CTheme.background,
          actions: [
            IconButton(
              onPressed: () async {
                final songs = await PlaylistController.loadLocal();
                playlistController.add(songs);
              },
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: _clearPlaylistDialog,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }
}
