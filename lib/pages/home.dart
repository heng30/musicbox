import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../components/home_drawer.dart';
import '../models/playlist_controller.dart';
import '../pages/song.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void goToSongPage(int songIndex) {
    Get.to(SongPage(songIndex: songIndex));
  }

  Widget _buildBody(BuildContext context) {
    return Obx(
      () => Container(
        color: CTheme.background,
        child: ListView.builder(
            itemCount: Get.find<PlaylistController>().playlist.length,
            itemBuilder: (count, index) {
              final song = Get.find<PlaylistController>().playlist[index];
              return ListTile(
                title: Text(song.songName),
                subtitle: Text(song.artistName),
                leading: Image.asset(song.albumArtImagePath),
                onTap: () => goToSongPage(index),
              );
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("播放列表".tr),
      ),
      drawer: const HomeDrawer(),
      body: _buildBody(context),
    );
  }
}
