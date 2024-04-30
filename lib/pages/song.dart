import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/neubox.dart';
import '../models/playlist_controller.dart';

class SongPage extends StatelessWidget {
  const SongPage({super.key, required this.songIndex});

  final int songIndex;

  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String formattedTime = "${duration.inMinutes.toString()}:$twoDigitSeconds";
    return formattedTime;
  }

  Widget _buildBody(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();
    playlistController.currentSongIndex = songIndex;
    final song = playlistController.playlist[songIndex];

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeuBox(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(CTheme.borderRadius),
                  child: Obx(
                    () => Image.asset(
                      song.albumArtImagePath,
                    ),
                  ),
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
                            () => Text(
                              song.songName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Obx(
                            () => Text(
                              song.artistName,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => IconButton(
                          icon: const Icon(Icons.favorite),
                          color:
                              song.isFavorite ? Colors.red : CTheme.secondary,
                          onPressed: () {
                            Get.find<PlaylistController>().toggleFavorite();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // song duration progress
          Obx(
            () => Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CTheme.padding * 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(playlistController.currentDuration)),
                      IconButton(
                        icon: const Icon(Icons.shuffle),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.repeat),
                        onPressed: () {},
                      ),
                      Text(formatTime(playlistController.totalDuration)),
                    ],
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 0)),
                  child: Slider(
                    min: 0,
                    max: playlistController.totalDuration.inSeconds.toDouble(),
                    value:
                        playlistController.currentDuration.inSeconds.toDouble(),
                    activeColor: Colors.green,
                    onChanged: (value) {
                      // playlistController.seek(Duration(seconds: value.toInt()));
                    },
                    onChangeEnd: (value) {
                      playlistController.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                // play button
                SizedBox(height: CTheme.padding * 2),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: playlistController.playPreviousSong,
                        child: const NeuBox(child: Icon(Icons.skip_previous)),
                      ),
                    ),
                    SizedBox(width: CTheme.padding * 5),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: playlistController.pauseOrResume,
                        child: NeuBox(
                            child: Icon(playlistController.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow)),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CTheme.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: CTheme.background,
        title: Text("歌 曲".tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          )
        ],
      ),
      body: _buildBody(context),
    );
  }
}
