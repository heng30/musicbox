import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import './util.dart';
import './setting_controller.dart';
import '../src/rust/api/db.dart' as rustdb;

class DbController extends GetxController {
  static const playlistTable = "playlist";

  final settingController = Get.find<SettingController>();
  final log = Logger();
  late Database db;

  Future<void> init() async {
    try {
      if (isSqfliteSupportPlatform()) {
        await createDb(settingController.dbPath);
        await createTable(playlistTable);
      } else if (isRustSqliteSupportPlatform()) {
        await rustdb.createDb(dbPath: settingController.dbPath);
        await createTable(playlistTable);
      } else {
        log.d("Database not implement");
      }
    } catch (e) {
      log.w("init database error: $e");
    }
  }

  Future<bool> createDb(String dbPath) async {
    try {
      if (isSqfliteSupportPlatform()) {
        db = await openDatabase(dbPath, version: 1);
        return true;
      } else if (isRustSqliteSupportPlatform()) {
        await rustdb.createDb(dbPath: settingController.dbPath);
        return true;
      } else {
        log.d("Create database not implement");
        return false;
      }
    } catch (e) {
      log.w("init database error: $e");
      return false;
    }
  }

  Future<bool> deleteDb() async {
    try {
      if (isSqfliteSupportPlatform()) {
        await deleteDatabase(settingController.dbPath);
      } else if (isRustSqliteSupportPlatform()) {
        await rustdb.deleteDb(dbPath: settingController.dbPath);
      } else {
        log.d("Database not implement");
      }
    } catch (e) {
      log.w("Delete database error: $e");
      return false;
    }
    return true;
  }

  Future<bool> closeDb() async {
    try {
      if (isSqfliteSupportPlatform()) {
        await db.close();
      } else if (isRustSqliteSupportPlatform()) {
        await rustdb.closeDb();
      } else {
        log.d("Database not implement");
      }
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
      if (isSqfliteSupportPlatform()) {
        await db.execute(sql);
      } else if (isRustSqliteSupportPlatform()) {
        await rustdb.createTable(sql: sql);
      } else {
        log.d("Database not implement");
        return false;
      }
    } catch (e) {
      log.w("Open database error: $e");
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
      } else if (isRustSqliteSupportPlatform()) {
        await rustdb.insert(sql: sql);
      } else {
        log.d("Database not implement");
        return false;
      }
    } catch (e) {
      log.w("Database insert error: $e");
      return false;
    }
    return true;
  }

  Future<bool> updateData(String tableName, String uuid, String data) async {
    final sql = "UPDATE $tableName SET data='$data' WHERE uuid='$uuid'";

    try {
      if (isSqfliteSupportPlatform()) {
        await db.rawUpdate(sql);
      } else if (isRustSqliteSupportPlatform()) {
        await rustdb.update(sql: sql);
      } else {
        log.d("Database not implement");
        return false;
      }
    } catch (e) {
      log.w("Database update error: $e");
      return false;
    }
    return true;
  }

  Future<bool> delete(String tableName, String uuid) async {
    final sql = "DELETE FROM $tableName WHERE uuid='$uuid'";

    try {
      if (isSqfliteSupportPlatform()) {
        await db.rawDelete(sql);
      } else if (isRustSqliteSupportPlatform()) {
        await rustdb.delete(sql: sql);
      } else {
        log.d("Database not implement");
        return false;
      }
    } catch (e) {
      log.w("Database delete error: $e");
      return false;
    }
    return true;
  }

  Future<bool> deleteAll(String tableName) async {
    final sql = "DELETE FROM $tableName";

    try {
      if (isSqfliteSupportPlatform()) {
        await db.rawDelete(sql);
      } else if (isRustSqliteSupportPlatform()) {
        await rustdb.deleteAll(sql: sql);
      } else {
        log.d("Database delete all not implement");
        return false;
      }
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
      if (isSqfliteSupportPlatform()) {
        return await db.rawQuery(sql);
      } else if (isRustSqliteSupportPlatform()) {
        return await rustdb.select(sql: sql);
      } else {
        log.d("Database not implement");
        return [];
      }
    } catch (e) {
      log.w("Database select error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> selectAll(String tableName) async {
    final sql = "SELECT * FROM $tableName";
    try {
      if (isSqfliteSupportPlatform()) {
        return await db.rawQuery(sql);
      } else if (isRustSqliteSupportPlatform()) {
        return await rustdb.selectAll(sql: sql);
      } else {
        log.d("Database select all not implement");
        return [];
      }
    } catch (e) {
      log.w("Database select all error: $e");
      return [];
    }
  }

  Future<bool> dropTable(String tableName) async {
    final sql = "DROP TABLE IF EXISTS $tableName";

    try {
      if (isSqfliteSupportPlatform()) {
        await db.execute(sql);
      } else if (isRustSqliteSupportPlatform()) {
        await rustdb.dropTable(sql: sql);
      } else {
        log.d("Database drop table not implement");
        return false;
      }
    } catch (e) {
      log.w("Database drop table error: $e");
      return false;
    }
    return true;
  }

  Future<int> rowCount(String tableName) async {
    final sql = "SELECT COUNT(*) FROM $tableName";

    try {
      if (isSqfliteSupportPlatform()) {
        return Sqflite.firstIntValue(await db.rawQuery(sql)) ?? 0;
      } else if (isRustSqliteSupportPlatform()) {
        return await rustdb.rowCount(sql: sql);
      } else {
        log.d("Database not implement");
        return -1;
      }
    } catch (e) {
      log.w("Database row count error: $e");
      return -1;
    }
  }
}
