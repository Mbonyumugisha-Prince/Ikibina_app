import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const _key = 'selected_language';

  static Future<void> save(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language);
  }

  static Future<String> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? 'English';
  }
}
