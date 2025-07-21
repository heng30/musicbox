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
    try {
      await createDb(settingController.dbPath);
      await createTable(playlistTable);
    } catch (e) {
      log.w("init database error: $e");
    }
  }

  Future<bool> createDb(String dbPath) async {
    try {
      db = await openDatabase(dbPath, version: 1);
      return true;
    } catch (e) {
      log.w("init database error: $e");
      return false;
    }
  }

  Future<bool> deleteDb() async {
    try {
      await deleteDatabase(settingController.dbPath);
    } catch (e) {
      log.w("Delete database error: $e");
      return false;
    }
    return true;
  }

  Future<bool> closeDb() async {
    try {
      await db.close();
    } catch (e) {
      log.w("Delete database error: $e");
      return false;
    }
    return true;
  }

  Future<bool> createTable(String tableName) async {
    final sql =
        "CREATE TABLE IF NOT EXISTS $tableName (id INTEGER PRIMARY KEY, uuid TEXT NOT NULL UNIQUE, data TEXT NOT NULL)";

    try {
      await db.execute(sql);
    } catch (e) {
      log.w("Open database error: $e");
      return false;
    }
    return true;
  }

  Future<bool> insert(String tableName, String uuid, String data) async {
    final sql = "INSERT INTO $tableName (uuid, data) VALUES('$uuid', '$data')";

    try {
      await db.transaction(
        (txn) async {
          await txn.rawInsert(sql);
        },
      );
    } catch (e) {
      log.w("Database insert error: $e");
      return false;
    }
    return true;
  }

  Future<bool> updateData(String tableName, String uuid, String data) async {
    final sql = "UPDATE $tableName SET data='$data' WHERE uuid='$uuid'";

    try {
      await db.rawUpdate(sql);
    } catch (e) {
      log.w("Database update error: $e");
      return false;
    }
    return true;
  }

  Future<bool> delete(String tableName, String uuid) async {
    final sql = "DELETE FROM $tableName WHERE uuid='$uuid'";

    try {
      await db.rawDelete(sql);
    } catch (e) {
      log.w("Database delete error: $e");
      return false;
    }
    return true;
  }

  Future<bool> deleteAll(String tableName) async {
    final sql = "DELETE FROM $tableName";

    try {
      await db.rawDelete(sql);
    } catch (e) {
      log.w("Database delete all error: $e");
      return false;
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> select(
      String tableName, String uuid) async {
    final sql = "SELECT * FROM $tableName WHERE uuid='$uuid'";

    try {
      return await db.rawQuery(sql);
    } catch (e) {
      log.w("Database select error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> selectAll(String tableName) async {
    final sql = "SELECT * FROM $tableName";
    try {
      return await db.rawQuery(sql);
    } catch (e) {
      log.w("Database select all error: $e");
      return [];
    }
  }

  Future<bool> dropTable(String tableName) async {
    final sql = "DROP TABLE IF EXISTS $tableName";

    try {
      await db.execute(sql);
    } catch (e) {
      log.w("Database drop table error: $e");
      return false;
    }
    return true;
  }

  Future<int> rowCount(String tableName) async {
    final sql = "SELECT COUNT(*) FROM $tableName";

    try {
      return Sqflite.firstIntValue(await db.rawQuery(sql)) ?? 0;
    } catch (e) {
      log.w("Database row count error: $e");
      return -1;
    }
  }
}
