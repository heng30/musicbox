import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:mmoo_lyric/lyric.dart';
import 'package:mmoo_lyric/lyric_util.dart';

import './albums.dart';
import '../models/find_controller.dart';

enum AudioLocation {
  asset,
  local,
  remote,
  memory,
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
  String uuid;
  String songName;
  String artistName;
  String albumArtImagePath;
  String audioPath;
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
      lyrics.addAll(LyricUtil.formatLyric(lyric));
    } catch (e) {
      log.d("parse lyric error: $e");
    }
  }

  static const String noneAsset = "audio/none.mp3";

  Song.none({
    this.uuid = "uuid-none",
    this.songName = "None",
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
        _isFavorite = (json['isFavorite'] as bool).obs;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'uuid': uuid,
      'songName': songName,
      'artistName': artistName,
      'audioPath': audioPath,
      'audioLocation': audioLocation.toString(),
      'isFavorite': isFavorite,
    };
    return data;
  }
}
