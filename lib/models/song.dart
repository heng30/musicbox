import 'dart:convert';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:mmoo_lyric/lyric.dart';
import 'package:mmoo_lyric/lyric_util.dart';

import './albums.dart';
import './db_controller.dart';
import '../models/find_controller.dart';

enum AudioLocation {
  asset,
  local,
  remote,
  memory,
}

enum LyricUpdateType {
  forward,
  backword,
  reset,
}

AudioLocation audioLocationFromStr(String v) {
  if (v == "AudioLocation.asset") {
    return AudioLocation.asset;
  } else if (v == "AudioLocation.local") {
    return AudioLocation.local;
  } else if (v == "AudioLocation.remote") {
    return AudioLocation.remote;
  } else {
    return AudioLocation.memory;
  }
}

class Song {
  static const String noneAsset = "audio/none.mp3";

  String uuid;
  String songName;
  String artistName;
  String albumArtImagePath;
  String audioPath;
  int lyricTimeOffset;
  AudioLocation audioLocation;

  final log = Logger();

  final RxBool _isFavorite;
  bool get isFavorite => _isFavorite.value;
  set isFavorite(bool v) => _isFavorite.value = v;

  final _isSelected = false.obs;
  bool get isSelected => _isSelected.value;
  set isSelected(bool v) => _isSelected.value = v;

  final _lyric = "".obs;
  String get lyric => _lyric.value;
  set lyric(String v) {
    _lyric.value = v;
    updateLyrics();
  }

  final lyrics = <Lyric>[].obs;
  void updateLyrics() {
    lyrics.clear();
    try {
      final items = LyricUtil.formatLyric(lyric);
      if (lyricTimeOffset != 0) {
        final tmpLyrics = items.map(
          (item) {
            var startTime = item.startTime!.inMilliseconds + lyricTimeOffset;
            var endTime = item.endTime!.inMilliseconds + lyricTimeOffset;

            if (startTime < 0) startTime = 0;
            if (endTime < 0) endTime = 0;

            item.startTime = Duration(milliseconds: startTime);
            item.endTime = Duration(milliseconds: endTime);

            return item;
          },
        ).toList();

        lyrics.addAll(tmpLyrics);
      } else {
        lyrics.addAll(items);
      }
    } catch (e) {
      log.d("parse lyric error: $e");
    }
  }

  Song.none({
    this.uuid = "uuid-none",
    this.songName = "None",
    this.lyricTimeOffset = 0,
    this.artistName = "",
    this.albumArtImagePath = Albums.noneAsset,
    this.audioPath = noneAsset,
    this.audioLocation = AudioLocation.asset,
  }) : _isFavorite = false.obs;

  Song({
    required this.songName,
    required this.artistName,
    required this.albumArtImagePath,
    required this.audioPath,
    this.audioLocation = AudioLocation.local,
    this.lyricTimeOffset = 0,
    String? uuid,
    bool isFavorite = false,
  })  : _isFavorite = isFavorite.obs,
        uuid = uuid ?? const Uuid().v4();

  Song copy() {
    final song = Song(
      uuid: uuid,
      songName: songName,
      artistName: artistName,
      albumArtImagePath: albumArtImagePath,
      audioPath: audioPath,
      audioLocation: audioLocation,
      isFavorite: isFavorite,
      lyricTimeOffset: lyricTimeOffset,
    );
    song.lyric = lyric;
    song.isSelected = isSelected;

    return song;
  }

  static Future<Song> fromInfo(Info info) async {
    final findController = Get.find<FindController>();
    return Song(
      songName: info.raw.title,
      artistName: info.raw.author,
      albumArtImagePath: Albums.random(),
      audioPath: await findController.downloadPath(info),
    );
  }

  Song.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        songName = json['songName'],
        artistName = json['artistName'] ?? "",
        albumArtImagePath = Albums.random(),
        audioPath = json['audioPath'],
        audioLocation = audioLocationFromStr(json['audioLocation']),
        lyricTimeOffset = (json['lyricTimeOffset'] ?? 0) as int,
        _isFavorite = (json['isFavorite'] as bool).obs;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'uuid': uuid,
      'songName': songName,
      'artistName': artistName,
      'audioPath': audioPath,
      'audioLocation': audioLocation.toString(),
      'isFavorite': isFavorite,
      'lyricTimeOffset': lyricTimeOffset,
    };
    return data;
  }

  Future<void> updateLyricTimeOffset(LyricUpdateType updateType) async {
    if (lyrics.isEmpty) {
      Get.snackbar("提 示".tr, "没有歌词，无法进行调整".tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (updateType == LyricUpdateType.forward) {
      lyricTimeOffset += 200;
    } else if (updateType == LyricUpdateType.backword) {
      lyricTimeOffset -= 200;
    } else {
      lyricTimeOffset = 0;
    }

    try {
      final dbController = Get.find<DbController>();
      await dbController.updateData(
        DbController.playlistTable,
        uuid,
        jsonEncode(toJson()),
      );
    } catch (e) {
      log.d(e);
    }
  }
}
