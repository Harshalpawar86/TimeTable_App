import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prodos_app/controller/providers/tasks_provider.dart';
import 'package:prodos_app/model/tasks.dart';
import 'package:prodos_app/view/widgets/add_task_dialog.dart';

class TaskInfoCell extends ConsumerWidget {
  final Tasks task;
  final DateTime date;
  const TaskInfoCell({super.key, required this.task, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final isCompleted = task.doneMap.values.any(
      (innerMap) => innerMap.entries.any(
        (entry) =>
            entry.key.year == date.year &&
            entry.key.month == date.month &&
            entry.key.day == date.day &&
            entry.value == true,
      ),
    );

    return TextButton(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        overlayColor: WidgetStatePropertyAll(
          theme.primaryColor.withValues(alpha: 0.08),
        ),
      ),
      onPressed: () async {
        Tasks? updatedTask = await showDialog(
          context: context,
          builder: (context) {
            return AddTaskDialog(
              prevTask: task,
              range: null,
              fromCalendarScreen: true,
              dateFromCalendarScreen: date,
            );
          },
        );
        if (updatedTask != null) {
          try {
            ref.read(tasksProvider.notifier).updateTask(updatedTask);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Something Went Wrong Please try again later...",
                  ),
                ),
              );
            }
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            task.time.format(context),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isCompleted ? "Completed" : "Not Completed",
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCompleted ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
