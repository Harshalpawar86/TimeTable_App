import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prodos_app/controller/providers/date_range_provider.dart';
import 'package:prodos_app/controller/providers/demo_tasks_provider.dart';
import 'package:prodos_app/controller/providers/tasks_provider.dart';
import 'package:prodos_app/model/tasks.dart';
import 'package:prodos_app/view/home_screen.dart';
import 'package:prodos_app/view/widgets/add_task_dialog.dart';
import 'package:prodos_app/view/widgets/add_task_tile.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});
  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dateRangeProvider.notifier).updateRange(0);
      ref.read(demoTasksProvider.notifier).deleteAlldata();
    });
  }

  DateTimeRange? selectedRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () async {
              List<Tasks> demoList = ref.watch(demoTasksProvider);
              if (demoList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    duration: const Duration(seconds: 2),
                    content: Text(
                      "Please add some tasks first..",
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: const Color.fromRGBO(244, 67, 54, 1),
                      ),
                    ),
                  ),
                );
              } else {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Confirm Tasks",
                        style: theme.textTheme.titleMedium,
                      ),
                      content: Text(
                        "Sure you want to Confirm these Tasks ?",
                        style: theme.textTheme.titleSmall,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(tasksProvider.notifier)
                                  .createList(demoList);
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return HomeScreen();
                                    },
                                  ),
                                );
                              }
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
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              theme.colorScheme.primary,
                            ),
                          ),
                          child: Text(
                            "Yes",
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
                            "No",
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: const Color.fromRGBO(255, 255, 255, 1),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            icon: const Icon(Icons.done_outline_outlined),
          ),
          const SizedBox(width: 10),
        ],
        title: Text(
          "Add TimeTable Tasks",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          return BottomAppBar(
            color: theme.colorScheme.surface,
            elevation: 0,
            child: TextButton(
              onPressed: () async {
                if (selectedRange != null) {
                  Tasks? task = await showDialog(
                    context: context,
                    builder: (context) {
                      return AddTaskDialog(
                        prevTask: null,
                        range: selectedRange!,
                        fromCalendarScreen: false,
                        dateFromCalendarScreen: null,
                      );
                    },
                  );
                  if (task != null) {
                    ref.read(demoTasksProvider.notifier).addDemoList(task);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: theme.scaffoldBackgroundColor,
                      duration: const Duration(seconds: 2),
                      content: Text(
                        "Please select date first..",
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: const Color.fromRGBO(244, 67, 54, 1),
                        ),
                      ),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Add New"),
            ),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Date Range :", style: theme.textTheme.bodyMedium),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                return (ref.watch(demoTasksProvider).isEmpty)
                    ? Divider(color: theme.colorScheme.primary)
                    : const SizedBox();
              },
            ),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                int selectedRangeIndex = ref.watch(dateRangeProvider);
                int length = ref.watch(demoTasksProvider).length;
                return (length == 0)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                selectedRange = DateTimeRange(
                                  start: DateTime.now(),
                                  end: DateTime.now(),
                                );
                                ref
                                    .read(dateRangeProvider.notifier)
                                    .updateRange(1);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (selectedRangeIndex == 1)
                                      ? theme.colorScheme.primary
                                      : theme.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: theme.primaryColorDark,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(1, 2),
                                      color: Colors.black12,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "Only Today",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: (selectedRangeIndex == 1)
                                        ? theme.colorScheme.onPrimary
                                        : theme.textTheme.bodyLarge!.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                selectedRange = DateTimeRange(
                                  start: DateTime.now(),
                                  end: DateTime.now().add(
                                    const Duration(days: 7),
                                  ),
                                );
                                ref
                                    .read(dateRangeProvider.notifier)
                                    .updateRange(2);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (selectedRangeIndex == 2)
                                      ? theme.colorScheme.primary
                                      : theme.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: theme.primaryColorDark,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(1, 2),
                                      color: Colors.black12,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "One Week",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: (selectedRangeIndex == 2)
                                        ? theme.colorScheme.onPrimary
                                        : theme.textTheme.bodyLarge!.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                selectedRange = DateTimeRange(
                                  start: DateTime.now(),
                                  end: DateTime.now().add(Duration(days: 30)),
                                );
                                ref
                                    .read(dateRangeProvider.notifier)
                                    .updateRange(3);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (selectedRangeIndex == 3)
                                      ? theme.colorScheme.primary
                                      : theme.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: theme.primaryColorDark,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(1, 2),
                                      color: Colors.black12,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "One Month",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: (selectedRangeIndex == 3)
                                        ? theme.colorScheme.onPrimary
                                        : theme.textTheme.bodyLarge!.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                DateTimeRange? range =
                                    await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.utc(
                                        DateTime.now().year,
                                        DateTime.now().month + 3,
                                      ),
                                    );
                                if (range != null) {
                                  selectedRange = range;
                                  ref
                                      .read(dateRangeProvider.notifier)
                                      .updateRange(4);
                                } else {
                                  selectedRange = null;
                                  ref
                                      .read(dateRangeProvider.notifier)
                                      .updateRange(0);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (selectedRangeIndex == 4)
                                      ? theme.colorScheme.primary
                                      : theme.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: theme.primaryColorDark,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(1, 2),
                                      color: Colors.black12,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "Select Custom",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: (selectedRangeIndex == 4)
                                        ? theme.colorScheme.onPrimary
                                        : theme.textTheme.bodyLarge!.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox();
              },
            ),
            Divider(color: theme.colorScheme.primary),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                int selectedDateRange = ref.watch(dateRangeProvider);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: (selectedDateRange == 0)
                          ? const SizedBox()
                          : (selectedDateRange == 1)
                          ? Text(
                              DateFormat("d MMM yyyy").format(DateTime.now()),
                              style: theme.textTheme.titleMedium,
                            )
                          : (selectedRange != null)
                          ? Text(
                              "${DateFormat("d MMM yyyy").format(selectedRange!.start)} to ${DateFormat("d MMM yyyy").format(selectedRange!.end)}",
                              style: theme.textTheme.titleMedium,
                            )
                          : const SizedBox(),
                    ),
                    (selectedDateRange == 0)
                        ? const SizedBox()
                        : Divider(color: theme.colorScheme.primary),
                  ],
                );
              },
            ),
            Expanded(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  List<Tasks> list = ref.watch(demoTasksProvider);
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return AddTaskTile(task: list[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
