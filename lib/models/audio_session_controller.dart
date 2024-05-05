import 'package:get/get.dart';
import "package:logger/logger.dart";
import 'package:audio_session/audio_session.dart';

import './playlist_controller.dart';

class AudioSessionController extends GetxController {
  AudioSession? session;

  void init() async {
    try {
      session = await AudioSession.instance;
      if (session == null) {
        Logger().w("AudioSession is null");
      }

      await session?.configure(const AudioSessionConfiguration.music());

      // initListener();
    } catch (e) {
      Get.snackbar("初始化AudioSession失败".tr, "$e.toString()");
    }
  }

  Future<bool> setActive(bool flag) async {
    if (session == null) return false;

    late String msg;
    if (flag) {
      msg = "激活 AudioSession 失败".tr;
    } else {
      msg = "停止 AudioSession 失败".tr;
    }

    try {
      if (!(await session!.setActive(flag))) {
        Get.snackbar("提 示".tr, msg);
      }
    } catch (e) {
      Get.snackbar(msg, "$e.toString()");
    }

    return true;
  }

  void initListener() {
    session?.interruptionEventStream.listen(
      (event) {
        final playlistController = Get.find<PlaylistController>();

        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // Another app started playing audio and we should duck.
              Logger().d("should duck");
              playlistController.duck(0.1);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              // Another app started playing audio and we should pause.
              Logger().d("should pause");
              playlistController.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // The interruption ended and we should unduck.
              Logger().d("should unduck");
              playlistController.unduck();
              break;
            case AudioInterruptionType.pause:
              // The interruption ended and we should resume.
              Logger().d("should resume");
              playlistController.resume();
              break;
            case AudioInterruptionType.unknown:
              // The interruption ended but we should not resume.
              Logger().d("should not resume");
              break;
          }
        }
      },
    );

    session?.becomingNoisyEventStream.listen((_) {
      Logger().d("device unplug");
      final playlistController = Get.find<PlaylistController>();
      playlistController.duck(0.1);
    });
  }
}
