import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/language_service.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  AppStrings _strings = EnStrings();

  Locale get locale => _locale;
  AppStrings get strings => _strings;
  String get languageName =>
      _locale.languageCode == 'rw' ? 'Ikinyarwanda' : 'English';

  LocaleProvider() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await LanguageService.load();
    _apply(saved, notify: false);
  }

  Future<void> setLanguage(String languageName) async {
    await LanguageService.save(languageName);
    _apply(languageName);
  }

  void _apply(String languageName, {bool notify = true}) {
    if (languageName == 'Ikinyarwanda') {
      _locale = const Locale('rw');
      _strings = RwStrings();
    } else {
      _locale = const Locale('en');
      _strings = EnStrings();
    }
    if (notify) notifyListeners();
  }
}
