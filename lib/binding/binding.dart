import 'package:get/get.dart';

import '../theme/controller.dart';
import '../lang/controller.dart';
import '../models/playlist_controller.dart';
import '../models/player_controller.dart';
import '../models/player_tile_controller.dart';
import '../models/about_controller.dart';
import '../models/audio_session_controller.dart';
import '../models/setting_controller.dart';

class InitControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ThemeController());
  }
}

Future<void> initGlobalController() async {
  // ensure setting is completed before others operation
  final settingController = SettingController();
  await settingController.init();
  Get.put(settingController);

  Get.put(LangController());
  Get.put(AudioSessionController());
  Get.put(PlaylistController());
  Get.put(PlayerTileController());
  Get.put(PlayerController());
  Get.put(AboutController());
}
