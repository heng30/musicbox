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
    final createTableSql =
        'CREATE TABLE $tableName (id INTEGER PRIMARY KEY, uuid TEXT NOT NULL UNIQUE, data TEXT NOT NULL)';

    try {
      if (isSqfliteSupportPlatform()) {
        db = await openDatabase(settingController.dbPath, version: 1,
            onCreate: (Database db, int version) async {
          await db.execute(createTableSql);
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
    try {
      if (isSqfliteSupportPlatform()) {
        await db.readTransaction(
          (txn) async {
            await txn.rawInsert(
                'INSERT INTO $tableName (uuid, data) VALUES(?, ?)',
                [uuid, data]);
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
    try {
      if (isSqfliteSupportPlatform()) {
        await db.rawUpdate(
            'UPDATE $tableName SET data=? WHERE uuid=?', [data, uuid]);
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
    try {
      if (isSqfliteSupportPlatform()) {
        await db.rawDelete('DELETE FROM $tableName WHERE uuid = ?', [uuid]);
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
    try {
      if (isSqfliteSupportPlatform()) {
        await db.rawDelete('DELETE FROM $tableName');
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

  Future<List<Map>?> select(String tableName, String uuid) async {
    try {
      if (isSqfliteSupportPlatform()) {
        return await db
            .rawQuery('SELECT * FROM $tableName WHERE uuid = ?', [uuid]);
      } else {
        log.d("Database not implement");
        return null;
      }
    } catch (e) {
      log.w("Database select error: $e.toString()");
      return null;
    }
  }

  Future<List<Map>?> selectAll(String tableName) async {
    try {
      if (isSqfliteSupportPlatform()) {
        return await db.rawQuery('SELECT * FROM $tableName');
      } else {
        log.d("Database not implement");
        return null;
      }
    } catch (e) {
      log.w("Database select all error: $e.toString()");
      return null;
    }
  }
}
