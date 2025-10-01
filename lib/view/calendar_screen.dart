import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prodos_app/controller/providers/calendar_view_provider.dart';
import 'package:prodos_app/controller/providers/tasks_provider.dart';
import 'package:prodos_app/model/calendar_view.dart';
import 'package:prodos_app/model/tasks.dart';
import 'package:prodos_app/view/widgets/header_cell.dart';
import 'package:prodos_app/view/widgets/task_info_cell.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  List<TableRow> buildTaskRows(
    DateTime start,
    DateTime end,
    List<Tasks> allTasks,
  ) {
    final days = getDaysWithTasksInRange(start, end, allTasks);

    final Map<DateTime, List<Tasks>> tasksPerDay = {};
    int maxTasks = 0;
    for (final day in days) {
      final dayTasks = allTasks.where((task) {
        return task.doneMap.values.any(
          (innerMap) => innerMap.keys.any((keyDate) {
            if (keyDate.year == day.year &&
                keyDate.month == day.month &&
                keyDate.day == day.day) {
              return true;
            } else {
              return false;
            }
          }),
        );
      }).toList();

      tasksPerDay[day] = dayTasks;
      if (dayTasks.length > maxTasks) {
        maxTasks = dayTasks.length;
      }
    }

    return List.generate(maxTasks, (taskIndex) {
      return TableRow(
        children: days.map((day) {
          final tasks = tasksPerDay[day] ?? [];
          if (taskIndex < tasks.length) {
            return TaskInfoCell(task: tasks[taskIndex], date: day);
          } else {
            return const SizedBox(); 
          }
        }).toList(),
      );
    });
  }

  String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date); 
  }

  String getFormattedDate(DateTime date) {
    String day = date.day.toString();
    String suffix = getDaySuffix(date.day);
    String month = DateFormat('MMM').format(date); 
    String year = DateFormat('yyyy').format(date);

    return "$day$suffix $month $year"; 
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return "th"; 
    }
    switch (day % 10) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }

  List<DateTime> getDaysWithTasksInRange(
    DateTime start,
    DateTime end,
    List<Tasks> allTasks,
  ) {
    List<DateTime> days = [];
    DateTime current = start;

    while (!current.isAfter(end)) {
      bool hasTask = allTasks.any((task) {
        return task.doneMap.values.any(
          (innerMap) => innerMap.keys.any(
            (keyDate) =>
                keyDate.year == current.year &&
                keyDate.month == current.month &&
                keyDate.day == current.day,
          ),
        );
      });

      if (hasTask) {
        days.add(current);
      }

      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    DateTime current = start;
    while (!current.isAfter(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  List<Widget> headerCellsForRange(
    DateTime start,
    DateTime end,
    List<Tasks> allTasks,
  ) {
    return getDaysWithTasksInRange(start, end, allTasks).map((day) {
      return HeaderCell(
        day: DateFormat('EEEE').format(day),
        date: getFormattedDate(day),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      appBar: AppBar(title: const Text("Calendar View"), centerTitle: true),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Text(
                  "💡 Tip: Long press to select range..",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: Divider(color: theme.primaryColor)),
              SliverToBoxAdapter(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: theme.primaryColor.withValues(alpha: 0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                            CalendarView calendarView = ref.watch(
                              calendarViewProvider,
                            );
                            DateTime now = DateTime.now();
                            return TableCalendar(
                              firstDay: DateTime.utc(now.year - 1),
                              lastDay: DateTime.utc(now.year + 1),
                              focusedDay: calendarView.focusedDay,
                              calendarFormat: CalendarFormat.month,
                              availableCalendarFormats: {
                                CalendarFormat.month: 'Month',
                              },
                              onDaySelected:
                                  (DateTime selectedDay, DateTime focusedDay) {
                                    ref
                                        .read(calendarViewProvider.notifier)
                                        .onDaySelected(selectedDay, focusedDay);
                                  },
                              selectedDayPredicate: (DateTime day) =>
                                  isSameDay(calendarView.selectedDay, day),
                              onRangeSelected:
                                  (
                                    DateTime? start,
                                    DateTime? end,
                                    DateTime focusedDay,
                                  ) {
                                    ref
                                        .read(calendarViewProvider.notifier)
                                        .onRangeSelected(
                                          start,
                                          end,
                                          focusedDay,
                                        );
                                  },
                              rangeStartDay: calendarView.rangeStart,
                              rangeEndDay: calendarView.rangeEnd,
                              rangeSelectionMode:
                                  calendarView.rangeSelectionMode,

                              daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                                weekendStyle: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextStyle: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                leftChevronIcon: Icon(
                                  Icons.chevron_left,
                                  color: theme.primaryColor,
                                ),
                                rightChevronIcon: Icon(
                                  Icons.chevron_right,
                                  color: theme.primaryColor,
                                ),
                              ),
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: theme.primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                todayTextStyle: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                selectedTextStyle: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                rangeStartDecoration: BoxDecoration(
                                  color: const Color.fromRGBO(156, 39, 176, 1),
                                  shape: BoxShape.circle,
                                ),
                                rangeEndDecoration: BoxDecoration(
                                  color: const Color.fromRGBO(156, 39, 176, 1),
                                  shape: BoxShape.circle,
                                ),
                                withinRangeDecoration: BoxDecoration(
                                  color: const Color.fromRGBO(
                                    156,
                                    39,
                                    176,
                                    1,
                                  ).withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                defaultTextStyle: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                                weekendTextStyle: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                                outsideTextStyle: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                            );
                          },
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 15)),

              SliverToBoxAdapter(
                child: Text(
                  "💡 Tip: Click on any task to edit..",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: Divider(color: theme.primaryColor)),
              const SliverToBoxAdapter(child: SizedBox(height: 5)),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Consumer(
                    builder: (BuildContext context, WidgetRef ref, Widget? child) {
                      AsyncValue<List<Tasks>> taskRef = ref.watch(
                        tasksProvider,
                      );
                      CalendarView calendarView = ref.watch(
                        calendarViewProvider,
                      );
                      DateTimeRange? range;
                      if (calendarView.rangeStart != null &&
                          calendarView.rangeEnd != null) {
                        range = DateTimeRange(
                          start: calendarView.rangeStart!,
                          end: calendarView.rangeEnd!,
                        );
                      }

                      return taskRef.when(
                        data: (List<Tasks> tasksList) {
                          DateTime? selectedDay = calendarView.selectedDay;
                          List<Tasks> selectedDayTasks = [];
                          if (selectedDay != null) {
                            selectedDayTasks = tasksList.where((Tasks test) {
                              return test.doneMap.values.any(
                                (innerMap) => innerMap.keys.any(
                                  (DateTime keyDate) =>
                                      keyDate.year == selectedDay.year &&
                                      keyDate.month == selectedDay.month &&
                                      keyDate.day == selectedDay.day,
                                ),
                              );
                            }).toList();
                          } else {
                            if (range != null) {
                              selectedDayTasks = tasksList.where((Tasks test) {
                                return test.doneMap.values.any((innerMap) {
                                  return innerMap.keys.any((DateTime keyDate) {
                                    return !keyDate.isBefore(range!.start) &&
                                        !keyDate.isAfter(range.end);
                                  });
                                });
                              }).toList();
                            }
                          }
                          if (range == null && selectedDay == null) {
                            return const SizedBox();
                          }
                          if (selectedDayTasks.isEmpty) {
                            return const SizedBox();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Table(
                              defaultColumnWidth: const FixedColumnWidth(120),
                              border: TableBorder.all(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.05,
                                    ),
                                  ),
                                  children: (selectedDay != null)
                                      ? [
                                          HeaderCell(
                                            day: DateFormat(
                                              'EEEE',
                                            ).format(selectedDay),
                                            date: getFormattedDate(selectedDay),
                                          ),
                                        ]
                                      : headerCellsForRange(
                                          range!.start,
                                          range.end,
                                          tasksList,
                                        ),
                                ),

                                if (range != null)
                                  ...buildTaskRows(
                                    range.start,
                                    range.end,
                                    tasksList,
                                  )
                                else if (selectedDay != null)
                                  ...buildTaskRows(
                                    selectedDay,
                                    selectedDay,
                                    tasksList,
                                  ),
                              ],
                            ),
                          );
                        },
                        error: (_, error) {
                          return Center(
                            child: Text(
                              "Something went wrong please try again later...\n$error",
                            ),
                          );
                        },
                        loading: () {
                          return Shimmer.fromColors(
                            baseColor: theme.primaryColor,
                            highlightColor: Colors.white,
                            child: Container(
                              width: width,
                              height: 400,
                              color: theme.primaryColor,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
