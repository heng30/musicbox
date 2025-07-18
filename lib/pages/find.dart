import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../models/util.dart';
import '../models/albums.dart';
import '../theme/theme.dart';
import '../widgets/nodata.dart';
import '../widgets/searchbar.dart';
import '../models/find_controller.dart';
import '../models/setting_controller.dart';
import '../src/rust/api/bilibili.dart' as bilibili;

class FindPage extends StatefulWidget {
  const FindPage({super.key});

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  final findController = Get.find<FindController>();
  final settingController = Get.find<SettingController>();

  // no need to dispose
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  final FocusNode focusNodeSearch = FocusNode();
  final TextEditingController controllerSearch = TextEditingController();
  final log = Logger();

  void onRefresh() async {
    findController.retainDownloadingInfo();
    refreshController.refreshCompleted();
  }

  Future<void> searchBilibili(String text) async {
    final ids = await bilibili.bvFetchIds(
      keyword: text,
      maxIdCount: BigInt.from(max(1, settingController.find.searchCount)),
    );

    for (String id in ids) {
      if (!findController.isSearching) {
        return;
      }

      try {
        final vinfo = await bilibili.bvVideoInfo(bvid: id);
        final info = Info(
          raw: vinfo,
          extention: "m4s",
          albumArtImagePath: Albums.bilibiliAsset,
        );

        // song duration too short or too long would be ignored
        if (vinfo.lengthSeconds <
                BigInt.from(max(1, settingController.find.minSecondLength)) ||
            vinfo.lengthSeconds >
                BigInt.from(max(5, settingController.find.maxSecondLength))) {
          continue;
        }

        findController.infoList.add(info);
      } catch (e) {
        log.d(e);
      }
    }
  }

