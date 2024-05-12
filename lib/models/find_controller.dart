import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import "../models/albums.dart";
import "../src/rust/api/data.dart";
import "../models/setting_controller.dart";

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
  Stream<ProgressData>? progress;
  ProxyType? proxyType;
  String extention;
  String albumArtImagePath;

  final RxBool _isPlaying;
  bool get isPlaying => _isPlaying.value;
  set isPlaying(bool v) => _isPlaying.value = v;

  final Rx<DownloadState> _downloadState;
  DownloadState get downloadState => _downloadState.value;
  set downloadState(DownloadState v) => _downloadState.value = v;

  Info({
    required this.raw,
    this.proxyType,
    this.extention = "mp3",
    String? albumArtImagePath,
    bool isPlaying = false,
    DownloadState downloadState = DownloadState.undownload,
  })  : _isPlaying = isPlaying.obs,
        _downloadState = downloadState.obs,
        albumArtImagePath = albumArtImagePath ?? Albums.random();

  String? proxyUrl() {
    return Get.find<SettingController>().proxy.url(proxyType);
  }
}

class FindController {
  final infoList = <Info>[].obs;
  final log = Logger();
  late String downloadDir;

  Future<void> init() async {
    if (!kReleaseMode) fakeInfos();

    await makeDownloadDir();
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

  // TODO
  Future<void> makeDownloadDir() async {}

  String downloadPath(Info info) {
    return "$downloadDir/${info.raw.title}_${info.raw.author}.${info.extention}";
  }
}
