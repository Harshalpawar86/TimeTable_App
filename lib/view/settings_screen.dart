import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_autostart/flutter_autostart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prodos_app/controller/providers/tasks_provider.dart';
import 'package:prodos_app/controller/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          "Settings",
          style: theme.textTheme.titleLarge!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            children: [
              Expanded(
                flex: 0,
                child: Container(
                  margin: EdgeInsets.only(left: 5, right: 5),
                  width: width,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withAlpha(230),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Change Theme",
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: Consumer(
                          builder: (context, ref, child) {
                            AsyncValue<ThemeMode> themeMode = ref.watch(
                              themeProvider,
                            );
                            String str = (themeMode.value == ThemeMode.light)
                                ? "Light Mode"
                                : "Dark Mode";
                            return DropdownButton(
                              alignment: Alignment.centerRight,
                              iconDisabledColor: Colors.white,
                              iconEnabledColor: Colors.white,
                              onChanged: (value) {
                                if (value == 1) {
                                  if (themeMode.value == ThemeMode.dark) {
                                    ref
                                        .read(themeProvider.notifier)
                                        .toggleTheme(ThemeMode.light);
                                  }
                                } else if (value == 2) {
                                  if (themeMode.value == ThemeMode.light) {
                                    ref
                                        .read(themeProvider.notifier)
                                        .toggleTheme(ThemeMode.dark);
                                  }
                                }
                              },
                              hint: Text(
                                str,
                                style: theme.textTheme.labelLarge!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(
                                    "Light Mode",
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text(
                                    "Dark Mode",
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: GestureDetector(
                  onTap: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            "Permissions Required",
                            style: theme.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "To ensure reminders work reliably, please allow the following permissions : ",
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 5),
                                Divider(color: theme.primaryColor),
                                const SizedBox(height: 5),
                                Text(
                                  "• Notifications Access",
                                  style: theme.textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await AppSettings.openAppSettings(
                                      type: AppSettingsType.notification,
                                    );
                                  },
                                  style: ButtonStyle(
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(5),
                                      ),
                                    ),
                                    backgroundColor: WidgetStatePropertyAll(
                                      theme.primaryColor,
                                    ),
                                  ),
                                  child: Text(
                                    "Notification Settings",
                                    style: theme.textTheme.titleSmall!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromRGBO(
                                        255,
                                        255,
                                        255,
                                        1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "• Background AutoStart Access",
                                  style: theme.textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await FlutterAutostart()
                                        .showAutoStartPermissionSettings();
                                  },
                                  style: ButtonStyle(
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(5),
                                      ),
                                    ),
                                    backgroundColor: WidgetStatePropertyAll(
                                      theme.primaryColor,
                                    ),
                                  ),
                                  child: Text(
                                    "Background Autostart Settings",
                                    style: theme.textTheme.titleSmall!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromRGBO(
                                        255,
                                        255,
                                        255,
                                        1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "• Battery Optimization (Remove Restrictions)",
                                  style: theme.textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await AppSettings.openAppSettings(
                                      type: AppSettingsType.batteryOptimization,
                                    );
                                  },
                                  style: ButtonStyle(
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(5),
                                      ),
                                    ),
                                    backgroundColor: WidgetStatePropertyAll(
                                      theme.primaryColor,
                                    ),
                                  ),
                                  child: Text(
                                    "Battery Optimization Settings",
                                    style: theme.textTheme.titleSmall!.copyWith(
                                      fontWeight: FontWeight.bold,
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
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  theme.primaryColor,
                                ),
                              ),
                              child: const Text(
                                "Done",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    width: width,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(230),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Notifications",
                            style: theme.textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    return GestureDetector(
                      onTap: () async {
                        await showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => AlertDialog(
                            title: Text(
                              "Delete All Data!!",
                              style: theme.textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              "This action will permanently delete all app data. "
                              "This cannot be undone. Are you sure you want to proceed?",
                              style: theme.textTheme.titleMedium,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    theme.primaryColor,
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: const Color.fromRGBO(
                                      255,
                                      255,
                                      255,
                                      1,
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(
                                    244,
                                    67,
                                    54,
                                    1,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await ref
                                        .read(tasksProvider.notifier)
                                        .deleteAll();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              theme.scaffoldBackgroundColor,
                                          duration: const Duration(seconds: 2),
                                          content: Text(
                                            "All tasks deleted ..",
                                            style: theme.textTheme.bodyLarge!
                                                .copyWith(
                                                  color: const Color.fromRGBO(
                                                    244,
                                                    67,
                                                    54,
                                                    1,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      );
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }
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
                                child: Text(
                                  "Delete",
                                  style: theme.textTheme.bodyMedium!.copyWith(
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
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 5, right: 5),
                        width: width,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withAlpha(230),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Reset Data",
                                style: theme.textTheme.titleLarge!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.delete,
                              color: Color.fromRGBO(244, 67, 54, 1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                flex: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyPolicyPage(),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    width: width,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(230),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Privacy Policy",
                            style: theme.textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: GestureDetector(
                  onTap: () async {
                    Uri url = Uri.parse('https://buymeacoffee.com/prodosapp');
                    if (await launcher.canLaunchUrl(url)) {
                      await launcher.launchUrl(
                        url,
                        mode: launcher.LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Could not open link , try later.."),
                          ),
                        );
                      }
                    }
                  },

                  child: Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    width: width,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(230),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Buy us a Coffee",
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const Icon(
                          Icons.coffee,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Coming Soon ...")),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    width: width,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(230),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "More apps from us...",
                            style: theme.textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ],
                    ),
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

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Last updated: September 21, 2025",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              "1. Data Collection",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Our app does not collect any personal information from users. You can use all features fully offline.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "2. Permissions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "The app requests the following permissions to function optimally:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "- Notifications: To remind you about tasks and schedules.",
                  ),
                  Text(
                    "- Background Autostart: To ensure reminders work after device restart.",
                  ),
                  Text(
                    "- Battery Optimization: To prevent reminders from being delayed or stopped.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "3. Offline Usage",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "All app features can be used without an internet connection. Your data stays on your device unless you choose to export it.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "4. Third-Party Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Currently, the app does not use any third-party services. In the future, third-party services such as analytics or ads may be added, which may involve minimal data collection.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "5. Children",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "This app is suitable for all ages and does not knowingly collect data from children under 13.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
