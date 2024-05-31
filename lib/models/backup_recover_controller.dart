import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../theme/theme.dart';
import '../models/util.dart';
import '../models/setting_controller.dart';

class BackupREcoverController extends GetxController {
  String? backupDir;

  Future<bool> createBackupDir() async {
    try {
      if (Platform.isAndroid) {
        if (!(await getPermission())) {
          return false;
        }

        final pname = (await PackageInfo.fromPlatform()).packageName;
        final d = Directory("/storage/emulated/0/$pname/backup");

        if (!(await d.exists())) {
          await d.create(recursive: true);
        }

        backupDir = d.path;
      } else {
        final tmpDir = await getDownloadsDirectory() ??
            await getApplicationCacheDirectory();

        final d = Directory("${tmpDir.path}/backup");

        if (!(await d.exists())) {
          await d.create(recursive: true);
        }

        backupDir = d.path;
      }
      return true;
    } catch (e) {
      Get.snackbar("创建备份目录失败".tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<void> _backup() async {
    await createBackupDir();
    if (backupDir == null) {
      return;
    }

    final settingController = Get.find<SettingController>();
    final configFile = File(settingController.configPath);
    final dbFile = File(settingController.dbPath);

    final configName = basename(settingController.configPath);
    final backupConfigFile = File("$backupDir/$configName");

    final dbName = basename(settingController.dbPath);
    final backupDbFile = File("$backupDir/$dbName");

    try {
      if (await backupConfigFile.exists()) {
        final bakFile = "$backupDir/$configName.bak";
        backupConfigFile.rename(bakFile);
      }

      if (await backupDbFile.exists()) {
        final bakFile = "$backupDir/$dbName.bak";
        backupDbFile.rename(bakFile);
      }

      if (await configFile.exists()) {
        final bakFile = "$backupDir/$configName";
        await configFile.copy(bakFile);
      }

      if (await dbFile.exists()) {
        final bakFile = "$backupDir/$dbName";
        await dbFile.copy(bakFile);
      }

      Get.snackbar("提 示".tr, "备份成功".tr, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("备份失败".tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<bool> _recover() async {
    await createBackupDir();
    if (backupDir == null) {
      Get.snackbar("提 示".tr, "没有备份文件".tr, snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    final settingController = Get.find<SettingController>();

    final configName = basename(settingController.configPath);
    final backupConfigFile = File("$backupDir/$configName");

    final dbName = basename(settingController.dbPath);
    final backupDbFile = File("$backupDir/$dbName");

    try {
      if (await backupConfigFile.exists()) {
        await backupConfigFile.copy(settingController.configPath);
      }

      final shmFile = File("${settingController.dbPath}-shm");
      if (await shmFile.exists()) {
        await shmFile.delete();
      }

      final walFile = File("${settingController.dbPath}-wal");
      if (await walFile.exists()) {
        await walFile.delete();
      }

      if (await backupDbFile.exists()) {
        await backupDbFile.copy(settingController.dbPath);
      }
      return true;
    } catch (e) {
      Get.snackbar("恢复失败".tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  void showBackupDialog() {
    Get.defaultDialog(
      title: "提 示".tr,
      middleText: '${"是否备份".tr}?',
      confirm: ElevatedButton(
        onPressed: () async {
          Get.closeAllSnackbars();
          Get.back();
          await _backup();
        },
        child: Obx(
          () => Text(
            "确定备份".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: Obx(
          () => Text(
            "取消".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
    );
  }

  void showRecoverDialog() {
    Get.defaultDialog(
      title: "提 示".tr,
      middleText: '${"是否恢复".tr}?',
      confirm: ElevatedButton(
        onPressed: () async {
          Get.closeAllSnackbars();
          Get.back();
          if (await _recover()) {
            showRebootDialog();
          }
        },
        child: Obx(
          () => Text(
            "确定恢复".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: Obx(
          () => Text(
            "取消".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
    );
  }

  void showRebootDialog() {
    Get.defaultDialog(
      title: "提 示".tr,
      middleText: '${"恢复成功，请重启程序".tr}?',
      barrierDismissible: false,
      confirm: ElevatedButton(
        onPressed: () async {
          Get.closeAllSnackbars();
          Get.back();
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
        child: Obx(
          () => Text(
            "确定重启".tr,
            style: TextStyle(color: CTheme.inversePrimary),
          ),
        ),
      ),
    );
  }
}
