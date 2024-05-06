import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import './song.dart';
import './albums.dart';
import './player_controller.dart';

class PlaylistController extends GetxController {
  final playlist = <Song>[].obs;

  void sortPlaylist() {
    playlist.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) {
        return -1;
      } else if (!a.isFavorite && b.isFavorite) {
        return 1;
      } else {
        return a.songName.compareTo(b.songName);
      }
    });
  }

  List<Song> searchByKeyword(String keyword) {
    if (keyword.isEmpty) return [];

    return playlist.where((item) => item.songName.contains(keyword)).toList();
  }

  // find the some by sone name
  int? findByName(String name) {
    return playlist.indexWhere((item) => item.songName == name);
  }

  // get the current playing song info
  Song playingSong() {
    if (isValidCurrentSongIndex) {
      return playlist[currentSongIndex!];
    } else {
      return Song.none();
    }
  }

  // put fake songs into playlist
  void fakePlaylist() {
    for (int i = 0; i < 1; i++) {
      playlist.add(
        Song(
          songName: "本地测试音频",
          artistName: "测试",
          albumArtImagePath: Albums.random(),
          audioPath: "audio/none.mp3",
          audioLocation: AudioLocation.asset,
          isFavorite: Random().nextInt(2) == 0,
        ),
      );
    }

    playlist.add(
      Song(
        songName: "在线mp3音频",
        artistName: "mp3音频",
        albumArtImagePath: Albums.random(),
        audioPath: "https://download.samplelib.com/mp3/sample-15s.mp3",
        audioLocation: AudioLocation.remote,
        isFavorite: true,
      ),
    );
  }

  bool get isValidCurrentSongIndex => _currentSongIndex != null;

  RxInt? _currentSongIndex;
  int? get currentSongIndex => _currentSongIndex?.value;

  set currentSongIndex(int? index) {
    final playerController = Get.find<PlayerController>();
    if (index == null) {
      _currentSongIndex = null;
      playerController.stop();
    } else {
      if (_currentSongIndex == null) {
        _currentSongIndex = index.obs;
      } else {
        _currentSongIndex!.value = index;
      }

      playerController.play();
    }
  }

  // toggle favorite song by index
  void toggleFavorite(index) {
    playlist[index].isFavorite = !playlist[index].isFavorite;
  }

  // remove one song from playlist
  void remove(int index) {
    if (index < playlist.length) {
      if (currentSongIndex == index) {
        currentSongIndex = null;
      }
      playlist.removeAt(index);
    }
  }

  // remove all songs from playlist
  void removeAll() {
    playlist.value = [];
    currentSongIndex = null;
  }

  // add songs to playlist
  void add(List<Song> songs) {
    if (songs.isEmpty) return;

    List<Song> newSongs = [];
    for (var item in songs) {
      if (playlist.firstWhereOrNull((el) => item.songName == el.songName) ==
          null) {
        newSongs.add(item);
      }
    }

    if (newSongs.isNotEmpty) {
      Get.snackbar("提 示".tr, '${"添加".tr} ${newSongs.length} ${"首歌曲".tr}');
      playlist.addAll(newSongs);
    } else {
      Get.snackbar("提 示".tr, "歌曲已经在播放列表".tr);
    }
  }

  PlaylistController() {
    if (!kReleaseMode) fakePlaylist();

    sortPlaylist();
  }
}
