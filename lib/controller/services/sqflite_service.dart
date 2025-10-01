import 'package:path/path.dart' as path;
import 'package:prodos_app/controller/services/notify_service.dart';
import 'package:prodos_app/model/tasks.dart';
import 'package:sqflite/sqflite.dart' as sq;
import 'package:sqflite/sqlite_api.dart';

class SQFliteService {
  static final SQFliteService _instance = SQFliteService._internal();
  SQFliteService._internal();
  factory SQFliteService() {
    return _instance;
  }
  late final sq.Database database;
  Future<void> initializeSQFliteDatabase() async {
    try {
      database = await sq.openDatabase(
        path.join(await sq.getDatabasesPath(), "prodosdb.db"),
        version: 1,
        onCreate: (db, version) async {
          await db.execute(''' 
            CREATE TABLE time_table(
              id TEXT PRIMARY KEY NOT NULL,
              name TEXT NOT NULL,
              time TEXT NOT NULL,
              doneMap TEXT NOT NULL,
              notifyMap NOT NULL
            );
          ''');
        },
      );
    //  log('SQFlite Service Started.....');
    } catch (e) {
  //    log("\x1B[31mError while initializing database $e");
    }
  }

  Future<List<Tasks>> getAllTasks() async {
    try {
      final sq.Database localDb = database;
      List<Map<String, dynamic>> list = await localDb.query('time_table');
      List<Tasks> tasksList = [];
      for (Map<String, dynamic> data in list) {
        tasksList.add(await Tasks.toObj(data));
      }
     // log("$tasksList");
     // for (Tasks task in tasksList) {
     //   log("Notification Ids : ${task.doneMap.keys}");
     // }
      return tasksList;
    } catch (e) {
    //  log('\x1B[31merror while getting tasks :$e');
      return [];
    }
  }

  Future<bool> addTaskToDatabase(Tasks task) async {
    try {
      final sq.Database localDb = database;
      await localDb.insert(
        'time_table',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await NotifyService().scheduleNotificationsFromMap(task);
      return true;
    } catch (e) {
     // log('\x1B[31mError while adding tasks to sqflite :$e');
      return false;
    }
  }

  Future<bool> deleteTaskFromDatabase(String id) async {
    try {
      final sq.Database localDb = database;
      await localDb.delete('time_table', where: 'id=?', whereArgs: [id]);
      return true;
    } catch (e) {
     // log('\x1B[31mError whilde deleting Task from Database :$e');
      return false;
    }
  }

  Future<bool> updateTaskFromDatabase(Tasks task) async {
    try {
      final sq.Database localDb = database;
      await localDb.update(
        'time_table',
        task.toMap(),
        where: "id=?",
        whereArgs: [task.id],
      );
      return true;
    } catch (e) {
     // log("\x1B[31mError while updating task in database :$e");
      return false;
    }
  }

  Future<bool> deleteAll() async {
    try {
      final sq.Database localDb = database;
      await localDb.delete('time_table');
      return true;
    } catch (e) {
     // log('\x1B[31mError whilde deleting Task from Database :$e');
      return false;
    }
  }
}
