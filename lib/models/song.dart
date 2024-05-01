import 'package:get/get.dart';

class Song {
  final String songName;
  final String artistName;
  final String albumArtImagePath;
  final String audioPath;

  final RxBool _isFavorite;

  Song({
    required this.songName,
    required this.artistName,
    required this.albumArtImagePath,
    required this.audioPath,
    bool isFavorite = false,
  }) : _isFavorite = isFavorite.obs;

  bool get isFavorite => _isFavorite.value;
  set isFavorite(v) => _isFavorite.value = v;
}
