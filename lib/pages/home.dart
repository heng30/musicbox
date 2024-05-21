import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../theme/theme.dart';
import '../widgets/nodata.dart';
import '../components/home_drawer.dart';
import '../models/player_controller.dart';
import '../models/playlist_controller.dart';
import '../models/player_tile_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? currentBackPressTime;
  final playlistController = Get.find<PlaylistController>();
  final playerController = Get.find<PlayerController>();
  final playerTileController = Get.find<PlayerTileController>();

  void go2song(int index) async {
    await Get.toNamed("/song", arguments: {"currentSongIndex": index});
    playerTileController.playingSong = playlistController.playingSong();
    playlistController.updateSelectedSong();
  }

  bool closeOnConfirmed() {
    const exitDuration = Duration(seconds: 3);
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > exitDuration) {
      currentBackPressTime = now;
      Get.snackbar("提 示".tr, "再返回一次退出程序".tr, duration: exitDuration);

      return false;
    }

    currentBackPressTime = null;
    return true;
  }

  Widget buildTrailing(BuildContext context, int index) {
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
                    icon: Icon(
                      Icons.favorite,
                      color:
                          song.isFavorite ? CTheme.favorite : CTheme.secondary,
                    ),
                    onPressed: () {
                      playlistController.toggleFavorite(index);
                    },
                  ),
                ],
              ),
            )
          : IconButton(
              icon: Icon(
                Icons.favorite,
                color: song.isFavorite ? CTheme.favorite : CTheme.secondary,
              ),
              onPressed: () {
                playlistController.toggleFavorite(index);
              },
            ),
    );
  }

  Widget _buildBodyPlaylist(BuildContext context) {
    return Obx(
      () => Container(
        color: CTheme.background,
        child: ListView.builder(
          itemCount: playlistController.playlist.length,
          itemBuilder: (count, index) {
            final song = playlistController.playlist[index];
            return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    backgroundColor: CTheme.secondary,
                    foregroundColor: Colors.red,
                    icon: Icons.delete_outline,
                    label: '删除'.tr,
                    onPressed: (_) =>
                        playlistController.clearPlaylistOneSongDialog(index),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: CTheme.padding * 2),
                onTap: () => go2song(index),
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
                trailing: buildTrailing(context, index),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomPlayer(BuildContext context) {
    final song = playerTileController.playingSong;

    return Obx(
      () => Container(
        color: CTheme.bottomPlayerBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: CTheme.padding),
          child: ListTile(
            contentPadding: const EdgeInsets.only(
                left: CTheme.padding * 2, right: CTheme.padding * 4),
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
            trailing: IconButton(
              icon: playerController.isPlaying
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
              onPressed: playerController.pauseOrResume,
            ),
            onTap: () {
              if (playlistController.isValidCurrentSongIndex) {
                go2song(playlistController.currentSongIndex!);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: playlistController.playlist.isNotEmpty
              ? _buildBodyPlaylist(context)
              : NoData(),
        ),
        _buildBottomPlayer(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Obx(
        () => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("播放列表".tr),
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
                onPressed: () => Get.toNamed("/search"),
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          drawer: const HomeDrawer(),
          body: _buildBody(context),
        ),
      ),
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (closeOnConfirmed()) {
          SystemNavigator.pop();
        }
      },
    );
  }
}
