import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prodos_app/controller/providers/tasks_provider.dart';
import 'package:prodos_app/controller/services/shared_pref_service.dart';
import 'package:prodos_app/model/tasks.dart';
import 'package:uuid/uuid.dart';

class AddTaskDialog extends StatefulWidget {
  final Tasks? prevTask;
  final DateTimeRange? range;
  final bool fromCalendarScreen;
  final DateTime? dateFromCalendarScreen;
  const AddTaskDialog({
    super.key,
    required this.prevTask,
    required this.range,
    required this.fromCalendarScreen,
    required this.dateFromCalendarScreen,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _taskController = TextEditingController();

  final TextEditingController _timeController = TextEditingController();

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  Future<Map<String, Map<DateTime, bool>>> filterMap(
    DateTimeRange range,
  ) async {
    Map<String, Map<DateTime, bool>> result = {};

    String id =
        "notifyId_${Uuid().v4()}_${DateTime.now().millisecondsSinceEpoch}";
    DateTime current = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );

    DateTime end = DateTime(range.end.year, range.end.month, range.end.day);

    while (!current.isAfter(end)) {
      result[id] = {current: false};
      id = "notifyId_${Uuid().v4()}_${DateTime.now().millisecondsSinceEpoch}";
      current = current.add(const Duration(days: 1));
    }

    return result;
  }

  Future<Map<String, int>> getNotifyMap(
    Map<String, Map<DateTime, bool>> doneMap,
  ) async {
    int id = SharedPrefService().getNewId();
    Map<String, int> notifyMap = {};
    doneMap.forEach((String key, Map<DateTime, bool> value) {
      notifyMap[key] = id;
      id++;
    });
    await SharedPrefService().setNewId(id);
    return notifyMap;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Tasks? task = widget.prevTask;
      if (task != null) {
        _taskController.text = task.name;
        _timeController.text = task.time.format(context);
        selectedTime = task.time;
      }
    });
  }

  TimeOfDay? selectedTime;
  int? intKey;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Enter Details",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              (widget.fromCalendarScreen)
                  ? IconButton(
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
                                Consumer(
                                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          spacing: 5,
                                          children: [
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  if (widget.dateFromCalendarScreen !=
                                                          null &&
                                                      widget.prevTask != null) {
                                                    await ref
                                                        .read(
                                                          tasksProvider
                                                              .notifier,
                                                        )
                                                        .deleteSingleTask(
                                                          widget.prevTask!,
                                                          widget
                                                              .dateFromCalendarScreen!,
                                                        );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Something Went Wrong Please try again later...",
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                      const Color.fromRGBO(
                                                        244,
                                                        67,
                                                        54,
                                                        1,
                                                      ),
                                                    ),
                                              ),
                                              child: Text(
                                                "Delete",
                                                style: theme
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      color:
                                                          const Color.fromRGBO(
                                                            255,
                                                            255,
                                                            255,
                                                            1,
                                                          ),
                                                    ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (Navigator.canPop(context)) {
                                                  Navigator.pop(context);
                                                }
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                      theme.colorScheme.primary,
                                                    ),
                                              ),
                                              child: Text(
                                                "Cancel",
                                                style: theme
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      color:
                                                          const Color.fromRGBO(
                                                            255,
                                                            255,
                                                            255,
                                                            1,
                                                          ),
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(color: theme.primaryColor),
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              ref
                                                  .read(tasksProvider.notifier)
                                                  .deleteTask(widget.prevTask!);
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Something Went Wrong Please try again later...",
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                  const Color.fromRGBO(
                                                    244,
                                                    67,
                                                    54,
                                                    1,
                                                  ),
                                                ),
                                          ),
                                          child: Text(
                                            "Delete for all dates",
                                            style: theme.textTheme.bodyLarge!
                                                .copyWith(
                                                  color: const Color.fromRGBO(
                                                    255,
                                                    255,
                                                    255,
                                                    1,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        if (context.mounted) {
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Color.fromRGBO(244, 67, 54, 1),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          Divider(color: theme.colorScheme.primary),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Form(
            key: _globalKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Task Name", style: theme.textTheme.bodyMedium),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    controller: _taskController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter task name";
                      }
                      return null;
                    },
                    textAlign: TextAlign.start,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: theme.colorScheme.error),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Text("Enter Time", style: theme.textTheme.bodyMedium),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    readOnly: true,
                    controller: _timeController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please select task time";
                      }
                      return null;
                    },
                    onTap: () async {
                      selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        if (context.mounted) {
                          _timeController.text = selectedTime!.format(context);
                        }
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: theme.colorScheme.error),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 10,
                      children: [
                        TextButton(
                          onPressed: () async {
                            if (_globalKey.currentState!.validate()) {
                              if (widget.prevTask == null) {
                                Map<String, Map<DateTime, bool>> doneMap =
                                    await filterMap(widget.range!);
                                Map<String, int> notifyMap = await getNotifyMap(
                                  doneMap,
                                );
                                if (context.mounted) {
                                  Navigator.of(context).pop(
                                    Tasks(
                                      id: "${Uuid().v4()}_${DateTime.now().millisecondsSinceEpoch}",
                                      name: _taskController.text,
                                      time: selectedTime!,
                                      doneMap: doneMap,
                                      notifyMap: notifyMap,
                                    ),
                                  );
                                }
                              } else {
                                Navigator.of(context).pop(
                                  Tasks(
                                    id: widget.prevTask!.id,
                                    name: _taskController.text,
                                    time: selectedTime!,
                                    doneMap: widget.prevTask!.doneMap,
                                    notifyMap: widget.prevTask!.notifyMap,
                                  ),
                                );
                              }
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              theme.colorScheme.primary,
                            ),
                          ),
                          child: Text(
                            (widget.prevTask == null) ? "Add" : "Update",
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: const Color.fromRGBO(255, 255, 255, 1),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
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
                            "Cancel",
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: const Color.fromRGBO(255, 255, 255, 1),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
