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
  String get wirdEmpty => 'No adhkār yet. Tap + to add one.';

  @override
  String get newKhatma => 'New khatma';

  @override
  String get startFirstKhatmaTitle => 'Start your first khatma';

  @override
  String get startFirstKhatmaBody =>
      'Plan to complete the Qur\'an, juz\' by juz\', at a pace that suits you.';

  @override
  String get startKhatmaCta => 'Start a khatma';

  @override
  String get khatmaTitleLabel => 'Khatma name';

  @override
  String get khatmaTitleHint => 'Ramadan khatma, monthly khatma…';

  @override
  String get goalLabel => 'Finish within';

  @override
  String get goalWeek => 'A week';

  @override
  String get goalMonth => 'A month';

  @override
  String get goalCustom => 'Pick a date';

  @override
  String get targetDateLabel => 'Finish by';

  @override
  String get createButton => 'Create khatma';

  @override
  String readTodayTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Read $count juz\' today',
      one: 'Read 1 juz\' today',
      zero: 'All done for today',
    );
    return '$_temp0';
  }

  @override
  String juzPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count juz\' a day',
      one: '1 juz\' a day',
    );
    return '$_temp0';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'Last day',
    );
    return '$_temp0';
  }

  @override
  String remainingJuzLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count juz\' left',
      one: '1 juz\' left',
      zero: 'Complete',
    );
    return '$_temp0';
  }

  @override
  String finishByDate(String date) {
    return 'Finish by $date';
  }

  @override
  String get statRemaining => 'Remaining';

  @override
  String get statDaysLeft => 'Days left';

  @override
  String get statPerDay => 'Per day';

  @override
  String get sectionJuz => 'Ajzāʾ';

  @override
  String get paceOnTrack => 'On track';

  @override
  String get paceBehind => 'Behind';

  @override
  String get paceAhead => 'Ahead';

  @override
  String get paceDone => 'Completed';

  @override
  String get paceOverdue => 'Overdue';

  @override
  String get bannerDone => 'Khatma complete — taqabbal Allāhu minkum.';

  @override
  String get bannerAhead => 'Ahead of schedule, mā shāʾ Allāh.';

  @override
  String get bannerOnTrack => 'Right on track — keep going.';

  @override
  String get bannerBehind =>
      'A little behind — a steady pace will catch you up.';

  @override
  String get bannerOverdue =>
      'Past the finish date — adjust it, or finish strong.';

  @override
  String get renameKhatma => 'Rename';

  @override
  String get renameKhatmaTitle => 'Rename khatma';

  @override
  String get deleteKhatma => 'Delete';

  @override
  String get deleteKhatmaTitle => 'Delete khatma?';

  @override
  String deleteKhatmaBody(String title) {
    return 'This permanently removes “$title” and its progress.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get khatmaNotFound => 'This khatma is no longer available.';

  @override
  String get genericError => 'Something went wrong.';
}
