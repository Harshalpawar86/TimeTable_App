import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autostart/flutter_autostart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:prodos_app/controller/providers/tasks_provider.dart';
import 'package:prodos_app/controller/services/shared_pref_service.dart';
import 'package:prodos_app/model/tasks.dart';
import 'package:prodos_app/view/add_task_screen.dart';
import 'package:prodos_app/view/calendar_screen.dart';
import 'package:prodos_app/view/settings_screen.dart';
import 'package:prodos_app/view/widgets/today_grid_tile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      if (SharedPrefService().permissionPrompt() == 0) {
        checkAndPromptAutoStart(context);
      }
    });
  }

  checkAndPromptAutoStart(BuildContext context) async {
    await SharedPrefService().incrementPermissionPrompt();
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enable Autostart"),
            content: Text(
              "To make sure your reminders and notifications work reliably, "
              "please allow this app to start automatically in the background. "
              "This is required on some phones (Xiaomi, Vivo, Oppo, Huawei,etc.).",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Later"),
              ),
              TextButton(
                onPressed: () async {
                  await flutterAutoStart.showAutoStartPermissionSettings();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Open Settings"),
              ),
            ],
          );
        },
      );
    }
  }

  final FlutterAutostart flutterAutoStart = FlutterAutostart();
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "TASKTABLE",
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 5,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: theme.primaryColor,
        onTap: (int value) {
          if (value == 0) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
          } else if (value == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return SettingsScreen();
                },
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Calendar",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AddTaskScreen();
              },
            ),
          );
        },
        shape: const CircleBorder(),
        tooltip: "Add Task",
        elevation: 10,
        child: const Icon(Icons.add, size: 35),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 15)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: height / 6,
                child: Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    AsyncValue<List<Tasks>> asyncValue = ref.watch(
                      tasksProvider,
                    );
                    int count = 0;
                    int done = 0;
                    int totalCount = 0;
                    int totalDone = 0;

                    DateTime now = DateTime.now();
                    DateTime today = DateTime(now.year, now.month, now.day);
                    return asyncValue.when(
                      data: (List<Tasks> taskList) {
                        for (Tasks task in taskList) {
                          for (var action in task.doneMap.values) {
                            for (var val in action.values) {
                              totalCount++;
                              if (val) {
                                totalDone++;
                              }
                            }
                          }
                        }
                        for (Tasks task in taskList) {
                          if (task.doneMap.values.any((innerMap) {
                            DateTime now = DateTime.now();
                            return innerMap.keys.any(
                              (DateTime test) =>
                                  test.year == now.year &&
                                  test.month == now.month &&
                                  test.day == now.day,
                            );
                          })) {
                            count++;
                          }
                          if (task.isDoneOn(today)) {
                            done++;
                          }
                        }

                        return PageView(
                          controller: _pageController,
                          onPageChanged: (int value) {
                            _pageController.animateToPage(
                              value,
                              duration: const Duration(milliseconds: 60),
                              curve: Curves.bounceIn,
                            );
                          },
                          children: [
                            Container(
                              height: height / 6,
                              width: width,
                              margin: const EdgeInsets.only(left: 1, right: 1),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Today Completed Tasks :",
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: CircularPercentIndicator(
                                            radius: height / 15,
                                            lineWidth: 10.0,
                                            percent: count == 0
                                                ? 0
                                                : done / count,
                                            center: Text(
                                              "$done/$count",
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            backgroundColor: theme
                                                .colorScheme
                                                .onSurface
                                                .withAlpha(200),
                                            progressColor:
                                                theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: height / 6,
                              width: width,
                              margin: const EdgeInsets.only(left: 1, right: 1),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Total Completed Tasks :",
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: CircularPercentIndicator(
                                            radius: height / 15,
                                            lineWidth: 10.0,
                                            percent: totalCount == 0
                                                ? 0
                                                : totalDone / totalCount,
                                            center: Text(
                                              "$totalDone/$totalCount",
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            backgroundColor: theme
                                                .colorScheme
                                                .onSurface
                                                .withAlpha(200),
                                            progressColor:
                                                theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      error: (_, error) {
                        return Center(
                          child: Text(
                            "Something went wrong please try again later...\n$error",
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      loading: () {
                        return Container(
                          height: height / 6,
                          width: width,
                          margin: const EdgeInsets.only(left: 1, right: 1),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Today Completed Tasks :",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              CircularProgressIndicator(
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 5)),
            SliverToBoxAdapter(
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 2,
                  effect: WormEffect(
                    dotWidth: 10,
                    dotHeight: 10,
                    dotColor: const Color.fromRGBO(158, 158, 158, 1),
                    activeDotColor: theme.primaryColor,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Text(
                "Today's Timetable :",
                style: TextStyle(fontSize: 25),
              ),
            ),
            SliverToBoxAdapter(
              child: Divider(color: theme.colorScheme.primary),
            ),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                AsyncValue<List<Tasks>> taskProviderValue = ref.watch(
                  tasksProvider,
                );
                return taskProviderValue.when(
                  data: (tasks) {
                    List<Tasks> todayTasksList = [];
                    DateTime now = DateTime.now();
                    for (Tasks task in tasks) {
                      if (task.doneMap.values.any((innerMap) {
                        return innerMap.keys.any(
                          (test) =>
                              test.year == now.year &&
                              test.month == now.month &&
                              test.day == now.day,
                        );
                      })) {
                        todayTasksList.add(task);
                      }
                    }

                    return SliverGrid(
                      gridDelegate: SliverWovenGridDelegate.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        pattern: [
                          const WovenGridTile(1),
                          const WovenGridTile(
                            5 / 7,
                            crossAxisRatio: 0.9,
                            alignment: AlignmentDirectional.centerEnd,
                          ),
                        ],
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return TodayGridTile(task: todayTasksList[index]);
                      }, childCount: todayTasksList.length),
                    );
                  },
                  error: (Object obj, StackTrace error) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          "Something went wrong please try again later...\nerror",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: const Color.fromRGBO(244, 67, 54, 1),
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () {
                    return SliverGrid(
                      gridDelegate: SliverWovenGridDelegate.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        pattern: [
                          const WovenGridTile(1),
                          const WovenGridTile(
                            5 / 7,
                            crossAxisRatio: 0.9,
                            alignment: AlignmentDirectional.centerEnd,
                          ),
                        ],
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Shimmer.fromColors(
                          baseColor: theme.colorScheme.primary,
                          highlightColor: const Color.fromRGBO(
                            255,
                            255,
                            255,
                            1,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                              color: theme.colorScheme.primary.withAlpha(5),
                            ),
                          ),
                        );
                      }, childCount: 10),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
