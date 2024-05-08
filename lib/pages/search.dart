import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/searchbar.dart';
import '../widgets/nodata.dart';
import '../models/playlist_controller.dart';
import '../models/player_tile_controller.dart';
import '../models/song.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controllerSearch = TextEditingController();
  final FocusNode _focusNodeSearch = FocusNode();
  final playlistController = Get.find<PlaylistController>();
  final playerTileController = Get.find<PlayerTileController>();

  final songs = <Song>[].obs;

  void go2song(int index) async {
    await Get.offAndToNamed("/song", arguments: {"currentSongIndex": index});
    playerTileController.playingSong = playlistController.playingSong();
  }

  void search(String text) {
    var items = playlistController.searchByKeyword(text.trim());

    if (items.isEmpty) {
      Get.snackbar("提 示".tr, "没有搜索到歌曲".tr, snackPosition: SnackPosition.BOTTOM);
    }

    songs.value = items;
  }

  Widget _buildTitle(BuildContext context) {
    const searchHeight = 34.0;
    return Row(
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: searchHeight),
            child: CSearchBar(
              height: searchHeight,
              controller: _controllerSearch,
              focusNode: _focusNodeSearch,
              hintText: "请输入关键字".tr,
              onSubmitted: (value) => search(value),
            ),
          ),
        ),
        SizedBox(width: CTheme.margin * 4),
        GestureDetector(
          onTap: () => search(_controllerSearch.text),
          child: Text("搜索".tr, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return playlistController.playlist.isNotEmpty
        ? Obx(
            () => Container(
              color: CTheme.background,
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (count, index) {
                  final song = songs[index];
                  return ListTile(
                    title: Text(song.songName),
                    subtitle: Text(song.artistName ?? ""),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(CTheme.borderRadius),
                      child: Image.asset(song.albumArtImagePath),
                    ),
                    onTap: () {
                      var realIndex =
                          playlistController.findByName(song.songName);

                      if (realIndex != null) {
                        go2song(realIndex);
                      }
                    },
                  );
                },
              ),
            ),
          )
        : const NoData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: CTheme.background,
          centerTitle: true,
          title: _buildTitle(context),
        ),
        body: _buildBody(context),
      ),
    );
  }
}
