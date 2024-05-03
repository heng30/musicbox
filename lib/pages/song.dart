import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/neubox.dart';
import '../widgets/vslider.dart';
import '../widgets/track_shape.dart';
import '../models/playlist_controller.dart';
import '../models/util.dart';

class SongPage extends StatelessWidget {
  const SongPage({super.key});

  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${duration.inMinutes.toString()}:$twoDigitSeconds";
  }

  Widget _buildBody(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();
    final currentSongIndex = Get.arguments["currentSongIndex"];

    if (playlistController.currentSongIndex != currentSongIndex) {
      playlistController.currentSongIndex = currentSongIndex;
      playlistController.play();
    } else {
      if (!playlistController.isPlaying) {
        playlistController.resume();
      }
    }

    Widget buildAlbum(BuildContext context) {
      return NeuBox(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(CTheme.borderRadius),
              child: Obx(() {
                final song = playlistController
                    .playlist[playlistController.currentSongIndex!];

                return Image.asset(
                  song.albumArtImagePath,
                );
              }),
            ),

            // song artist name and icon
            Padding(
              padding: EdgeInsets.all(CTheme.padding * 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () {
                          final song = playlistController
                              .playlist[playlistController.currentSongIndex!];

                          return Text(
                            song.songName,
                            style: Theme.of(context).textTheme.titleLarge,
                          );
                        },
                      ),
                      Obx(
                        () {
                          final song = playlistController
                              .playlist[playlistController.currentSongIndex!];

                          return Text(
                            song.artistName,
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        },
                      ),
                    ],
                  ),
                  Obx(
                    () {
                      final song = playlistController
                          .playlist[playlistController.currentSongIndex!];

                      return IconButton(
                        icon: const Icon(Icons.favorite),
                        color: song.isFavorite
                            ? CTheme.favorite
                            : CTheme.secondary,
                        onPressed: () {
                          Get.find<PlaylistController>().toggleFavorite(
                              playlistController.currentSongIndex);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget buildSongInfo(BuildContext context) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: CTheme.padding * 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 50,
              alignment: Alignment.centerLeft,
              child: Obx(
                () => Text(formatTime(playlistController.currentDuration)),
              ),
            ),
            Obx(
              () => IconButton(
                icon: playlistController.playModel == PlayModel.loop
                    ? const Icon(Icons.repeat)
                    : (playlistController.playModel == PlayModel.shuffle
                        ? const Icon(Icons.shuffle)
                        : const Icon(Icons.loop)),
                onPressed: () {
                  playlistController.playModelNext();
                },
              ),
            ),
            Obx(
              () => IconButton(
                icon: playlistController.isMute
                    ? const Icon(Icons.volume_mute)
                    : const Icon(Icons.volume_down_rounded),
                onPressed: () {
                  playlistController.syncVolumn();
                  showVSliderDialog(
                    context,
                    initValue: playlistController.volume * 100,
                    onChanged: (value) {
                      playlistController.setVolumn(value / 100.0);
                    },
                  );
                },
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.centerRight,
              child: Obx(
                () => Text(formatTime(playlistController.totalDuration)),
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
            max: playlistController.totalDuration.inSeconds.toDouble(),
            value: playlistController.currentDuration.inSeconds.toDouble(),
            activeColor: CTheme.aduioProcessBar,
            inactiveColor: CTheme.secondary,
            onChanged: (value) {},
            onChangeEnd: (value) {
              playlistController.seek(Duration(seconds: value.toInt()));
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
              onTap: playlistController.playPreviousSong,
              child: const NeuBox(child: Icon(Icons.skip_previous)),
            ),
          ),
          SizedBox(width: CTheme.padding * 5),
          Obx(
            () => Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: playlistController.pauseOrResume,
                child: NeuBox(
                  child: Icon(playlistController.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow),
                ),
              ),
            ),
          ),
          SizedBox(width: CTheme.padding * 5),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: playlistController.playNextSong,
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

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildAlbum(context),
          buildCtrl(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: CTheme.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: CTheme.background,
        title: Text("歌 曲".tr),
      ),
      body: Center(
        child: SizedBox(
          width: isDesktopPlatform()
              ? min(windowSize.width, CTheme.windowWidth)
              : double.infinity,
          height: isDesktopPlatform()
              ? max(windowSize.height, CTheme.windowHeight)
              : double.infinity,
          child: _buildBody(context),
        ),
      ),
    );
  }
}
