import 'package:get/get.dart';

class Song {
  final String songName;
  final String artistName;
  final String albumArtImagePath;
  final String audioPath;

  final isFavorite = false.obs;

  Song({
    required this.songName,
    required this.artistName,
    required this.albumArtImagePath,
    required this.audioPath,
  });
}
