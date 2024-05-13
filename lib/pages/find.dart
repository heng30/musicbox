import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

import '../models/util.dart';
import '../models/albums.dart';
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

  final FocusNode focusNodeSearch = FocusNode();
  final TextEditingController controllerSearch = TextEditingController();
  final log = Logger();

  Future<void> searchYoutube(String text) async {
    final proxyUrl = settingController.proxy.url(ProxyType.youtube);
    final ids =
        await fetchIds(keyword: text, maxIdCount: 10, proxyUrl: proxyUrl);

    var tmpList = <Info>[];

    for (String id in ids) {
      try {
        final vinfo = await videoInfoById(id: id, proxyUrl: proxyUrl);
        final info = Info(
          raw: vinfo,
          extention: "mp4",
          proxyType: ProxyType.youtube,
          albumArtImagePath: Albums.youtubeAsset,
        );

        // song duration too short or too long would be ignored
        if (vinfo.lengthSeconds < 90 || vinfo.lengthSeconds > 600) {
          tmpList.add(info);
        } else {
          findController.infoList.add(info);
        }
      } catch (e) {
        Get.snackbar("提 示".tr, "获取音频信息失败".tr,
            snackPosition: SnackPosition.BOTTOM);
      }
    }

    if (findController.infoList.length < 5) {
      findController.infoList.addAll(tmpList);
    }
  }

  // TODO
  Future<void> searchBilibili(String text) async {}

  void search(String text) async {
    if (text.isEmpty) {
      Get.snackbar("提 示".tr, "请输入内容".tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    int searchErrorCount = 0;
    findController.infoList.clear();
    try {
      await searchYoutube(text);
    } catch (e) {
      searchErrorCount++;
    }

    try {
      await searchBilibili(text);
    } catch (e) {
      searchErrorCount++;
    }

    if (searchErrorCount == 2) {
      Get.snackbar("提 示".tr, "搜索失败".tr, snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("提 示".tr, "搜索完成".tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> downlaodYoutube(Info info) async {
    final progressStream = downloadVideoByIdWithCallback(
      id: info.raw.videoId,
      downloadPath: await findController.downloadPath(info),
      proxyUrl: info.proxyUrl(),
    );

    info.setProgressStreamWithListen(progressStream, info);
  }

  // TODO
  Future<void> downlaodBilibili(Info info) async {
    // final progressStream = downloadVideoByIdWithCallback(
    //   id: info.raw.videoId,
    //   downloadPath: await findController.downloadPath(info),
    //   proxyUrl: info.proxyUrl(),
    // );

    // info.setProgressStreamWithListen(progressStream, info);
  }

  Future<void> startDownload(Info info) async {
    if (info.downloadState == DownloadState.downloading) {
      Get.snackbar("提 示".tr, "已经在下载，请耐心等待".tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    info.downloadState = DownloadState.downloading;

    try {
      if (info.proxyType == ProxyType.youtube) {
        await downlaodYoutube(info);
      } else if (info.proxyType == ProxyType.bilibili) {
        await downlaodBilibili(info);
      }
    } catch (e) {
      info.downloadState = DownloadState.failed;
      Get.snackbar("下载失败".tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
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
              autofocus: findController.infoList.isEmpty,
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

  Widget buildDownload(BuildContext context, Info info) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (info.downloadState != DownloadState.undownload)
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.only(
                        right: CTheme.padding * 2, bottom: CTheme.padding),
                    child: Text("${info.downloadRate.toStringAsFixed(0)}%"),
                  ),
                ),
              Text(
                formattedTime(info.raw.lengthSeconds),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          IconButton(
            icon: Icon(downloadStateIcon(info.downloadState)),
            onPressed: () => startDownload(info),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(BuildContext context, int index) {
    final info = findController.infoList[index];
    return ListTile(
      contentPadding: const EdgeInsets.only(left: CTheme.padding * 2),
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
      trailing: SizedBox(
        width: 100,
        child: buildDownload(context, info),
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
