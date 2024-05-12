import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  Widget _buildBodyPlaylist(BuildContext context) {
    return Obx(
      () => Container(
        color: CTheme.background,
        child: ListView.builder(
          itemCount: playlistController.playlist.length,
          itemBuilder: (count, index) {
            final song = playlistController.playlist[index];
            return ListTile(
              title: Text(song.songName),
              subtitle: Text(song.artistName),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(CTheme.borderRadius),
                child: Image.asset(song.albumArtImagePath),
              ),
              trailing: Obx(
                () => IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: song.isFavorite ? CTheme.favorite : CTheme.secondary,
                  ),
                  onPressed: () {
                    playlistController.toggleFavorite(index);
                  },
                ),
              ),
              onTap: () => go2song(index),
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
            title: Text(song.songName),
            subtitle: Text(song.artistName),
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
              : const NoData(),
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
