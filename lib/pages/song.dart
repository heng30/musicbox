import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/controller.dart';
import '../widgets/neubox.dart';
import '../widgets/vslider.dart';
import '../widgets/track_shape.dart';
import '../models/playlist_controller.dart';
import '../models/util.dart';

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
  final currentSongIndex = Get.arguments["currentSongIndex"];

  @override
  void initState() {
    super.initState();

    if (playlistController.currentSongIndex != currentSongIndex) {
      playlistController.currentSongIndex = currentSongIndex;
    } else {
      if (!playlistController.isPlaying) {
        playlistController.resume();
      }
    }
  }

  Widget buildAlbum(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    Widget buildAlbumImage(BuildContext context) {
      return Obx(() {
        final song =
            playlistController.playlist[playlistController.currentSongIndex!];

        return Image.asset(
          song.albumArtImagePath,
          fit: BoxFit.cover,
        );
      });
    }

    return NeuBox(
      child: Column(
        children: [
          if (orientation == Orientation.portrait)
            ClipRRect(
              borderRadius: BorderRadius.circular(CTheme.borderRadius),
              child: buildAlbumImage(context),
            ),

          if (orientation == Orientation.landscape)
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(CTheme.borderRadius),
                  child: buildAlbumImage(context),
                ),
              ),
            ),

          // song artist name and icon
          Padding(
            padding: EdgeInsets.all(CTheme.padding * 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Obx(
                    () {
                      final song = playlistController
                          .playlist[playlistController.currentSongIndex!];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.songName,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            song.artistName ?? "",
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Obx(
                  () {
                    final song = playlistController
                        .playlist[playlistController.currentSongIndex!];

                    return IconButton(
                      icon: const Icon(Icons.favorite),
                      color:
                          song.isFavorite ? CTheme.favorite : CTheme.secondary,
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
            onTap: () => playlistController.playNextSong(),
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
    final windowSize = MediaQuery.of(context).size;
    return Center(
      child: SizedBox(
        width: isDesktopPlatform()
            ? min(windowSize.width, CTheme.windowWidth)
            : double.infinity,
        height: isDesktopPlatform()
            ? max(windowSize.height, CTheme.windowHeight)
            : double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: CTheme.padding * 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildAlbum(context),
              buildCtrl(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLandscapeLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(CTheme.padding * 5),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: buildAlbum(context),
          ),
          SizedBox(width: CTheme.padding * 5),
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
            IconButton(
              onPressed: () => Get.find<ThemeController>().toggleTheme(),
              icon: Icon(
                Get.find<ThemeController>().isDarkMode.value
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
