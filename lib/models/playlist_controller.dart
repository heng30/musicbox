import 'package:get/get.dart';

import './song.dart';

class PlaylistController extends GetxController {
  final playlist = [
    Song(
      songName: "泪桥-1",
      artistName: "古巨基",
      albumArtImagePath: "assets/images/1.png",
      audioPath: "assets/audio/leiqiao.mp3",
    ),
    Song(
      songName: "泪桥-2",
      artistName: "周深",
      albumArtImagePath: "assets/images/2.png",
      audioPath: "assets/audio/leiqiao.mp3",
    ),
    Song(
      songName: "泪桥-3",
      artistName: "古巨基 && 周深",
      albumArtImagePath: "assets/images/3.png",
      audioPath: "assets/audio/leiqiao.mp3",
    ),
  ].obs;

  RxInt? _currentSongIndex = 0.obs;
  int get currentSongIndex => _currentSongIndex!.value;

  set currentSongIndex(int index) {
    if (index < 0) {
      _currentSongIndex = null;
    } else {
      if (_currentSongIndex == null) {
        _currentSongIndex = index.obs;
      } else {
        _currentSongIndex!.value = index;
      }
    }
  }

  void toggleFavorite() {
    playlist[_currentSongIndex!.value].isFavorite.value =
        !playlist[_currentSongIndex!.value].isFavorite.value;
  }
}
