// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Khatmah';

  @override
  String get navKhatma => 'Khatma';

  @override
  String get navWird => 'Wird';

  @override
  String get navSettings => 'Settings';

  @override
  String get khatmaTitle => 'My Khatmas';

  @override
  String get wirdTitle => 'My Wird';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get khatmaEmpty => 'No khatmas yet. Tap + to start one.';

  @override
  String get wirdEmpty => 'No adhkār yet. Tap + to add one.';
}
