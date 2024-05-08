import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
  final GlobalKey<AnimatedListState> animatedListGlobalKey =
      GlobalKey<AnimatedListState>(
          debugLabel: "manage page listview debug label");

  void _clearPlaylistDialog() {
    Get.defaultDialog(
      title: "提 示".tr,
      middleText: '${"是否删除全部歌曲".tr}?',
      confirm: ElevatedButton(
        onPressed: () {
          playlistController.removeAll();
          Get.back();
          Get.snackbar("提 示".tr, "已经删除全部歌曲".tr);
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

  Widget _buildAnimationListTile(int index) {
    final song = playlistController.playlist[index];
    return ListTile(
      title: Text(song.songName),
      subtitle: song.artistName != null ? Text(song.artistName!) : null,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(CTheme.borderRadius),
        child: Image.asset(song.albumArtImagePath),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          if (index >= playlistController.playlist.length) {
            return;
          }

          var item = _buildAnimationListTile(index);

          animatedListGlobalKey.currentState!.removeItem(
            index,
            (context, animation) {
              return ScaleTransition(
                scale: animation,
                child: item,
              );
            },
          );

          playlistController.remove(index);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return playlistController.playlist.isNotEmpty
        ? Obx(
            () => Container(
              color: CTheme.background,
              child: AnimatedList(
                initialItemCount: playlistController.playlist.length,
                key: animatedListGlobalKey,
                itemBuilder: (context, index, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: _buildAnimationListTile(index),
                  );
                },
              ),
            ),
          )
        : const NoData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
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
