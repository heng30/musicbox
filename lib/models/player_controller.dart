import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:audioplayers/audioplayers.dart';

import './song.dart';
import './playlist_controller.dart';
import './audio_session_controller.dart';
import './setting_controller.dart';
import '../models/player_tile_controller.dart';
import "../models/lyric_controller.dart";

enum PlayModel {
  loop,
  shuffle,
  single,
}

class PlayerController extends GetxController {
  final _audioPlayer = AudioPlayer();
  final playlistController = Get.find<PlaylistController>();
  final settingController = Get.find<SettingController>();
  final log = Logger();

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

    _speed.value = settingController.playbackSpeed;
    _audioPlayer.setPlaybackRate(settingController.playbackSpeed);
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

  Future<Source> genSrc(int index) async {
    late Source src;
    final song = playlistController.playlist[index];

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

    return src;
  }

  Future<void> setLyric(int index) async {
    final songLyricController = Get.find<SongLyricController>();
    final song = playlistController.playlist[index];

    try {
      final path =
          await songLyricController.getDownloadsDirectoryWithoutCreate();
      final f = File("$path/${song.songName}.lrc");

      song.lyric = await f.readAsString();
      songLyricController.updateControllerWithForceUpdateLyricWidget();
    } catch (e) {
      log.d(e);
    }
  }

  Future<void> setSrc(int index) async {
    final src = await genSrc(index);
    _audioPlayer.setSource(src);
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

    try {
      final src = await genSrc(playlistController.currentSongIndex!);

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

    settingController.playbackSpeed = v;
    await settingController.save();
  }

  final _volume = 0.8.obs;
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

    Get.find<SongLyricController>()
        .updateControllerWithForceUpdateLyricWidget();

    if (playModel == PlayModel.shuffle) {
      playlistController.currentSongIndex =
          Random().nextInt(playlistController.playlist.length);
    } else {
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

    playlistController.updateSelectedSong();
  }

  void playPreviousSong() {
    if (playlistController.playlist.isEmpty) {
      return;
    }

    Get.find<SongLyricController>()
        .updateControllerWithForceUpdateLyricWidget();

    if (playModel == PlayModel.shuffle) {
      playlistController.currentSongIndex =
          Random().nextInt(playlistController.playlist.length);
    } else {
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
    playlistController.updateSelectedSong();
  }

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      totalDuration = newDuration;
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      currentDuration = newPosition;
      Get.find<SongLyricController>().controller.progress = newPosition;
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (playModel == PlayModel.single) {
        Get.find<SongLyricController>()
            .updateControllerWithForceUpdateLyricWidget();
        play();
      } else {
        playNextSong();
        Get.find<PlayerTileController>().playingSong =
            playlistController.playingSong();
      }
    });
  }
}
