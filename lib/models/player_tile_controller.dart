import 'package:get/get.dart';

import './song.dart';

class PlayerTileController extends GetxController {
  final Rx<Song> _playingSong = Song.none().obs;
  Song get playingSong => _playingSong.value;
  set playingSong(Song v) => _playingSong.value = v;
}
