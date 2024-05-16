import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import "../models/util.dart";
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
  bool _isUnlistInfo() {
    if (startDownloadTime == null ||
        downloadState != DownloadState.downloading) {
      return true;
    }

    // partial downloading timeout
    if (downloadRate > 0) {
      final isTimeout =
          DateTime.now().difference(startDownloadTime!).inSeconds > 600;

      if (isTimeout) {
        removeDownloadFailedFile();
      }
      return isTimeout;
    }

    return DateTime.now().difference(startDownloadTime!).inSeconds > 60;
  }

  Stream<ProgressData>? _progressStream;
  StreamSubscription<ProgressData>? _progressStreamSubscription;

  void cnacelProgressStreamSubscription() {
    if (_progressStreamSubscription != null) {
      _progressStreamSubscription!.cancel();
    }
  }

  void setProgressStreamWithListen(Stream<ProgressData> stream, Info info) {
    final findController = Get.find<FindController>();

    cnacelProgressStreamSubscription();

    _progressStream = stream;
    _progressStreamSubscription = _progressStream!.listen(
      (value) {
        if (value.totalSize != null && value.totalSize! > 0) {
          info.downloadRate = value.currentSize * 100 / value.totalSize!;
        }
      },
      onDone: () async {
        final settingController = Get.find<SettingController>();
        final playlistController = Get.find<PlaylistController>();
        final filepath = await findController.downloadPath(info);

        if (!(await File(filepath).exists())) {
          info.downloadState = DownloadState.failed;
          return;
        }

        info.downloadState = DownloadState.downloaded;

        if (settingController.find.enableVideoToAudio) {
          try {
            await convertVideoToAudio(info);
          } catch (e) {
            Logger().d(e);
            playlistController.add([await Song.fromInfo(info)]);
          }
        } else {
          Get.snackbar("下载成功".tr, filepath,
              snackPosition: SnackPosition.BOTTOM);
          playlistController.add([await Song.fromInfo(info)]);
        }
      },
      onError: (e) async {
        info.downloadState = DownloadState.failed;
        await removeDownloadFailedFile();
      },
    );
  }

  Future<void> removeDownloadFailedFile() async {
    final findController = Get.find<FindController>();
    final filepath = await findController.downloadPath(this);

    if (await File(filepath).exists()) {
      await File(filepath).delete();
    }
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
    final l = infoList.where((info) => !info._isUnlistInfo()).toList();

    infoList.clear();
    infoList.addAll(l);
  }

  Future<void> createDownloadDir() async {
    try {
      if (Platform.isAndroid) {
        final androidVersion = await DeviceInfoPlugin().androidInfo;
        if (androidVersion.version.sdkInt >= 30) {
          await Permission.manageExternalStorage.request();
          if (!(await Permission.manageExternalStorage.isGranted)) {
            Get.snackbar("提 示".tr, "请赋予管理外部存储权限，否则无法保存下载文件".tr,
                snackPosition: SnackPosition.BOTTOM);
            return;
          }
        } else {
          await Permission.storage.request();
          if (!(await Permission.storage.isGranted)) {
            Get.snackbar("提 示".tr, "请赋予管理外部存储权限，否则无法保存下载文件".tr,
                snackPosition: SnackPosition.BOTTOM);
            return;
          }
        }

        final pname = (await PackageInfo.fromPlatform()).packageName;
        final d = Directory("/storage/emulated/0/$pname");

        if (!(await d.exists())) {
          await d.create();
        }

        downloadDir = d.path;
      } else {
        final d = await getDownloadsDirectory() ??
            await getApplicationCacheDirectory();

        if (!(await d.exists())) {
          await d.create();
        }

        downloadDir = d.path;
      }
    } catch (e) {
      Get.snackbar("创建下载目录失败".tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<String> downloadPath(Info info) async {
    if (downloadDir == null) {
      await createDownloadDir();
    }

    return "$downloadDir/${info.raw.title}_${info.raw.author}.${info.extention}";
  }

  Future<bool> isInDownloadDir(String path) async {
    if (downloadDir == null) {
      await createDownloadDir();
    }

    final pname = (await PackageInfo.fromPlatform()).packageName;
    return path.contains(pname);
  }
}

// TODO
Future<void> convertVideoToAudio(Info info) async {
  if (!isFFmpegKitSupportPlatform()) {
    return;
  }

  final findController = Get.find<FindController>();
  final mp4Path = await findController.downloadPath(info);
  final mp3Path = "${path.withoutExtension(mp4Path)}.mp3";

  Get.snackbar("开始转换".tr, "$mp4Path -> $mp3Path",
      snackPosition: SnackPosition.BOTTOM);
}
