import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audiotagger/audiotagger.dart';

import './albums.dart';

enum AudioLocation {
  asset,
  local,
  remote,
}

class Song {
  final String songName;
  final String? artistName;
  final String albumArtImagePath;
  final String audioPath;
  final AudioLocation audioLocation;

  final RxBool _isFavorite;
  bool get isFavorite => _isFavorite.value;
  set isFavorite(bool v) => _isFavorite.value = v;

  static const String noneAsset = "audio/none.mp3";

  Song.none({
    this.songName = "None",
    this.artistName,
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

  static Future<List<Song>> loadLocal() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'flac', 'ogg'],
    );

    var songs = <Song>[];
    if (result != null) {
      final tagger = Audiotagger();

      for (var item in result.xFiles) {
        String trackName = item.name;
        String? artistName;

        try {
          final tag = await tagger.readTags(path: item.path);
          trackName = tag?.title ?? item.name;
          artistName = tag?.artist;
        } catch (e) {
          Logger().d("$e");
        } finally {
          if (trackName.isEmpty) trackName = item.name;
        }

        songs.add(
          Song(
            songName: trackName,
            artistName: artistName,
            albumArtImagePath: Albums.random(),
            audioPath: item.path,
          ),
        );
      }
    }

    return songs;
  }
}
