import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prodos_app/controller/providers/tasks_provider.dart';
import 'package:prodos_app/model/tasks.dart';

class TodayGridTile extends ConsumerWidget {
  final Tasks task;
  const TodayGridTile({super.key, required this.task});
  bool getDoneValue(Map<String, Map<DateTime, bool>> doneMap, DateTime date) {
    for (MapEntry<String, Map<DateTime, bool>> entry in doneMap.entries) {
      if (entry.value.containsKey(date)) {
        return entry.value[date] ?? false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = DateTime.now();
    final DateTime date = DateTime(now.year, now.month, now.day);

    ThemeData theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;
    Tasks obj = ref
        .watch(tasksProvider)
        .value!
        .firstWhere(
          (Tasks element) {
            return element.id == task.id;
          },
          orElse: () {
            return Tasks(
              id: '',
              name: '',
              time: TimeOfDay(hour: 0, minute: 0),
              doneMap: {},
              notifyMap: {},
            );
          },
        );
    bool checkValue;
    if (obj.id.isNotEmpty) {
      checkValue = getDoneValue(obj.doneMap, date);
    } else {
      checkValue = false;
    }

    return GridTile(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
          color: theme.colorScheme.primary.withAlpha(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        "Done",
                        softWrap: true,
                        maxLines: 3,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Checkbox(
                      value: checkValue,
                      onChanged: (bool? value) async {
                        try {
                          log("Value : $value");
                          await ref
                              .read(tasksProvider.notifier)
                              .toggleCheck(value ?? false, task);
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
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: theme.colorScheme.primary),
            Expanded(
              flex: 7,
              child: GestureDetector(
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          "Task Details",
                          style: theme.textTheme.titleLarge,
                        ),
                        content: SizedBox(
                          width: width - 50,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  task.name,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  task.time.format(context),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    task.name,
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
            ),
            Divider(color: theme.colorScheme.primary),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  task.time.format(context),
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: (task.time.isBefore(TimeOfDay.now()))
                        ? Colors.red
                        : theme.textTheme.bodyLarge!.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
