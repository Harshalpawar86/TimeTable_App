import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prodos_app/controller/services/notify_service.dart';
import 'package:prodos_app/controller/services/sqflite_service.dart';
import 'package:prodos_app/model/tasks.dart';

class TasksController extends AsyncNotifier<List<Tasks>> {
  final SQFliteService _sqFliteService = SQFliteService();
  @override
  Future<List<Tasks>> build() async {
    return await _sqFliteService.getAllTasks();
  }

  Future createList(List<Tasks> tasks) async {
    List<Tasks> temp = [...(state.value ?? []), ...tasks];
    for (Tasks task in tasks) {
      if (await _sqFliteService.addTaskToDatabase(task) == false) {
        throw Exception("Something went wrong..\nPlease try again later....");
      }
    }
    state = AsyncData(temp);
  }

  Future<void> updateTask(Tasks task) async {
    if (await _sqFliteService.updateTaskFromDatabase(task)) {
      final current = state.value ?? [];

      List<Tasks> updated = await Future.wait(
        current.map((test) async {
          if (test.id == task.id) {
            Tasks updatedTask = Tasks(
              id: task.id,
              name: task.name,
              time: task.time,
              doneMap: task.doneMap,
              notifyMap: task.notifyMap,
            );

            await NotifyService().updateNotifications(
              oldObj: test,
              newObj: updatedTask,
            );

            return updatedTask;
          } else {
            return test;
          }
        }),
      );

      state = AsyncValue.data(updated);
    } else {
      throw Exception("Something went wrong..\nPlease try again later...");
    }
  }

  Future deleteTask(Tasks task) async {
    if (await _sqFliteService.deleteTaskFromDatabase(task.id)) {
      task.notifyMap.forEach((String key, int val) async {
        await NotifyService().deleteNotification(val);
      });
      final current = state.value ?? [];
      final updated = current.where((test) => test.id != task.id).toList();
      state = AsyncData(updated);
    } else {
      throw Exception("Something went wrong..\nPlease try again later...");
    }
  }

  Future<bool> deleteAll() async {
    if (await _sqFliteService.deleteAll()) {
      await NotifyService().deleteAll();
      state = AsyncData([]);
      return true;
    } else {
      throw Exception("Something went wrong..\nPlease try again later...");
    }
  }

  Future<void> deleteSingleTask(Tasks task, DateTime date) async {
    for (Map<DateTime, bool> map in task.doneMap.values) {
      map.removeWhere((datetime, boolVal) {
        return datetime.year == date.year &&
            datetime.month == date.month &&
            datetime.day == date.day;
      });
    }
    await SQFliteService().updateTaskFromDatabase(task);
    List<Tasks> temp = state.value ?? [];
    for (Tasks test in temp) {
      if (test.id == task.id) {
        await NotifyService().updateNotifications(oldObj: test, newObj: task);
        test = task;
      }
    }
    state = AsyncData(temp);
  }

  Future<void> toggleCheck(bool val, Tasks task) async {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    for (Map<DateTime, bool> map in task.doneMap.values) {
      map[date] = val;
    }
    updateTask(task);
  }
}

AsyncNotifierProvider<TasksController, List<Tasks>> tasksProvider =
    AsyncNotifierProvider<TasksController, List<Tasks>>(() {
      return TasksController();
    });
