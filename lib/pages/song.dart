import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mmoo_lyric/lyric_widget.dart';

import '../theme/theme.dart';
import '../theme/controller.dart';
import '../widgets/nodata.dart';
import '../widgets/neubox.dart';
import '../widgets/vslider.dart';
import '../widgets/track_shape.dart';
import '../models/lyric_controller.dart';
import '../models/player_controller.dart';
import '../models/playlist_controller.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${duration.inMinutes.toString()}:$twoDigitSeconds";
  }

  final playlistController = Get.find<PlaylistController>();
  final playerController = Get.find<PlayerController>();
  final songLyricController = Get.find<SongLyricController>();
  final currentSongIndex = Get.arguments["currentSongIndex"];

  @override
  void initState() {
    super.initState();

    if (playlistController.currentSongIndex != currentSongIndex) {
      playlistController.currentSongIndex = currentSongIndex;
    } else {
      if (!playerController.isPlaying) {
        playerController.resume();
      }
    }
  }

  void updateSpeed(double speed) {
    playerController.speed = speed;
    Get.back();
  }

  void selectSpeedRate() {
    Get.bottomSheet(
      Container(
        height: 350,
        width: double.infinity,
        decoration: BoxDecoration(
          color: CTheme.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(CTheme.borderRadius),
            topRight: Radius.circular(CTheme.borderRadius),
          ),
        ),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            children: [2.0, 1.75, 1.5, 1.25, 1.0, 0.75, 0.5]
                .map(
                  (item) => SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ListTile(
                      title: Text(item.toString(), textAlign: TextAlign.center),
                      onTap: () => updateSpeed(item),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget buildLyric(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final song =
        playlistController.playlist[playlistController.currentSongIndex!];
    song.updateLyrics();

    return GestureDetector(
      onTap: () {
        songLyricController.isShow = !songLyricController.isShow;
        songLyricController.updateController();
      },
      child: Padding(
        padding: const EdgeInsets.all(CTheme.padding * 5),
        child: !songLyricController.isForceUpdateLyricWidget
            ? song.lyrics.isNotEmpty
                ? LyricWidget(
                    enableDrag: false,
                    lyrics: song.lyrics,
                    size: const Size(double.infinity, double.infinity),
                    controller: songLyricController.controller,
                    currLyricStyle: TextStyle(
                        color: CTheme.secondaryBrand,
                        fontSize: Get.textTheme.titleMedium?.fontSize ?? 16),
                  )
                : Center(
                    child: NoData(
                      text: "没有歌词".tr,
                      size: orientation == Orientation.portrait
                          ? null
                          : Get.height * 0.2,
                    ),
                  )
            : const SizedBox(
                width: double.infinity,
                height: double.infinity,
              ),
      ),
    );
  }

  Widget buildAlbum(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final song =
        playlistController.playlist[playlistController.currentSongIndex!];

    return NeuBox(
      child: Column(
        children: [
          if (orientation == Orientation.portrait)
            ClipRRect(
              borderRadius: BorderRadius.circular(CTheme.borderRadius),
              child: GestureDetector(
                child: SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    song.albumArtImagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: () {
                  songLyricController.isShow = !songLyricController.isShow;
                  songLyricController.updateController();
                },
              ),
            ),
          if (orientation == Orientation.landscape)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CTheme.borderRadius),
                child: GestureDetector(
                  child: SizedBox(
                    child: Image.asset(
                      song.albumArtImagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                  onTap: () {
                    songLyricController.isShow = !songLyricController.isShow;
                    songLyricController.updateController();
                  },
                ),
              ),
            ),
          Obx(
            () => ListTile(
              contentPadding: const EdgeInsets.all(0),
              title: Text(
                song.songName,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                song.artistName,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite),
                color: song.isFavorite ? CTheme.favorite : CTheme.secondary,
                onPressed: () {
                  Get.find<PlaylistController>()
                      .toggleFavorite(playlistController.currentSongIndex);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSongInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CTheme.padding * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            alignment: Alignment.centerLeft,
            child: Obx(
              () => Text(formatTime(playerController.currentDuration)),
            ),
          ),
          Obx(
            () => IconButton(
              icon: playerController.playModel == PlayModel.loop
                  ? const Icon(Icons.repeat)
                  : (playerController.playModel == PlayModel.shuffle
                      ? const Icon(Icons.shuffle)
                      : const Icon(Icons.loop)),
              onPressed: () {
                playerController.playModelNext();
              },
            ),
          ),
          Obx(
            () => IconButton(
              icon: playerController.isMute
                  ? const Icon(Icons.volume_mute)
                  : const Icon(Icons.volume_down_rounded),
              onPressed: () {
                playerController.syncVolumn();
                showVSliderDialog(
                  context,
                  initValue: playerController.volume * 100,
                  onChanged: (value) {
                    playerController.setVolumn(value / 100.0);
                  },
                );
              },
            ),
          ),
          TextButton(
            onPressed: selectSpeedRate,
            child: Obx(
              () => Text("${playerController.speed}x",
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          Container(
            width: 50,
            alignment: Alignment.centerRight,
            child: Obx(
              () => Text(formatTime(playerController.totalDuration)),
            ),
          )
        ],
      ),
    );
  }

  Widget buildCtrlBar(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
        trackShape: CustomTrackShape(horizontalPadding: CTheme.padding * 2),
      ),
      child: Obx(
        () => Slider(
          min: 0,
          max: playerController.totalDuration.inSeconds.toDouble(),
          value: playerController.currentDuration.inSeconds.toDouble(),
          activeColor: CTheme.aduioProcessBar,
          inactiveColor: CTheme.secondary,
          onChanged: (_) {},
          onChangeEnd: (value) {
            playerController.seek(Duration(seconds: value.toInt()));
          },
        ),
      ),
    );
  }

  Widget buildCtrlBtns(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: playerController.playPreviousSong,
            child: const NeuBox(child: Icon(Icons.skip_previous)),
          ),
        ),
        const SizedBox(width: CTheme.padding * 5),
        Obx(
          () => Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: playerController.pauseOrResume,
              child: NeuBox(
                child: Icon(playerController.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow),
              ),
            ),
          ),
        ),
        const SizedBox(width: CTheme.padding * 5),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () => playerController.playNextSong(),
            child: const NeuBox(child: Icon(Icons.skip_next)),
          ),
        ),
      ],
    );
  }

  Widget buildCtrl(BuildContext context) {
    return Column(
      children: [
        // song duration and play model
        buildSongInfo(context),

        // progress bar
        buildCtrlBar(context),

        // control buttons
        buildCtrlBtns(context),
      ],
    );
  }

  Widget buildPortraitLayout(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CTheme.padding * 5),
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!songLyricController.isForceUpdateLyricWidget &&
                  !songLyricController.isShow)
                buildAlbum(context),
              if (songLyricController.isForceUpdateLyricWidget ||
                  songLyricController.isShow)
                Expanded(
                  child: buildLyric(context),
                ),
              buildCtrl(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLandscapeLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CTheme.padding * 5),
      child: Obx(
        () => Row(
          children: [
            if (!songLyricController.isForceUpdateLyricWidget &&
                !songLyricController.isShow)
              Expanded(
                flex: 1,
                child: buildAlbum(context),
              ),
            if (songLyricController.isForceUpdateLyricWidget ||
                songLyricController.isShow)
              Expanded(
                flex: 1,
                child: buildLyric(context),
              ),
            const SizedBox(width: CTheme.padding * 5),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildCtrl(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return buildPortraitLayout(context);
        } else {
          return buildLandscapeLayout(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: CTheme.background,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: CTheme.background,
          title: Text("歌 曲".tr),
          actions: [
            if (songLyricController.isShow)
              IconButton(
                onPressed: () async {
                  final downloadPath = await songLyricController.downloadPath();

                  if (downloadPath.isEmpty) {
                    Get.snackbar("提 示".tr, "下载目录为空",
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }

                  Get.toNamed("/lyric", arguments: {
                    "downloadPath": downloadPath,
                    "currentSongIndex": playlistController.currentSongIndex!
                  });
                },
                icon: const Icon(Icons.search),
              ),
            IconButton(
              onPressed: () {
                Get.find<ThemeController>().toggleTheme();
              },
              icon: Icon(
                Get.find<ThemeController>().isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }
}
