import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

import './song.dart';
import './playlist_controller.dart';
import './audio_session_controller.dart';
import '../models/player_tile_controller.dart';

enum PlayModel {
  loop,
  shuffle,
  single,
}

class PlayerController extends GetxController {
  final _audioPlayer = AudioPlayer();
  final playlistController = Get.find<PlaylistController>();

  final _isPlaying = false.obs;
  bool get isPlaying => _isPlaying.value;
  set isPlaying(v) => _isPlaying.value = v;

  final _currentDuration = Duration.zero.obs;
  Duration get currentDuration => _currentDuration.value;
  set currentDuration(v) => _currentDuration.value = v;

  final _totalDuration = Duration.zero.obs;
  Duration get totalDuration => _totalDuration.value;
  set totalDuration(v) => _totalDuration.value = v;

  PlayerController() {
    listenToDuration();
    _audioPlayer.setVolume(volume);
  }

  final _playModel = PlayModel.loop.obs;
  PlayModel get playModel => _playModel.value;
  set playModel(v) => _playModel.value = v;

  // switch play mode: loop, shuffle, single
  void playModelNext() {
    if (playModel == PlayModel.loop) {
      playModel = PlayModel.shuffle;
    } else if (playModel == PlayModel.shuffle) {
      playModel = PlayModel.single;
    } else {
      playModel = PlayModel.loop;
    }
  }

  Future<void> setAudioSessionActive(bool flag) async {
    final audioSessionController = Get.find<AudioSessionController>();
    await audioSessionController.setActive(flag);
  }

  void play() async {
    if (playlistController.playlist.isEmpty) {
      return;
    }

    if (!playlistController.isValidCurrentSongIndex) {
      return;
    }

    await setAudioSessionActive(false);
    await _audioPlayer.stop(); // stop the current song

    late Source src;
    final song =
        playlistController.playlist[playlistController.currentSongIndex!];

    try {
      if (song.audioLocation == AudioLocation.asset) {
        src = AssetSource(song.audioPath);
      } else if (song.audioLocation == AudioLocation.local) {
        src = DeviceFileSource(song.audioPath);
      } else if (song.audioLocation == AudioLocation.memory) {
        final file = File(song.audioPath);
        src = BytesSource(await file.readAsBytes());
      } else {
        src = UrlSource(song.audioPath);
      }

      await _audioPlayer.play(src);
      await _audioPlayer.setPlaybackRate(speed);

      isPlaying = true;

      await setAudioSessionActive(true);
    } catch (e) {
      await _audioPlayer.release();
      isPlaying = false;
      Get.snackbar("播放失败".tr, e.toString());
    }
  }

  void stop() async {
    await setAudioSessionActive(false);

    await _audioPlayer.stop();
    isPlaying = false;
  }

  void pause({bool isActiveAduioSession = false}) async {
    if (!isActiveAduioSession) {
      await setAudioSessionActive(false);
    }

    await _audioPlayer.pause();
    isPlaying = false;

    if (isActiveAduioSession) {
      await setAudioSessionActive(true);
    }
  }

  void resume({bool isActiveAduioSession = true}) async {
    if (!isActiveAduioSession) {
      await setAudioSessionActive(false);
    }

    await _audioPlayer.resume();
    isPlaying = true;

    if (isActiveAduioSession) {
      await setAudioSessionActive(true);
    }
  }

  void pauseOrResume() async {
    if (!playlistController.isValidCurrentSongIndex) return;

    if (isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  final _speed = 1.0.obs;
  double get speed => _speed.value;
  set speed(double v) => setSpeed(v);

  void setSpeed(double v) async {
    _speed.value = v;
    await _audioPlayer.setPlaybackRate(speed);
  }

  final _volume = 0.5.obs;
  bool get isMute => _volume.value <= 0.001;
  double get volume => _volume.value;

  void setVolumn(double volume) async {
    _volume.value = volume;
    await _audioPlayer.setVolume(volume);
  }

  // get the real volume and update the _volume variable
  void syncVolumn() {
    _volume.value = _audioPlayer.volume;
  }

  // this is for AudioSession, so we should change the _valume variable
  void duck(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // this is for AudioSession, resume the audio volume
  void unduck() async {
    await _audioPlayer.setVolume(volume);
  }

  void playNextSong() {
    if (playlistController.playlist.isEmpty) {
      return;
    }

    if (playModel == PlayModel.shuffle) {
      playlistController.currentSongIndex =
          Random().nextInt(playlistController.playlist.length);
      return;
    }

    if (playlistController.isValidCurrentSongIndex) {
      if (playlistController.currentSongIndex! <
          playlistController.playlist.length - 1) {
        playlistController.currentSongIndex =
            playlistController.currentSongIndex! + 1;
      } else {
        playlistController.currentSongIndex = 0;
      }
    }
  }

  void playPreviousSong() {
    if (playlistController.playlist.isEmpty) {
      return;
    }

    if (playModel == PlayModel.shuffle) {
      playlistController.currentSongIndex =
          Random().nextInt(playlistController.playlist.length);
      return;
    }

    if (playlistController.isValidCurrentSongIndex) {
      if (playlistController.currentSongIndex! > 0) {
        playlistController.currentSongIndex =
            playlistController.currentSongIndex! - 1;
      } else {
        playlistController.currentSongIndex =
            playlistController.playlist.length - 1;
      }
    }
  }

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      totalDuration = newDuration;
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      currentDuration = newPosition;
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (playModel == PlayModel.single) {
        play();
      } else {
        playNextSong();
        Get.find<PlayerTileController>().playingSong =
            playlistController.playingSong();
      }
    });
  }
}
