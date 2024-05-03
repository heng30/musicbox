import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import './albums.dart';

enum AudioLocation {
  asset,
  local,
  remote,
}

class Song {
  final String songName;
  final String artistName;
  final String albumArtImagePath;
  final String audioPath;
  final AudioLocation audioLocation;

  final RxBool _isFavorite;
  bool get isFavorite => _isFavorite.value;
  set isFavorite(bool v) => _isFavorite.value = v;

  static const String noneAsset = "audio/none.mp3";

  Song.none({
    this.songName = "None",
    this.artistName = "None",
    this.albumArtImagePath = Albums.noneAsset,
    this.audioPath = noneAsset,
    this.audioLocation = AudioLocation.asset,
  }) : _isFavorite = false.obs;

  Song({
    required this.songName,
    required this.artistName,
    required this.albumArtImagePath,
    required this.audioPath,
    this.audioLocation = AudioLocation.local,
    bool isFavorite = false,
  }) : _isFavorite = isFavorite.obs;

  // TODO: get the artist name from the audio file
  static Future<List<Song>> loadLocal() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'flac', 'ogg'],
    );

    var songs = <Song>[];
    if (result != null) {
      songs = result.xFiles
          .map(
            (item) => Song(
              songName: item.name,
              artistName: "None",
              albumArtImagePath: Albums.random(),
              audioPath: item.path,
            ),
          )
          .toList();
    }

    return songs;
  }
}
