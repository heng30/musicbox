import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:mmoo_lyric/lyric_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/util.dart';
import '../src/rust/api/lyric.dart';
import "../models/setting_controller.dart";
import '../models/playlist_controller.dart';

class LyricListItem {
  final SearchLyricItem raw;

  final Rx<String> _lyric;
  String get lyric => _lyric.value;
  set lyric(String v) => _lyric.value = v;

  final RxBool _isDownloading;
  bool get isDownloading => _isDownloading.value;
  set isDownloading(bool v) => _isDownloading.value = v;

  LyricListItem(
      {required this.raw, required String lyric, bool isDownloading = false})
      : _lyric = lyric.obs,
        _isDownloading = isDownloading.obs;
}

class SongLyricController extends GetxController {
  final lyricList = <LyricListItem>[].obs;
  final log = Logger();

  final Rx<LyricController> _controller = LyricController().obs;
  LyricController get controller => _controller.value;
  set controller(v) => _controller.value = v;

  final _isShow = false.obs;
  bool get isShow => _isShow.value;
  set isShow(bool v) => _isShow.value = v;

  final _isForceUpdateLyricWidget = false.obs;
  bool get isForceUpdateLyricWidget => _isForceUpdateLyricWidget.value;
  set isForceUpdateLyricWidget(bool v) => _isForceUpdateLyricWidget.value = v;

  String? downloadDir;

  SongLyricController() {
    if (!kReleaseMode) {
      fakeLyricList();
    }
  }

  void fakeLyricList() {
    for (int i = 0; i < 2; i++) {
      lyricList.add(
        LyricListItem(
          raw: SearchLyricItem(
            name: "name-$i",
            authors: "authors-$i",
            token: "token-$i",
          ),
          lyric: testSongLyric,
        ),
      );
    }
  }

  void updateController() {
    controller.dispose();
    controller = LyricController();
  }

  void updateControllerWithForceUpdateLyricWidget() async {
    if (isShow) {
      updateController();
      isForceUpdateLyricWidget = true;
      isShow = false;
      await Future.delayed(const Duration(milliseconds: 10));
      isShow = true;
      isForceUpdateLyricWidget = false;
    }
  }

  void forceUpdateLyricWidget() async {
    if (isShow) {
      isForceUpdateLyricWidget = true;
      isShow = false;
      await Future.delayed(const Duration(milliseconds: 10));
      isShow = true;
      isForceUpdateLyricWidget = false;
    }
  }

  Future<void> migrateLyric() async {
    if (downloadDir == null) {
      await createDownloadDir();
    }

    final playlistController = Get.find<PlaylistController>();
    final newName = basenameWithoutExtension(playlistController
        .playlist[playlistController.currentSongIndex!].audioPath);
    final oldName = newName.split("_");

    if (oldName.isNotEmpty) {
      final oldPath = "$downloadDir/${oldName[0]}.lrc";
      final newPath = "$downloadDir/$newName.lrc";
      final file = File(oldPath);

      try {
        if (await file.exists()) {
          log.d("$oldPath -> $newPath");
          await file.rename(newPath);
        }
      } catch (e) {
        log.d("rename error: $e");
      }
    }
  }

  Future<String> downloadPath() async {
    if (downloadDir == null) {
      await createDownloadDir();
    }

    final playlistController = Get.find<PlaylistController>();
    final name = basenameWithoutExtension(playlistController
        .playlist[playlistController.currentSongIndex!].audioPath);

    if (downloadDir == null || name.isEmpty) {
      return "";
    }

    return "$downloadDir/$name.lrc";
  }

  Future<String> getDownloadsDirectoryWithoutCreate() async {
    final pname = (await PackageInfo.fromPlatform()).packageName;
    return "/storage/emulated/0/$pname/lyric";
  }

  Future<void> createDownloadDir() async {
    try {
      if (!(await getPermission())) {
        return;
      }

      final pname = (await PackageInfo.fromPlatform()).packageName;
      final d = Directory("/storage/emulated/0/$pname/lyric");

      if (!(await d.exists())) {
        await d.create(recursive: true);
      }

      downloadDir = d.path;
    } catch (e) {
      if (Get.find<SettingController>().isFirstLaunch) {
        log.d("Create lyric download directory failed. $e");
      } else {
        Get.snackbar("创建下载目录失败".tr, e.toString(),
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }
}

const testSongLyric =
    "[00:00.000] 作曲 : Maynard Plant/Blaise Plant/菊池拓哉 \n[00:00.226] 作词 : Maynard Plant/Blaise Plant/菊池拓哉\n[00:00.680]明日を照らすよSunshine\n[00:03.570]窓から射し込む…扉開いて\n[00:20.920]Stop!'cause you got me thinking\n[00:22.360]that I'm a little quicker\n[00:23.520]Go!Maybe the rhythm's off,\n[00:25.100]but I will never let you\n[00:26.280]Know!I wish that you could see it for yourself.\n[00:28.560]It's not,it's not,just stop,hey y'all!やだ!\n[00:30.930]I never thought that I would take over it all.\n[00:33.420]And now I know that there's no way I could fall.\n[00:35.970]You know it's on and on and off and on,\n[00:38.210]And no one gets away.\n[00:40.300]僕の夢は何処に在るのか?\n[00:45.100]影も形も見えなくて\n[00:50.200]追いかけていた守るべきもの\n[00:54.860]There's a sunshine in my mind\n[01:02.400]明日を照らすよSunshineどこまでも続く\n[01:07.340]目の前に広がるヒカリの先へ\n[01:12.870]未来の\n[01:15.420]輝く\n[01:18.100]You know it's hard,just take a chance.\n[01:19.670]信じて\n[01:21.289]明日も晴れるかな?\n[01:32.960]ほんの些細なことに何度も躊躇ったり\n[01:37.830]誰かのその言葉いつも気にして\n[01:42.850]そんな弱い僕でも「いつか必ずきっと!」\n[01:47.800]強がり?それも負け惜しみ?\n[01:51.940]僕の夢は何だったのか\n[01:56.720]大事なことも忘れて\n[02:01.680]目の前にある守るべきもの\n[02:06.640]There's a sunshine in my mind\n[02:14.500]明日を照らすよSunshineどこまでも続く\n[02:19.000]目の前に広がるヒカリの先へ\n[02:24.670]未来のSunshine\n[02:27.200]輝くSunshine\n[02:29.900]You know it's hard,just take a chance.\n[02:31.420]信じて\n[02:33.300]明日も晴れるかな?\n[02:47.200]Rain's got me now\n[03:05.650]I guess I'm waiting for that Sunshine\n[03:09.200]Why's It only shine in my mind\n[03:15.960]I guess I'm waiting for that Sunshine\n[03:19.110]Why's It only shine in my mind\n[03:25.970]明日を照らすよSunshineどこまでも続く\n[03:30.690]目の前に広がるヒカリの先へ\n[03:36.400]未来のSunshine\n[03:38.840]輝くSunshine\n[03:41.520]You know it's hard,just take a chance.\n[03:43.200]信じて\n[03:44.829]明日も晴れるかな?\n";
