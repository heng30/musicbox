import 'dart:io';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import "../models/song.dart";
import "../models/albums.dart";
import "../src/rust/api/data.dart";
import "../models/setting_controller.dart";
import '../models/playlist_controller.dart';

enum DownloadState {
  undownload,
  downloading,
  downloaded,
  failed,
}

IconData downloadStateIcon(DownloadState state) {
  switch (state) {
    case DownloadState.undownload:
      return Icons.download;
    case DownloadState.downloading:
      return Icons.downloading;
    case DownloadState.downloaded:
      return Icons.download_done;
    case DownloadState.failed:
      return Icons.error_outline;
  }
}

class Info {
  final InfoData raw;
  ProxyType proxyType;
  String extention;
  String albumArtImagePath;

  final RxBool _isPlaying;
  bool get isPlaying => _isPlaying.value;
  set isPlaying(bool v) => _isPlaying.value = v;

  final Rx<DownloadState> _downloadState;
  DownloadState get downloadState => _downloadState.value;
  set downloadState(DownloadState v) => _downloadState.value = v;

  final RxDouble _downloadRate = 0.0.obs;
  double get downloadRate => _downloadRate.value;
  set downloadRate(double v) => _downloadRate.value = v;

  DateTime? startDownloadTime;
  bool _isTimeout() {
    if (startDownloadTime == null) {
      return true;
    }

    if (downloadState != DownloadState.downloading) {
      return true;
    }

    // timeout
    if (downloadRate > 0) {
      return DateTime.now().difference(startDownloadTime!).inSeconds > 600;
    }

    return DateTime.now().difference(startDownloadTime!).inSeconds > 60;
  }

  Stream<ProgressData>? _progressStream;
  void setProgressStreamWithListen(Stream<ProgressData> stream, Info info) {
    _progressStream = stream;

    _progressStream!.listen(
      (value) {
        if (value.totalSize != null && value.totalSize! > 0) {
          info.downloadRate = value.currentSize * 100 / value.totalSize!;
        }
      },
      onDone: () async {
        final findController = Get.find<FindController>();
        final filepath = await findController.downloadPath(info);

        if (!File(filepath).existsSync()) {
          info.downloadState = DownloadState.failed;
          return;
        }

        info.downloadState = DownloadState.downloaded;
        Get.snackbar("下载成功".tr, filepath, snackPosition: SnackPosition.BOTTOM);

        final playlistController = Get.find<PlaylistController>();
        playlistController.add([await Song.fromInfo(info)]);
      },
      onError: (e) {
        info.downloadState = DownloadState.failed;
      },
    );
  }

  Info({
    required this.raw,
    this.proxyType = ProxyType.youtube,
    this.extention = "mp3",
    String? albumArtImagePath,
    bool isPlaying = false,
    DownloadState downloadState = DownloadState.undownload,
  })  : _isPlaying = isPlaying.obs,
        _downloadState = downloadState.obs,
        albumArtImagePath = albumArtImagePath ?? Albums.youtubeAsset;

  String? proxyUrl() {
    return Get.find<SettingController>().proxy.url(proxyType);
  }
}

class FindController extends GetxController {
  final infoList = <Info>[].obs;
  final log = Logger();
  String? downloadDir;

  final _isSearching = false.obs;
  bool get isSearching => _isSearching.value;
  set isSearching(bool v) => _isSearching.value = v;

  FindController() {
    if (!kReleaseMode) {
      fakeInfos();
    }
  }

  void fakeInfos() {
    for (int i = 0; i < 2; i++) {
      infoList.add(
        Info(
          raw: InfoData(
            title: "title-$i",
            author: "author-$i",
            videoId: "vdMTIe5ihYg",
            shortDescription: "shortDescription-$i",
            viewCount: 100,
            lengthSeconds: 320,
          ),
        ),
      );
    }
  }

  void retainDownloadingInfo() {
    final l = infoList.where((info) => !info._isTimeout()).toList();

    infoList.clear();
    infoList.addAll(l);
  }

  Future<void> _makeDownloadDir() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();

      if (!statuses[Permission.manageExternalStorage]!.isGranted) {
        Get.snackbar("提 示".tr, "请赋予管理外部存储权限，否则无法保存下载文件".tr,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final pname = (await PackageInfo.fromPlatform()).packageName;
      final d = Directory("/storage/emulated/0/$pname");

      if (!(await d.exists())) {
        await d.create();
      }

      downloadDir = d.path;
    } else {
      final d =
          await getDownloadsDirectory() ?? await getApplicationCacheDirectory();

      if (!(await d.exists())) {
        await d.create();
      }

      downloadDir = d.path;
    }

    log.d("download dir: $downloadDir");
  }

  Future<String> downloadPath(Info info) async {
    if (downloadDir == null) {
      try {
        await _makeDownloadDir();
      } catch (e) {
        Get.snackbar("创建下载目录失败".tr, e.toString(),
            snackPosition: SnackPosition.BOTTOM);
      }
    }

    return "$downloadDir/${info.raw.title}_${info.raw.author}.${info.extention}";
  }

  Future<bool> isInDownloadDir(String path) async {
    if (downloadDir == null) {
      await _makeDownloadDir();
    }

    final pname = (await PackageInfo.fromPlatform()).packageName;
    return path.contains(pname);
  }
}
