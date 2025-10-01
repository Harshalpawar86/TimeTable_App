import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prodos_app/controller/providers/demo_tasks_provider.dart';
import 'package:prodos_app/model/tasks.dart';
import 'package:prodos_app/view/widgets/add_task_dialog.dart';

class AddTaskTile extends ConsumerWidget {
  final Tasks task;
  const AddTaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double width = MediaQuery.of(context).size.width;
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor,
              offset: Offset(0, 0),
              blurRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 6),
            Container(
              height: 60,
              width: 60,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor),
                image: DecorationImage(
                  image: AssetImage('assets/photos/Clock.png'),
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(task.name, style: theme.textTheme.titleLarge),
                  Text(
                    task.time.format(context),
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: (!task.time.isBefore(TimeOfDay.now()))
                          ? theme.primaryColor
                          : const Color.fromRGBO(244, 67, 54, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () async {
                    Tasks? updatedTask = await showDialog(
                      context: context,
                      builder: (context) {
                        return AddTaskDialog(
                          prevTask: task,
                          range: null,
                          fromCalendarScreen: false,
                          dateFromCalendarScreen: null,
                        );
                      },
                    );
                    if (updatedTask != null) {
                      ref
                          .read(demoTasksProvider.notifier)
                          .updateTask(updatedTask);
                    }
                  },
                  icon: Icon(Icons.edit, color: theme.primaryColor),
                ),
                IconButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "Delete Task",
                            style: theme.textTheme.titleMedium,
                          ),
                          content: Text(
                            "Sure you want to Delete this Task ?",
                            style: theme.textTheme.titleSmall,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(demoTasksProvider.notifier)
                                    .deleteTask(task.id);
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  const Color.fromRGBO(244, 67, 54, 1),
                                ),
                              ),
                              child: Text(
                                "Delete",
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  theme.colorScheme.primary,
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.delete,
                    color: const Color.fromRGBO(244, 67, 54, 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
