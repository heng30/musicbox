import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audiotagger/audiotagger.dart';

import './song.dart';
import './albums.dart';
import '../theme/theme.dart';
import './player_controller.dart';
import './db_controller.dart';
import './find_controller.dart';

class PlaylistController extends GetxController {
  final playlist = <Song>[].obs;
  final dbController = Get.find<DbController>();
  final log = Logger();

  final TextEditingController _renameController = TextEditingController();
  final FocusNode _renameFocusNode = FocusNode();

  @override
  void onClose() {
    _renameController.dispose();
    _renameFocusNode.dispose();

    super.onClose();
  }

  Future<void> init() async {
    if (!kReleaseMode) {
      fakePlaylist();
    }

    await initFromDB();
    sortPlaylist();
  }

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
    for (int i = 0; i < 2; i++) {
      playlist.add(
        Song(
          songName: "$i本地测试音频",
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
        isFavorite: false,
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

      playerController.setLyric(index);
      playerController.play();
    }
  }

  void setCurrentSongIndexWithoutPlay(int index) {
    _currentSongIndex = index.obs;

    final playerController = Get.find<PlayerController>();
    playerController.setSrc(index);
    playerController.setLyric(index);
  }

  // toggle favorite song by index
  void toggleFavorite(index) async {
    playlist[index].isFavorite = !playlist[index].isFavorite;

    await dbController.updateData(DbController.playlistTable,
        playlist[index].uuid, jsonEncode(playlist[index].toJson()));
  }

  void updateSelectedSong() {
    for (int i = 0; i < playlist.length; i++) {
      if (i == currentSongIndex) {
        playlist[i].isSelected = true;
      } else {
        playlist[i].isSelected = false;
      }
    }
  }

  Future<void> _removeFileInDownloadDir(String path) async {
    final findController = Get.find<FindController>();

    try {
      if (await findController.isInDownloadDir(path)) {
        final file = File(path);
        final realFile =
            File("${findController.downloadDir!}/${basename(file.path)}");

        await realFile.delete();
        await file.delete();
      }
    } catch (e) {
      log.d(e);
    }
  }

  // remove one song from playlist
  void remove(int index) async {
    try {
      if (index < playlist.length) {
        if (currentSongIndex == index) {
          currentSongIndex = null;
        } else if (isValidCurrentSongIndex && currentSongIndex! > index) {
          _currentSongIndex!.value--;
        }

        final song = playlist[index];
        playlist.removeAt(index);

        await dbController.delete(DbController.playlistTable, song.uuid);
        await _removeFileInDownloadDir(song.audioPath);
      }
    } catch (e) {
      log.d(e);
    }
  }

  void renameSong(int index) async {
    final name = _renameController.text.trim();
    if (name.isEmpty) return;

    final song = playlist[index].copy();
    song.songName = name;
    playlist[index] = song;

    await dbController.updateData(DbController.playlistTable,
        playlist[index].uuid, jsonEncode(song.toJson()));
  }

  // remove all songs from playlist
  void removeAll() async {
    for (Song song in playlist) {
      await _removeFileInDownloadDir(song.audioPath);
    }

    playlist.value = [];
    currentSongIndex = null;

    await dbController.deleteAll(DbController.playlistTable);
  }

  // add songs to playlist
  void add(List<Song> songs, {bool isShowMsg = true}) async {
    if (songs.isEmpty) return;

    List<Song> newSongs = [];
    for (var item in songs) {
      if (playlist.firstWhereOrNull((el) =>
              item.songName == el.songName &&
              item.artistName == el.artistName) ==
          null) {
        newSongs.add(item);
      }
    }

    if (newSongs.isNotEmpty) {
      if (isShowMsg) {
        Get.snackbar("提 示".tr, '${"添加".tr} ${newSongs.length} ${"首歌曲".tr}',
            snackPosition: SnackPosition.BOTTOM);
      }
      playlist.addAll(newSongs);
    } else {
      Get.snackbar("提 示".tr, "歌曲已经在播放列表".tr,
          snackPosition: SnackPosition.BOTTOM);
    }

    for (var song in newSongs) {
      await dbController.insert(
          DbController.playlistTable, song.uuid, jsonEncode(song.toJson()));
    }
  }

  Future<void> initFromDB() async {
    final entrys = await dbController.selectAll(DbController.playlistTable);

    var items = <Song>[];
    for (Map<String, dynamic> item in entrys) {
      final data = item['data'];
      Map<String, dynamic> json = jsonDecode(data);
      items.add(Song.fromJson(json));
    }
    playlist.addAll(items);
  }

  static Future<List<Song>> loadLocal() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      // type: FileType.custom,
      // allowedExtensions: ['mp3', 'mp4', 'm4s', 'wav', 'flac', 'ogg'],
      initialDirectory: Get.find<FindController>().downloadDir,
    );

