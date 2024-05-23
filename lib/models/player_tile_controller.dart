import 'package:get/get.dart';

import './song.dart';
import './playlist_controller.dart';

class PlayerTileController extends GetxController {
  final Rx<Song> _playingSong = Song.none().obs;
  Song get playingSong => _playingSong.value;
  set playingSong(Song v) => _playingSong.value = v;

  PlayerTileController() {
    final playlistController = Get.find<PlaylistController>();
    if (playlistController.playlist.isNotEmpty) {
      playingSong = playlistController.playlist[0];
      playlistController.setCurrentSongIndexWithoutPlay(0);
      playlistController.playlist[0].isSelected = true;
    }
  }
}
