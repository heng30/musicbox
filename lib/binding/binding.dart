import 'package:get/get.dart';

import '../theme/controller.dart';
import '../lang/controller.dart';

class InitControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ThemeController());
  }
}

void initGlobalController() {
  Get.put(LangController());
}
