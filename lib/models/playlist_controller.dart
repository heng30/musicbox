import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

import './song.dart';
import '././albums.dart';

enum PlayModel {
  loop,
  shuffle,
  single,
}

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

  void fakePlaylist() {
    for (int i = 0; i < 10; i++) {
      playlist.add(
        Song(
          songName: "泪桥-$i",
          artistName: "古巨基 && 周深",
          albumArtImagePath: Albums.random(),
          audioPath: "audio/leiqiao.mp3",
          audioLocation: AudioLocation.asset,
          isFavorite: Random().nextInt(5) == 0,
        ),
      );
    }

    playlist.add(
      Song(
        songName: "泪桥-local",
        artistName: "古巨基 && 周深",
        albumArtImagePath: Albums.random(),
        audioPath: "/home/blue/tmp/leiqiao.mp3",
        audioLocation: AudioLocation.local,
        isFavorite: true,
      ),
    );

    playlist.add(
      Song(
        songName: "泪桥-local-wrong",
        artistName: "古巨基 && 周深",
        albumArtImagePath: Albums.random(),
        audioPath: "/tmp/leiqiao.mp3",
        audioLocation: AudioLocation.local,
        isFavorite: true,
      ),
    );

    playlist.add(
      Song(
        songName: "在线mp3音频",
        artistName: "mp3音频",
        albumArtImagePath: Albums.random(),
        audioPath:
            "http://downsc.chinaz.net/Files/DownLoad/sound1/201906/11582.mp3",
        audioLocation: AudioLocation.remote,
        isFavorite: true,
      ),
    );
  }

  RxInt? _currentSongIndex;
  int? get currentSongIndex => _currentSongIndex?.value;
  bool get isValidCurrentSongIndex => _currentSongIndex != null;

  set currentSongIndex(int? index) {
    if (index == null) {
      _currentSongIndex = null;
    } else {
      if (_currentSongIndex == null) {
        _currentSongIndex = index.obs;
      } else {
        _currentSongIndex!.value = index;
      }

      play();
    }
  }

  void toggleFavorite(index) {
    playlist[index].isFavorite = !playlist[index].isFavorite;
  }

  final _playModel = PlayModel.loop.obs;
  PlayModel get playModel => _playModel.value;
  set playModel(v) => _playModel.value = v;

  void playModelNext() {
    if (playModel == PlayModel.loop) {
      playModel = PlayModel.shuffle;
    } else if (playModel == PlayModel.shuffle) {
      playModel = PlayModel.single;
    } else {
      playModel = PlayModel.loop;
    }
  }

  final _audioPlayer = AudioPlayer();
  final _currentDuration = Duration.zero.obs;
  final _totalDuration = Duration.zero.obs;

  final _isPlaying = false.obs;
  bool get isPlaying => _isPlaying.value;
  set isPlaying(v) => _isPlaying.value = v;

  Duration get currentDuration => _currentDuration.value;
  Duration get totalDuration => _totalDuration.value;

  PlaylistController() {
    fakePlaylist();
    sortPlaylist();
    listenToDuration();
    _audioPlayer.setVolume(volume);
  }

  void play() async {
    if (playlist.isEmpty) {
      return;
    }

    if (_currentSongIndex == null) {
      return;
    }

    final song = playlist[currentSongIndex!];
    await _audioPlayer.stop(); // stop the current song
    late Source src;

    try {
      if (song.audioLocation == AudioLocation.asset) {
        src = AssetSource(song.audioPath);
      } else if (song.audioLocation == AudioLocation.local) {
        final file = File(song.audioPath);
        src = BytesSource(await file.readAsBytes());
      } else {
        src = UrlSource(song.audioPath);
      }
      await _audioPlayer.play(src);
      isPlaying = true;
    } catch (e) {
      await _audioPlayer.release();
      Get.snackbar("播放失败".tr, e.toString());
      isPlaying = false;
    }
  }

  void pause() async {
    await _audioPlayer.pause();
    isPlaying = false;
  }

  void resume() async {
    await _audioPlayer.resume();
    isPlaying = true;
  }

  void pauseOrResume() async {
    if (isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  final _volume = 0.5.obs;
  bool get isMute => _volume.value <= 0.001;
  double get volume => _volume.value;

  void setVolumn(double volume) async {
    _volume.value = volume;
    await _audioPlayer.setVolume(volume);
  }

  void syncVolumn() {
    _volume.value = _audioPlayer.volume;
  }

  void playNextSong() {
    if (playlist.isEmpty) {
      return;
    }

    if (playModel == PlayModel.shuffle) {
      currentSongIndex = Random().nextInt(playlist.length);
    }

    if (isValidCurrentSongIndex) {
      if (currentSongIndex! < playlist.length - 1) {
        currentSongIndex = currentSongIndex! + 1;
      } else {
        currentSongIndex = 0;
      }
    }
  }

  void playPreviousSong() {
    if (playlist.isEmpty) {
      return;
    }

    if (playModel == PlayModel.shuffle) {
      currentSongIndex = Random().nextInt(playlist.length);
    }

    if (isValidCurrentSongIndex) {
      if (currentSongIndex! > 0) {
        currentSongIndex = currentSongIndex! - 1;
      } else {
        currentSongIndex = playlist.length - 1;
      }
    }
  }

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration.value = newDuration;
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration.value = newPosition;
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (playModel == PlayModel.single) {
        play();
      } else {
        playNextSong();
      }
    });
  }
}