    var songs = <Song>[];
    if (result != null) {
      final tagger = Audiotagger();

      for (var item in result.xFiles) {
        final entrys = basenameWithoutExtension(item.name).split('_');
        String trackName = entrys.first;
        String artistName = "";

        if (entrys.length > 1) {
          artistName = entrys[1];
        }

        if (item.path.endsWith(".mp3")) {
          try {
            final tag = await tagger.readTags(path: item.path);
            trackName = tag?.title ?? entrys.first;
            artistName = tag?.artist ?? "";
          } catch (e) {
            Logger().d("$e");
          } finally {
            if (trackName.isEmpty) trackName = entrys.first;
          }
        }

        songs.add(
          Song(
            songName: trackName,
            artistName: artistName,
            albumArtImagePath: Albums.next(),
            audioPath: item.path,
          ),
        );
      }
    }

    return songs;
  }

  void clearPlaylistDialog() {
    Get.defaultDialog(
      title: "提 示".tr,
      middleText: '${"是否删除全部歌曲".tr}?',
      confirm: ElevatedButton(
        onPressed: () {
          Get.closeAllSnackbars();
          Get.back();
          removeAll();
          Get.snackbar("提 示".tr, "已经删除全部歌曲".tr,
              snackPosition: SnackPosition.BOTTOM);
        },
        child: Obx(
          () => Text(
            "删除全部".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: Obx(
          () => Text(
            "取消".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
    );
  }

  void renameSongDialog(int index) {
    _renameController.text = playlist[index].songName;

    Get.defaultDialog(
      title: "重命名".tr,
      content: TextField(
        controller: _renameController,
        focusNode: _renameFocusNode,
        onSubmitted: (_) => renameSong(index),
        decoration: InputDecoration(
          hintText: "新名称",
          suffixIcon: IconButton(
            onPressed: () => _renameController.clear(),
            icon: Icon(
              Icons.clear,
              size: CTheme.iconSize * 0.8,
              color: CTheme.primary,
            ),
          ),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.closeAllSnackbars();
          Get.back();
          renameSong(index);
          Get.snackbar("提 示".tr, "重命名成功".tr,
              snackPosition: SnackPosition.BOTTOM);
        },
        child: Text(
          "确定".tr,
          style: TextStyle(color: CTheme.inversePrimary),
        ),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: Text(
          "取消".tr,
          style: TextStyle(color: CTheme.inversePrimary),
        ),
      ),
    );
  }

  void clearPlaylistOneSongDialog(int index) {
    Get.defaultDialog(
      title: "提 示".tr,
      middleText: '${"是否删除歌曲".tr}?',
      confirm: ElevatedButton(
        onPressed: () {
          Get.closeAllSnackbars();
          Get.back();
          remove(index);
          Get.snackbar("提 示".tr, "已经删除歌曲".tr,
              snackPosition: SnackPosition.BOTTOM);
        },
        child: Obx(
          () => Text(
            "删除歌曲".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: Obx(
          () => Text(
            "取消".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
    );
  }
}
