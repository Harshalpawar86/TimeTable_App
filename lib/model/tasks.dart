import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Tasks {
  final String id;
  final String name;
  final TimeOfDay time;
  final Map<String, Map<DateTime, bool>> doneMap;
  final Map<String, int> notifyMap;
  const Tasks({
    required this.id,
    required this.name,
    required this.time,
    required this.doneMap,
    required this.notifyMap,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': timeToString(time),
      'doneMap': nestedMapToString(doneMap),
      'notifyMap': mapToString(notifyMap),
    };
  }

  static Future<Tasks> toObj(Map<String, dynamic> map) async {
    return Tasks(
      id: map['id'],
      name: map['name'],
      time: stringToTime(map['time']),
      doneMap: await stringToNestedMap(map['doneMap']),
      notifyMap: await stringFromMap(map['notifyMap']),
    );
  }

  static Future<Map<String, int>> stringFromMap(String str) async {
    return await jsonDecode(str);
  }

  String mapToString(Map<String, int> map) {
    return jsonEncode(map);
  }

  String timeToString(TimeOfDay time) {
    return "${time.hour}:${time.minute}";
  }

  static TimeOfDay stringToTime(String timeString) {
    List<String> timeList = timeString.split(':');
    int hour = int.parse(timeList[0]);
    int minute = int.parse(timeList[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  String nestedMapToString(Map<String, Map<DateTime, bool>> map) {
    Map<String, dynamic> outerMap = {};

    map.forEach((id, innerMap) {
      Map<String, String> newInner = {};
      innerMap.forEach((date, value) {
        newInner[DateFormat('yyyy-MM-dd').format(date)] = value.toString();
      });
      outerMap[id.toString()] = newInner;
    });

    return jsonEncode(outerMap);
  }

  static Future<Map<String, Map<DateTime, bool>>> stringToNestedMap(
    String mapString,
  ) async {
    if (mapString.isEmpty) return {};

    final decoded = jsonDecode(mapString);
    if (decoded is! Map) return {};

    Map<String, Map<DateTime, bool>> newMap = {};
    decoded.forEach((idKey, innerMap) {
      Map<DateTime, bool> parsedInner = {};
      if (innerMap is Map<String, dynamic>) {
        innerMap.forEach((dateStr, value) {
          DateTime date = DateFormat('yyyy-MM-dd').parseStrict(dateStr);
          bool boolValue = (value.toString().toLowerCase() == 'true');
          parsedInner[date] = boolValue;
        });
      }
      newMap[idKey] = parsedInner;
    });
    return newMap;
  }

  bool isDoneOn(DateTime date) {
    for (Map<DateTime, bool> innerMap in doneMap.values) {
      if (innerMap[date] == true) return true;
    }
    return false;
  }
}