import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../theme/theme.dart';
import '../widgets/searchbar.dart';
import '../widgets/nodata.dart';
import '../models/lyric_controller.dart';
import '../models/player_controller.dart';
import '../models/playlist_controller.dart';
import '../src/rust/api/lyric.dart';

class LyricPage extends StatefulWidget {
  const LyricPage({super.key});

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> {
  final TextEditingController controllerSearch = TextEditingController();
  final FocusNode focusNodeSearch = FocusNode();
  final lyricController = Get.find<SongLyricController>();
  final playerController = Get.find<PlayerController>();
  final playlistController = Get.find<PlaylistController>();
  final isSearching = false.obs;

  final downloadPath = Get.arguments["downloadPath"] as String;
  final currentSongIndex = Get.arguments["currentSongIndex"] as int;

  @override
  void initState() {
    super.initState();
    controllerSearch.text = playlistController.playingSong().songName;
  }

  Future<void> search(String text) async {
    lyricController.lyricList.clear();

    if (text.isEmpty) {
      Get.snackbar("提 示".tr, "请输入内容".tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    focusNodeSearch.unfocus();

    isSearching.value = true;
    var items = await searchLyric(keyword: text.trim());
    isSearching.value = false;

    if (items.isEmpty) {
      Get.snackbar("提 示".tr, "没有搜索到歌词".tr, snackPosition: SnackPosition.BOTTOM);
    }

    lyricController.lyricList.addAll(items
        .map((item) => LyricListItem(
              raw: item,
              lyric: "",
            ))
        .toList());
  }

  Future<void> updateLyric(LyricListItem lyricItem) async {
    if (lyricItem.isDownloading) {
      return;
    }

    lyricItem.isDownloading = true;
    lyricItem.lyric = await getLyric(token: lyricItem.raw.token);
    lyricItem.isDownloading = false;
  }

  void downloadLyric(String text) async {
    if (downloadPath.isEmpty) {
      return;
    }

    Get.back();

    try {
      await saveLyric(text: text, path: downloadPath);
      await playerController.setLyric(currentSongIndex);

      Get.snackbar("下载成功".tr, downloadPath,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("下载失败".tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showDetailDialog(BuildContext context, LyricListItem lyricItem) async {
    if (lyricItem.lyric.isEmpty) {
      updateLyric(lyricItem);
    }

    final width = min(500.0, Get.width * 0.8);
    final height = min(600.0, Get.height * 0.8);

    Get.dialog(
      Dialog(
        child: Obx(
          () => Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(CTheme.margin * 4),
            decoration: BoxDecoration(
              color: CTheme.background,
              borderRadius: BorderRadius.circular(CTheme.borderRadius * 2),
            ),
            child: lyricItem.isDownloading
                ? Center(
                    child: SpinKitWave(
                      color: CTheme.secondaryBrand,
                      size: min(100, width * 0.2),
                    ),
                  )
                : (lyricItem.lyric.isNotEmpty
                    ? Column(
                        children: [
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: ListView(
                                children: [
                                  Obx(
                                    () => Text(lyricItem.lyric),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: CTheme.padding * 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => downloadLyric(lyricItem.lyric),
                                child: Text(
                                  "下载歌词".tr,
                                  style:
                                      TextStyle(color: CTheme.secondaryBrand),
                                ),
                              ),
                              const SizedBox(width: CTheme.padding * 5),
                              ElevatedButton(
                                onPressed: () => Get.back(),
                                child: Obx(
                                  () => Text(
                                    "取消".tr,
                                    style:
                                        TextStyle(color: CTheme.inversePrimary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: CTheme.padding * 2),
                            ],
                          )
                        ],
                      )
                    : NoData()),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            constraints:
                const BoxConstraints(maxHeight: CTheme.searchBarHeight),
            child: CSearchBar(
              height: CTheme.searchBarHeight,
              controller: controllerSearch,
              focusNode: focusNodeSearch,
              autofocus: lyricController.lyricList.isEmpty,
              hintText: "请输入关键字".tr,
              onSubmitted: (value) => search(value),
            ),
          ),
        ),
        const SizedBox(width: CTheme.margin * 4),
        GestureDetector(
          onTap: () => search(controllerSearch.text),
          child: Text("搜索".tr, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(
      () => lyricController.lyricList.isNotEmpty
          ? Container(
              color: CTheme.background,
              child: ListView.builder(
                itemCount: lyricController.lyricList.length,
                itemBuilder: (count, index) {
                  final lyric = lyricController.lyricList[index];
                  return ListTile(
                      title: Text(
                        lyric.raw.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        lyric.raw.authors,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        _showDetailDialog(context, lyric);
                      });
                },
              ),
            )
          : (isSearching.value
              ? Center(
                  child: SpinKitWave(
                    color: CTheme.secondaryBrand,
                    size: min(100, Get.width * 0.2),
                  ),
                )
              : NoData()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: CTheme.background,
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