  void search(String text) async {
    focusNodeSearch.unfocus();
    if (!settingController.find.enableBilibiliSearch) {
      Get.snackbar("提 示".tr, "没有启用Bilibili搜索".tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (findController.isSearching) {
      Get.snackbar("提 示".tr, "正在搜索...".tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (text.trim().isEmpty) {
      findController.retainDownloadingInfo();
      Get.snackbar("提 示".tr, "请输入内容".tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    int searchErrorCount = 0;
    int targetSearchErrorCount = 1;
    findController.retainDownloadingInfo();
    findController.isSearching = true;

    if (settingController.find.enableBilibiliSearch) {
      try {
        await searchBilibili(text);
      } catch (e) {
        Get.snackbar("搜索Bilibili失败".tr, e.toString(),
            snackPosition: SnackPosition.BOTTOM);
        searchErrorCount++;
      }
    } else {
      targetSearchErrorCount++;
    }

    if (searchErrorCount != targetSearchErrorCount) {
      Get.snackbar("提 示".tr, "搜索完成".tr, snackPosition: SnackPosition.BOTTOM);
    }

    findController.isSearching = false;
  }

  Future<void> downlaodBilibili(Info info) async {
    final progressStream = bilibili.bvDownloadVideoByIdWithCallback(
      id: info.raw.videoId,
      cid: info.raw.bvCid,
      downloadPath: await findController.downloadPath(info),
    );

    info.setProgressStreamWithListen(progressStream, info);
  }

  Future<void> innerDownload(Info info) async {
    info.startDownloadTime = DateTime.now();
    info.downloadState = DownloadState.downloading;

    try {
      await downlaodBilibili(info);
    } catch (e) {
      log.d(e);
    }
  }

  void showCoverExistFileDialog(Function onConfirm) {
    Get.defaultDialog(
      title: "提 示".tr,
      middleText: '${"文件已存在，是否覆盖".tr}?',
      confirm: ElevatedButton(
        onPressed: () {
          Get.closeAllSnackbars();
          Get.back();
          onConfirm();
        },
        child: Obx(
          () => Text(
            "确定".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: Obx(
          () => Text(
            "取消".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
    );
  }

  Future<void> startDownload(Info info) async {
    if (info.downloadState == DownloadState.downloading) {
      Get.snackbar("提 示".tr, "已经在下载，请耐心等待".tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (info.downloadState == DownloadState.downloaded) {
      Get.snackbar("提 示".tr, "请勿重复下载".tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (await File(await findController.downloadPath(info)).exists()) {
      showCoverExistFileDialog(() async {
        Get.snackbar("提 示".tr, "${'开始下载'.tr} ${info.raw.title}".tr,
            snackPosition: SnackPosition.BOTTOM);

        await innerDownload(info);
      });
    } else {
      Get.snackbar("提 示".tr, "${'开始下载'.tr} ${info.raw.title}".tr,
          snackPosition: SnackPosition.BOTTOM);

      await innerDownload(info);
    }
  }

  Future<void> downloadAgain(Info info) async {
    Get.snackbar("提 示".tr, "${'重新下载'.tr} ${info.raw.title}".tr,
        snackPosition: SnackPosition.BOTTOM);

    await cancelDownload(info);

    try {
      await innerDownload(info);
    } catch (e) {
      Get.snackbar("重新下载失败".tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> cancelDownload(Info info) async {
    info.downloadState = DownloadState.undownload;
    info.cnacelProgressStreamSubscription();
    await info.removeDownloadFailedFile();
  }

  void showDownloadOptionsDialog(BuildContext context, Info info) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(CTheme.padding * 2),
          decoration: BoxDecoration(
            color: CTheme.background,
            borderRadius: BorderRadius.circular(CTheme.blurRadius),
          ),
          height: 116,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child: InkWell(
                  onTap: () async {
                    Get.closeAllSnackbars();
                    Get.back();
                    await downloadAgain(info);
                  },
                  child: Center(
                    child: Text(
                      "重新下载".tr,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: InkWell(
                  onTap: () async {
                    Get.closeAllSnackbars();
                    Get.back();
                    await cancelDownload(info);
                  },
                  child: Center(
                    child: Text(
                      "取消下载".tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showDetailDialog(BuildContext context, Info info) {
    final settingController = Get.find<SettingController>();
    final labelWidth = settingController.isLangZh ? 50.0 : 80.0;

    Get.dialog(
      Dialog(
        child: Container(
          width: double.infinity,
          height: min(350, MediaQuery.of(context).size.height * 0.8),
          padding: const EdgeInsets.all(CTheme.margin * 4),
          decoration: BoxDecoration(
            color: CTheme.background,
            borderRadius: BorderRadius.circular(CTheme.borderRadius * 2),
          ),
          child: ListView(
            children: [
              if (info.raw.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: CTheme.padding * 2, top: CTheme.padding * 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text("标题".tr,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Uri url = Uri.parse(bilibili.bvWatchUrl(id: info.raw.videoId));
                            try {
                              await launchUrl(url);
                            } catch (e) {
                              Get.snackbar("提 示".tr, e.toString());
                            }
                          },
                          child: Text(
                            info.raw.title,
                            style: TextStyle(
                              color: CTheme.link,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (info.raw.author.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: CTheme.padding * 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text("作者".tr,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Expanded(
                        child: Text(info.raw.author),
                      ),
                    ],
                  ),
                ),
              if (info.raw.lengthSeconds > BigInt.from(0))
                Padding(
                  padding: const EdgeInsets.only(bottom: CTheme.padding * 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text("时长".tr,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Expanded(
                        child: Text(formattedTime(info.raw.lengthSeconds.toInt())),
                      ),
                    ],
                  ),
                ),
              if (info.raw.viewCount > BigInt.from(0))
                Padding(
                  padding: const EdgeInsets.only(bottom: CTheme.padding * 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text("次数".tr,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Expanded(
                        child: Text(formattedNumber(info.raw.viewCount.toInt())),
                      ),
                    ],
                  ),
                ),
              if (info.raw.shortDescription.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(CTheme.padding * 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(info.raw.shortDescription),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
          onTap: () {
            if (!findController.isSearching) {
              search(controllerSearch.text);
            } else {
              findController.isSearching = false;
            }
          },
          child: Obx(
            () => Text(!findController.isSearching ? "搜索".tr : "停止".tr,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ),
      ],
    );
  }

  Widget buildDownload(BuildContext context, Info info) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            formattedTime(info.raw.lengthSeconds.toInt()),
            overflow: TextOverflow.ellipsis,
          ),
          if (info.downloadState == DownloadState.downloading ||
              info.downloadState == DownloadState.downloaded)
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: CTheme.padding * 2),
              child: InkWell(
                hoverColor: Colors.transparent,
                onTap: () {
                  if (info.downloadState == DownloadState.downloading) {
                    showDownloadOptionsDialog(context, info);
                  }
                },
                child: CircularPercentIndicator(
                  radius: 15,
                  lineWidth: 3,
                  percent: info.downloadRate / 100,
                  center: Text(
                    info.downloadRate.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                  ),
                  progressColor: info.downloadState == DownloadState.downloaded
                      ? Colors.green
                      : CTheme.secondaryBrand,
                  backgroundColor: CTheme.primary,
                ),
              ),
            ),
          if (info.downloadState == DownloadState.undownload)
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
      onTap: () => showDetailDialog(context, info),
    );
  }

  Widget buildInfoList(BuildContext context) {
    return Obx(
      () => SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(complete: Text("刷新完成".tr)),
        controller: refreshController,
        onRefresh: onRefresh,
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
    final size = MediaQuery.of(context).size;

    return findController.infoList.isNotEmpty
        ? buildInfoList(context)
        : (findController.isSearching
            ? SpinKitWave(
                color: CTheme.secondaryBrand,
                size: size.width * 0.2,
              )
            : NoData());
  }

  @override
  Widget build(BuildContext context) {
    findController.createDownloadDir();

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
