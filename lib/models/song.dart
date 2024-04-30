import 'package:get/get.dart';

class Song {
  late RxString _songName;
  late RxString _artistName;
  late RxString _albumArtImagePath;
  String audioPath;

  final _isFavorite = false.obs;

  Song({
    required String songName,
    required String artistName,
    required String albumArtImagePath,
    required this.audioPath,
  }) {
    _songName = songName.obs;
    _artistName = artistName.obs;
    _albumArtImagePath = albumArtImagePath.obs;
  }

  String get songName => _songName.value;
  String get artistName => _artistName.value;
  String get albumArtImagePath => _albumArtImagePath.value;
  bool get isFavorite => _isFavorite.value;
  set isFavorite(v) => _isFavorite.value = v;
}
