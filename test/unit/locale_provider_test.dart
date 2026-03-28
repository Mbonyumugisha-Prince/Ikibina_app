import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ikibina/providers/locale_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleProvider', () {
    test('starts with English locale by default', () {
      final provider = LocaleProvider();
      expect(provider.locale.languageCode, 'en');
    });

    test('languageName returns "English" initially', () {
      final provider = LocaleProvider();
      expect(provider.languageName, 'English');
    });

    test('setLanguage to Ikinyarwanda changes locale to rw', () async {
      final provider = LocaleProvider();
      await provider.setLanguage('Ikinyarwanda');
      expect(provider.locale.languageCode, 'rw');
      expect(provider.languageName, 'Ikinyarwanda');
    });

    test('setLanguage to English keeps locale as en', () async {
      final provider = LocaleProvider();
      await provider.setLanguage('English');
      expect(provider.locale.languageCode, 'en');
    });

    test('notifies listeners when language changes', () async {
      final provider = LocaleProvider();
      bool notified = false;
      provider.addListener(() => notified = true);
      await provider.setLanguage('Ikinyarwanda');
      expect(notified, isTrue);
    });

    test('strings instance changes after switching language', () async {
      final provider = LocaleProvider();
      final before = provider.strings;
      await provider.setLanguage('Ikinyarwanda');
      expect(provider.strings, isNot(same(before)));
    });

    test('switching back to English restores en locale', () async {
      final provider = LocaleProvider();
      await provider.setLanguage('Ikinyarwanda');
      await provider.setLanguage('English');
      expect(provider.locale.languageCode, 'en');
    });
  });
}
