import 'dart:io' show Platform;
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

bool isDesktopPlatform() {
  return Platform.isMacOS ||
      Platform.isLinux ||
      Platform.isWindows ||
      Platform.isFuchsia;
}

bool isSqfliteSupportPlatform() {
  return Platform.isIOS || Platform.isAndroid;
}

bool isRustSqliteSupportPlatform() {
  return Platform.isLinux ||
      Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isFuchsia;
}

bool isFFmpegKitSupportPlatform() {
  return false;
}

String formattedTime(int seconds) {
  int hours = (seconds / 3600).truncate();
  int minutes = ((seconds % 3600) / 60).truncate();
  int remainingSeconds = seconds % 60;

  String m = minutes.toString().padLeft(2, '0');
  String s = remainingSeconds.toString().padLeft(2, '0');

  if (hours > 0) {
    return '$hours:$m:$s';
  } else if (minutes > 0) {
    return '$minutes:$s';
  } else {
    return '$remainingSeconds';
  }
}

String formattedNumber(int num) {
  String result = '';
  String input = num.toString();

  for (int i = input.length - 1, count = 0; i >= 0; i--) {
    result = input[i] + result;
    if (++count % 3 == 0 && i > 0) {
      result = ",$result";
    }
  }

  return result;
}

Future<void> ffmpegConvert(String input, String args, String output) async {
  if (!isFFmpegKitSupportPlatform()) {
    return;
  }
}

Future<bool> getPermission() async {
  if (Platform.isAndroid) {
    final androidVersion = await DeviceInfoPlugin().androidInfo;
    if (androidVersion.version.sdkInt >= 30) {
      await Permission.manageExternalStorage.request();
      if (!(await Permission.manageExternalStorage.isGranted)) {
        Get.snackbar("提 示".tr, "请赋予管理外部存储权限，否则无法保存下载文件".tr,
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } else {
      await Permission.storage.request();
      if (!(await Permission.storage.isGranted)) {
        Get.snackbar("提 示".tr, "请赋予管理外部存储权限，否则无法保存下载文件".tr,
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    }
  }

  return true;
}
