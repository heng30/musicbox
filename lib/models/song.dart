import 'package:get/get.dart';

import './albums.dart';

enum AudioLocation {
  asset,
  local,
  remote,
}

class Song {
  final String songName;
  final String artistName;
  final String albumArtImagePath;
  final String audioPath;
  final AudioLocation audioLocation;

  final RxBool _isFavorite;
  bool get isFavorite => _isFavorite.value;
  set isFavorite(bool v) => _isFavorite.value = v;

  static const String noneAsset = "audio/none.mp3";

  Song.none({
    this.songName = "None",
    this.artistName = "None",
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
  }) : _isFavorite = isFavorite.obs;
}
