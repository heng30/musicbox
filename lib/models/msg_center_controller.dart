import 'dart:convert';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../src/rust/api/data.dart';
import '../src/rust/api/msg_center.dart';
import './find_controller.dart';

class MsgCenterController extends GetxController {
  final log = Logger();
  final Stream<MsgItem> stream = msgCenterInit();
  final findController = Get.find<FindController>();

  @override
  void onInit() {
    super.onInit();
    stream.listen(
      (item) {
        switch (item.ty) {
          case MsgType.downloadError:
            updateFindInfoListDownloadStatusToError(item.data);
            break;
          case MsgType.plainText:
            log.d(item.data);
            break;
        }
      },
      onError: (e) {
        Get.snackbar(
            "提 示".tr, "message center unexpected exit. ${e.toString()}");
      },
      onDone: () {
        Get.snackbar("提 示".tr, "message center should not exit");
      },
    );
  }

  void updateFindInfoListDownloadStatusToError(String data) async {
    final Map<String, dynamic> m = jsonDecode(data);
    if (!m.containsKey("id")) {
      return;
    }

    try {
      final info = findController.infoList.firstWhere((item) {
        return item.raw.videoId == m["id"];
      });

      if (m.containsKey("msg")) {
        Get.snackbar("下载失败".tr, "${m['msg']}\n${info.raw.title}",
            snackPosition: SnackPosition.BOTTOM);
      }

      await info.removeDownloadFailedFile();
    } catch (e) {
      log.d(e);
    }
  }
}
