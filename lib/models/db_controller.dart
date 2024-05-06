import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import './util.dart';
import './setting_controller.dart';

class DbController extends GetxController {
  static const playlistTable = "playlist";

  final settingController = Get.find<SettingController>();
  final log = Logger();
  late Database db;

  Future<void> init() async {
    await createTable(playlistTable);
  }

  Future<bool> createTable(String tableName) async {
    final sql =
        'CREATE TABLE IF NOT EXISTS $tableName (id INTEGER PRIMARY KEY, uuid TEXT NOT NULL UNIQUE, data TEXT NOT NULL)';

    try {
      if (isSqfliteSupportPlatform()) {
        db = await openDatabase(settingController.dbPath, version: 1,
            onCreate: (Database db, int version) async {
          await db.execute(sql);
        });
      } else {
        log.d("Database not implement");
        return false;
      }
    } catch (e) {
      log.w("Open database error: $e.toString()");
      return false;
    }
    return true;
  }

  Future<bool> insert(String tableName, String uuid, String data) async {
    final sql = "INSERT INTO $tableName (uuid, data) VALUES('$uuid', '$data')";

    try {
      if (isSqfliteSupportPlatform()) {
        await db.transaction(
          (txn) async {
            await txn.rawInsert(sql);
          },
        );
      } else {
        log.d("Database not implement");
        return false;
      }
    } catch (e) {
      log.w("Database insert error: $e.toString()");
      return false;
    }
    return true;
  }

  Future<bool> updateData(String tableName, String uuid, String data) async {
    final sql = "UPDATE $tableName SET data='$data' WHERE uuid='$uuid'";

    try {
      if (isSqfliteSupportPlatform()) {
        await db.rawUpdate(sql);
      } else {
        log.d("Database not implement");
        return false;
      }
    } catch (e) {
      log.w("Database update error: $e.toString()");
      return false;
    }
    return true;
  }

  Future<bool> delete(String tableName, String uuid) async {
    final sql = "DELETE FROM $tableName WHERE uuid='$uuid'";

    try {
      if (isSqfliteSupportPlatform()) {
        await db.rawDelete(sql);
      } else {
        log.d("Database not implement");
        return false;
      }
    } catch (e) {
      log.w("Database delete error: $e.toString()");
      return false;
    }
    return true;
  }

  Future<bool> deleteAll(String tableName) async {
    final sql = "DELETE FROM $tableName";

    try {
      if (isSqfliteSupportPlatform()) {
        await db.rawDelete(sql);
      } else {
        log.d("Database not implement");
        return false;
      }
    } catch (e) {
      log.w("Database delete all error: $e.toString()");
      return false;
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> select(
      String tableName, String uuid) async {
    final sql = "SELECT * FROM $tableName WHERE uuid='$uuid'";

    try {
      if (isSqfliteSupportPlatform()) {
        return await db.rawQuery(sql);
      } else {
        log.d("Database not implement");
        return [];
      }
    } catch (e) {
      log.w("Database select error: $e.toString()");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> selectAll(String tableName) async {
    final sql = "SELECT * FROM $tableName";
    try {
      if (isSqfliteSupportPlatform()) {
        return await db.rawQuery(sql);
      } else {
        log.d("Database not implement");
        return [];
      }
    } catch (e) {
      log.w("Database select all error: $e.toString()");
      return [];
    }
  }
}
