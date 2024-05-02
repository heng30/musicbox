import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../components/home_drawer.dart';
import '../models/playlist_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildBody(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();

    return Obx(
      () => Container(
        color: CTheme.background,
        child: ListView.builder(
          itemCount: Get.find<PlaylistController>().playlist.length,
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
                    color: song.isFavorite ? Colors.red : CTheme.secondary,
                  ),
                  onPressed: () {
                    Get.find<PlaylistController>().toggleFavorite(index);
                  },
                ),
              ),
              onTap: () =>
                  Get.toNamed("/song", arguments: {"currentSongIndex": index}),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("播放列表".tr),
          backgroundColor: CTheme.background,
          actions: [
            IconButton(
              onPressed: () => Get.toNamed("/search"),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        drawer: const HomeDrawer(),
        body: _buildBody(context),
      ),
    );
  }
}
