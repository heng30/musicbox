import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import "../models/albums.dart";
import '../widgets/nodata.dart';
import '../widgets/searchbar.dart';
import '../models/find_controller.dart';

class FindPage extends StatefulWidget {
  const FindPage({super.key});

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  final findController = Get.find<FindController>();
  final TextEditingController controllerSearch = TextEditingController();
  final FocusNode focusNodeSearch = FocusNode();

  void search(String text) {
    // var items = playlistController.searchByKeyword(text.trim());

    // if (items.isEmpty) {
    //   Get.snackbar("提 示".tr, "没有搜索到歌曲".tr, snackPosition: SnackPosition.BOTTOM);
    // }

    // songs.value = items;
  }

  void playOrPauseOnlineSong(Info info) {
    info.isPlaying = !info.isPlaying;

    if (info.isPlaying) {
      // TODO
    }
  }

  void startDownload(Info info) {}

  Widget buildTitle(BuildContext context) {
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

  Widget buildBody(BuildContext context) {
    return Obx(
      () => Container(
        color: CTheme.background,
        child: ListView.builder(
          itemCount: findController.infoList.length,
          itemBuilder: (count, index) {
            final info = findController.infoList[index];
            return ListTile(
              title: Text(info.raw.title),
              subtitle: Text(info.raw.author),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(CTheme.borderRadius),
                child: Image.asset(Albums.random()),
              ),
              trailing: Obx(
                () => SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(downloadStateIcon(info.downloadState)),
                        onPressed: () => startDownload(info),
                      ),
                      IconButton(
                        icon: Icon(
                          info.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: () => playOrPauseOnlineSong(info),
                      ),
                    ],
                  ),
                ),
              ),
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
        backgroundColor: CTheme.background,
        appBar: AppBar(
          title: buildTitle(context),
          centerTitle: true,
          backgroundColor: CTheme.background,
        ),
        body: buildBody(context),
      ),
    );
  }
}
