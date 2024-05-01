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
  final playlist = [];

  void fakePlaylist() {
    for (int i = 0; i < 20; i++) {
      playlist.add(Song(
        songName: "泪桥-$i",
        artistName: "古巨基 && 周深",
        albumArtImagePath: Albums.random(),
        audioPath: "audio/leiqiao.mp3",
      ));
    }
  }

  RxInt? _currentSongIndex;
  int? get currentSongIndex => _currentSongIndex?.value;
  bool get isValidSongIndex => _currentSongIndex != null;

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

  void toggleFavorite() {
    playlist[_currentSongIndex!.value].isFavorite =
        !playlist[_currentSongIndex!.value].isFavorite;
  }

  final _playModel = PlayModel.loop.obs;
  PlayModel get playModel => _playModel.value;
  void playModelNext() {
    if (_playModel.value == PlayModel.loop) {
      _playModel.value = PlayModel.shuffle;
    } else if (_playModel.value == PlayModel.shuffle) {
      playlist.shuffle();
      _playModel.value = PlayModel.single;
    } else {
      _playModel.value = PlayModel.loop;
    }
  }

  final _audioPlayer = AudioPlayer();
  final _isPlaying = false.obs;
  final _currentDuration = Duration.zero.obs;
  final _totalDuration = Duration.zero.obs;

  bool get isPlaying => _isPlaying.value;
  Duration get currentDuration => _currentDuration.value;
  Duration get totalDuration => _totalDuration.value;

  PlaylistController() {
    fakePlaylist();
    listenToDuration();
    _audioPlayer.setVolume(volume);
  }

  void play() async {
    if (playlist.isEmpty) {
      return;
    }

    final path = playlist[_currentSongIndex!.value].audioPath;
    await _audioPlayer.stop(); // stop the current song
    await _audioPlayer.play(AssetSource(path));
    _isPlaying.value = true;
  }

  void pause() async {
    await _audioPlayer.pause();
    _isPlaying.value = false;
  }

  void resume() async {
    await _audioPlayer.resume();
    _isPlaying.value = true;
  }

  void pauseOrResume() async {
    if (_isPlaying.value) {
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

  void updateVolumn() {
    _volume.value = _audioPlayer.volume;
  }

  void playNextSong() {
    if (playlist.isEmpty) {
      return;
    }

    if (_currentSongIndex != null) {
      if (_currentSongIndex!.value < playlist.length - 1) {
        _currentSongIndex!.value += 1;
      } else {
        _currentSongIndex!.value = 0;
      }

      play();
    }
  }

  void playPreviousSong() {
    if (playlist.isEmpty) {
      return;
    }

    if (_currentSongIndex!.value > 0) {
      _currentSongIndex!.value -= 1;
    } else {
      _currentSongIndex!.value = playlist.length - 1;
    }
    play();
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
