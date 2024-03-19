import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS diary(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        feeling TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'diaryawie.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createDiary(String feeling, String? description) async {
    final db = await SQLHelper.db();

    final data = {'feeling': feeling, 'description': description};
    final id = await db.insert('diary', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getDiaries() async {
    final db = await SQLHelper.db();
    return db.query('diary', orderBy: "createdAt DESC");
  }

  static Future<List<Map<String, dynamic>>> getDiary(int id) async {
    final db = await SQLHelper.db();
    return db.query('diary', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateDiary(
      int id, String feeling, String? description) async {
    final db = await SQLHelper.db();

    final data = {
      'feeling': feeling,
      'description': description,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('diary', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteDiary(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("diary", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a diary: $err");
    }
  }
}
