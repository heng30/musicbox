import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/searchbar.dart';
import '../widgets/nodata.dart';
import '../models/lyric_controller.dart';
import '../src/rust/api/lyric.dart';

class LyricPage extends StatefulWidget {
  const LyricPage({super.key});

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> {
  final TextEditingController _controllerSearch = TextEditingController();
  final FocusNode _focusNodeSearch = FocusNode();
  final lyricController = Get.find<SongLyricController>();

  Future<void> search(String text) async {
    if (text.isEmpty) {
      Get.snackbar("提 示".tr, "请输入内容".tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    _focusNodeSearch.unfocus();
    var items = await searchLyric(keyword: text.trim());

    if (items.isEmpty) {
      Get.snackbar("提 示".tr, "没有搜索到歌词".tr, snackPosition: SnackPosition.BOTTOM);
    }

    lyricController.lyricList.clear();
    lyricController.lyricList.addAll(items
        .map((item) => LyricListItem(
              raw: item,
              lyric: "",
            ))
        .toList());
  }

  Future<void> updateLyric(LyricListItem lyricItem) async {
    lyricItem.lyric = await getLyric(token: lyricItem.raw.token);
  }

  void _showDetailDialog(BuildContext context, LyricListItem lyricItem) async {
    if (lyricItem.lyric.isEmpty) {
      updateLyric(lyricItem);
    }

    Get.dialog(
      Dialog(
        child: Container(
          width: min(500, Get.width * 0.8),
          height: min(600, Get.height * 0.8),
          padding: const EdgeInsets.all(CTheme.margin * 4),
          decoration: BoxDecoration(
            color: CTheme.background,
            borderRadius: BorderRadius.circular(CTheme.borderRadius * 2),
          ),
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView(
              children: [
                Obx(
                  () => Text(lyricItem.lyric),
                ),

                // TODO
              ],
            ),
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
              controller: _controllerSearch,
              focusNode: _focusNodeSearch,
              hintText: "请输入关键字".tr,
              onSubmitted: (value) => search(value),
            ),
          ),
        ),
        const SizedBox(width: CTheme.margin * 4),
        GestureDetector(
          onTap: () => search(_controllerSearch.text),
          child: Text("搜索".tr, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return lyricController.lyricList.isNotEmpty
        ? Obx(
            () => Container(
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
                    onTap: () => _showDetailDialog(context, lyric),
                  );
                },
              ),
            ),
          )
        : NoData();
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
