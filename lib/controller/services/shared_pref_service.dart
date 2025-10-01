import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static final SharedPrefService _instance = SharedPrefService._internal();
  SharedPrefService._internal();
  factory SharedPrefService() {
    return _instance;
  }
  late SharedPreferences preferences;
  Future<void> startPrefs() async {
    preferences = await SharedPreferences.getInstance();
  }

  int getNewId() {
    return preferences.getInt('notifyId') ?? 0;
  }

  Future<void> setNewId(int newId) async {
    if (newId >= 10000) {
      newId = 0;
    }
    await preferences.setInt('notifyId', newId);
  }

  int permissionPrompt() {
    return preferences.getInt('permission_prompt') ?? 0;
  }

  Future<void> incrementPermissionPrompt() async {
    await preferences.setInt('permission_prompt', 1);
  }
}
