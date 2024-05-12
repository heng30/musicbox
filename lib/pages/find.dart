import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/nodata.dart';
import '../widgets/searchbar.dart';
import '../models/find_controller.dart';
import '../models/setting_controller.dart';
import '../src/rust/api/youtube.dart';

class FindPage extends StatefulWidget {
  const FindPage({super.key});

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  final findController = Get.find<FindController>();
  final settingController = Get.find<SettingController>();
  final TextEditingController controllerSearch = TextEditingController();
  final FocusNode focusNodeSearch = FocusNode();

  Future<void> searchYoutube(String text) async {
    final proxyUrl = settingController.proxy.url(ProxyType.youtube);
    final ids =
        await fetchIds(keyword: text, maxIdCount: 10, proxyUrl: proxyUrl);
    for (String id in ids) {
      try {
        final vinfo = await videoInfoById(id: id, proxyUrl: proxyUrl);
        findController.infoList.add(Info(
          raw: vinfo,
          proxyType: ProxyType.youtube,
          extention: "mp4",
        ));
      } catch (e) {
        Get.snackbar("提 示".tr, "获取音频信息失败".tr,
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void search(String text) async {
    if (text.isEmpty) {
      Get.snackbar("提 示".tr, "请输入内容".tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    findController.infoList.clear();
    try {
      await searchYoutube(text);
    } catch (e) {
      Get.snackbar("提 示".tr, "搜索失败".tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.snackbar("提 示".tr, "搜索完成".tr, snackPosition: SnackPosition.BOTTOM);
  }

  // TODO
  void playOrPauseOnlineSong(Info info) {
    info.isPlaying = !info.isPlaying;
    if (info.isPlaying) {}
  }

  Future<void> downlaodYoutube(Info info) async {
    info.progress = downloadVideoByIdWithCallback(
      id: info.raw.videoId,
      downloadPath: findController.downloadPath(info),
      proxyUrl: info.proxyUrl(),
    );
  }

  Future<void> startDownload(Info info) async {
    info.downloadState = DownloadState.downloading;

    try {
      await downlaodYoutube(info);
    } catch (e) {
      info.downloadState = DownloadState.failed;
      Get.snackbar("下载失败".tr, e.toString());
    }
  }

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

  Widget buildListTile(BuildContext context, int index) {
    final info = findController.infoList[index];
    return ListTile(
      title: Text(
        info.raw.title,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        info.raw.author,
        overflow: TextOverflow.ellipsis,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(CTheme.borderRadius),
        child: Image.asset(info.albumArtImagePath),
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
              // IconButton(
              //   icon: Icon(
              //     info.isPlaying ? Icons.pause : Icons.play_arrow,
              //   ),
              //   onPressed: () => playOrPauseOnlineSong(info),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoList(BuildContext context) {
    return Obx(
      () => Container(
        color: CTheme.background,
        child: ListView.builder(
          itemCount: findController.infoList.length,
          itemBuilder: (count, index) {
            return buildListTile(context, index);
          },
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return findController.infoList.isNotEmpty
        ? buildInfoList(context)
        : const NoData();
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
