import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';
import '../widgets/nodata.dart';
import '../models/playlist_controller.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final playlistController = Get.find<PlaylistController>();

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
                    onPressed: () =>
                        playlistController.clearPlaylistOneSongDialog(index),
                  ),
                ],
              ),
            )
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () =>
                  playlistController.clearPlaylistOneSongDialog(index),
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
              onPressed: playlistController.clearPlaylistDialog,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }
}
