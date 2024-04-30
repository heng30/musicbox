import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../components/neubox.dart';
import '../models/playlist_controller.dart';

class SongPage extends StatelessWidget {
  const SongPage({super.key, required this.songIndex});

  final int songIndex;

  Widget _buildBody(BuildContext context) {
    Get.find<PlaylistController>().currentSongIndex = songIndex;
    final song = Get.find<PlaylistController>().playlist[songIndex];

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeuBox(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CTheme.borderRadius),
              child: Column(
                children: [
                  Image.asset(
                    song.albumArtImagePath,
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
                            Text(
                              song.songName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              song.artistName,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Obx(
                          () => IconButton(
                            icon: const Icon(Icons.favorite),
                            color: song.isFavorite.value
                                ? Colors.red
                                : CTheme.secondary,
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
          ),

          // song duration progress
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: CTheme.padding * 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("00:00"),
                    IconButton(
                      icon: const Icon(Icons.shuffle),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.repeat),
                      onPressed: () {},
                    ),
                    const Text("00:00"),
                  ],
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 0)),
                child: Slider(
                  min: 0,
                  max: 100,
                  value: 50,
                  activeColor: Colors.green,
                  onChanged: (value) {},
                ),
              ),
              SizedBox(height: CTheme.padding * 2),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {},
                      child: const NeuBox(child: Icon(Icons.skip_previous)),
                    ),
                  ),
                  SizedBox(width: CTheme.padding * 5),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {},
                      child: const NeuBox(child: Icon(Icons.play_arrow)),
                    ),
                  ),
                  SizedBox(width: CTheme.padding * 5),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {},
                      child: const NeuBox(child: Icon(Icons.skip_next)),
                    ),
                  ),
                ],
              ),
            ],
          )
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
