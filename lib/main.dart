import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prodos_app/app_theme.dart';
import 'package:prodos_app/controller/providers/theme_provider.dart';
import 'package:prodos_app/controller/services/notify_service.dart';
import 'package:prodos_app/controller/services/shared_pref_service.dart';
import 'package:prodos_app/controller/services/sqflite_service.dart';
import 'package:prodos_app/view/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SQFliteService().initializeSQFliteDatabase();
  await NotifyService().startNotificationsService();
  await SharedPrefService().startPrefs();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppTheme appTheme = AppTheme();
    AsyncValue<ThemeMode> theme = ref.watch(themeProvider);
    return theme.when(
      data: (ThemeMode themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomeScreen(),
          theme: appTheme.lightTheme,
          darkTheme: appTheme.darkTheme,
          themeMode: themeMode,
        );
      },
      error: (_, error) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text("Something went wrong install again :error"),
            ),
          ),
        );
      },
      loading: () {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: appTheme.lightTheme.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}