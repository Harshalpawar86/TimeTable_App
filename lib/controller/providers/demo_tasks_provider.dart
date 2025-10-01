import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prodos_app/model/tasks.dart';

class DemoTasksController extends StateNotifier<List<Tasks>> {
  DemoTasksController() : super([]);
  void deleteAlldata() {
    state = [];
  }

  void addDemoList(Tasks task) {
    state = [...state, task];
  }

  void updateTask(Tasks updatedTask) {
    state = state.map((Tasks task) {
      if (task.id == updatedTask.id) {
        return updatedTask;
      }
      return task;
    }).toList();
  }

  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }
}

StateNotifierProvider<DemoTasksController, List<Tasks>> demoTasksProvider =
    StateNotifierProvider<DemoTasksController, List<Tasks>>((Ref ref) {
      return DemoTasksController();
    });
