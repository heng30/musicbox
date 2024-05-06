import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import './albums.dart';

enum AudioLocation {
  asset,
  local,
  remote,
  memory,
}

class Song {
  final String uuid;
  final String songName;
  final String? artistName;
  final String albumArtImagePath;
  final String audioPath;
  final AudioLocation audioLocation;

  final RxBool _isFavorite;
  bool get isFavorite => _isFavorite.value;
  set isFavorite(bool v) => _isFavorite.value = v;

  static const String noneAsset = "audio/none.mp3";

  Song.none({
    this.uuid = "uuid-none",
    this.songName = "None",
    this.artistName,
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
}
