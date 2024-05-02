import 'package:get/get.dart';

import '../theme/controller.dart';
import '../lang/controller.dart';
import '../models/playlist_controller.dart';
import '../models/player_controller.dart';

class InitControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ThemeController());
  }
}

void initGlobalController() {
  Get.put(LangController());
  Get.put(PlaylistController());
  Get.put(PlayerController());
}
