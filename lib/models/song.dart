import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

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

  final RxBool _isFavorite;
  bool get isFavorite => _isFavorite.value;
  set isFavorite(bool v) => _isFavorite.value = v;

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
    bool isFavorite = false,
  })  : _isFavorite = isFavorite.obs,
        uuid = const Uuid().v4();

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
