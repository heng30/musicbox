import 'package:get/get.dart';

import '../theme/controller.dart';
import '../lang/controller.dart';
import '../models/playlist_controller.dart';
import '../models/player_controller.dart';
import '../models/about_controller.dart';
import '../models/audio_session_controller.dart';

class InitControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ThemeController());
  }
}

void initGlobalController() async {
  Get.put(LangController());

  final audioSessionController = AudioSessionController();
  audioSessionController.init();
  Get.put(audioSessionController);

  Get.put(PlaylistController());
  Get.put(PlayerController());

  final aboutController = AboutController();
  aboutController.init();
  Get.put(aboutController);
}
