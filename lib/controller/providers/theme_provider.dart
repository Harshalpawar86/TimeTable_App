import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final window = ui.PlatformDispatcher.instance.views.first;
    final brightness = MediaQueryData.fromView(window).platformBrightness;
    bool temp = brightness == Brightness.dark;
    bool isDark = prefs.getBool('prodosDark') ?? temp;
    return (isDark) ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = themeMode == ThemeMode.dark;
    await prefs.setBool('prodosDark', isDark);

    state = AsyncValue.data(themeMode);
  }
}

AsyncNotifierProvider<ThemeController, ThemeMode> themeProvider =
    AsyncNotifierProvider<ThemeController, ThemeMode>(() {
      return ThemeController();
    });
