import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:prodos_app/model/tasks.dart';

class NotifyService {
  static final NotifyService _instance = NotifyService._internal();
  NotifyService._internal();
  factory NotifyService() {
    return _instance;
  }
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> startNotificationsService() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await _localNotificationsPlugin.initialize(initializationSettings);
    AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    bool permission =
        await androidImplementation?.areNotificationsEnabled() ?? false;
    if (!permission) {
      await androidImplementation?.requestExactAlarmsPermission();
      await androidImplementation?.requestNotificationsPermission();
    }
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> scheduleNotificationsFromMap(Tasks task) async {
    final DateTime now = DateTime.now();

    for (final entry in task.doneMap.entries) {
      final int notificationId = task.notifyMap[entry.key] ?? -1;
      if (notificationId == -1) {
        continue;
      }
      final Map<DateTime, bool> innerMap = entry.value;

      for (final date in innerMap.keys) {
        final tzDate = tz.TZDateTime(
          tz.local,
          date.year,
          date.month,
          date.day,
          task.time.hour,
          task.time.minute,
        );

        if (tzDate.isBefore(now)) continue;

        await _localNotificationsPlugin.zonedSchedule(
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          notificationId,
          'Task Reminder',
          task.name,
          tzDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'task_channel',
              'Task Notifications',
              channelDescription: 'Reminder notifications for tasks',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    }
  }

  Future<void> updateNotifications({
    required Tasks oldObj,
    required Tasks newObj,
  }) async {
    for (var val in oldObj.notifyMap.values) {
      await _localNotificationsPlugin.cancel(val);
    }

    for (MapEntry<String, int> entry in newObj.notifyMap.entries) {
      String taskId = entry.key;

      Map<DateTime, bool>? datesDoneMap = newObj.doneMap[taskId];

      bool shouldSchedule = true;
      if (datesDoneMap != null) {
        shouldSchedule = !datesDoneMap.values.contains(true);
      }

      if (shouldSchedule) {
        await scheduleNotificationsFromMap(newObj);
      }
    }
  }

  Future<void> scheduleSingleNotification(
    String name,
    TimeOfDay time,
    int id,
    DateTime date,
  ) async {
    final tzDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (tzDate.isBefore(DateTime.now())) return;

    await _localNotificationsPlugin.zonedSchedule(
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      id,
      'Task Reminder',
      name,
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Notifications',
          channelDescription: 'Reminder notifications for tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    log("Single Notification Scheduled...");
  }

  Future<void> deleteAll() async {
    await _localNotificationsPlugin.cancelAll();
  }

  Future<void> deleteNotification(int id) async {
    log("Notification deleted...");
    await _localNotificationsPlugin.cancel(id);
  }
}
