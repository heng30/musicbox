import 'package:get/get.dart';

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
  set isFavorite(v) => _isFavorite.value = v;

  Song({
    required this.songName,
    required this.artistName,
    required this.albumArtImagePath,
    required this.audioPath,
    this.audioLocation = AudioLocation.local,
    bool isFavorite = false,
  }) : _isFavorite = isFavorite.obs;
}
