import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Khatmah'**
  String get appName;

  /// No description provided for @navKhatma.
  ///
  /// In en, this message translates to:
  /// **'Khatma'**
  String get navKhatma;

  /// No description provided for @navWird.
  ///
  /// In en, this message translates to:
  /// **'Wird'**
  String get navWird;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @khatmaTitle.
  ///
  /// In en, this message translates to:
  /// **'My Khatmas'**
  String get khatmaTitle;

  /// No description provided for @wirdTitle.
  ///
  /// In en, this message translates to:
  /// **'My Wird'**
  String get wirdTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @wirdComingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'The wird & dhikr counter is on its way. Khatmah v1 focuses on the Qur\'an khatma.'**
  String get wirdComingSoonBody;

  /// No description provided for @wirdEmpty.
  ///
  /// In en, this message translates to:
  /// **'No adhkār yet. Tap + to add one.'**
  String get wirdEmpty;

  /// No description provided for @newKhatma.
  ///
  /// In en, this message translates to:
  /// **'New khatma'**
  String get newKhatma;

  /// No description provided for @startFirstKhatmaTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your first khatma'**
  String get startFirstKhatmaTitle;

  /// No description provided for @startFirstKhatmaBody.
  ///
  /// In en, this message translates to:
  /// **'Plan to complete the Qur\'an, juz\' by juz\', at a pace that suits you.'**
  String get startFirstKhatmaBody;

  /// No description provided for @startKhatmaCta.
  ///
  /// In en, this message translates to:
  /// **'Start a khatma'**
  String get startKhatmaCta;

  /// No description provided for @khatmaTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Khatma name'**
  String get khatmaTitleLabel;

  /// No description provided for @khatmaTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Ramadan khatma, monthly khatma…'**
  String get khatmaTitleHint;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'Finish within'**
  String get goalLabel;

  /// No description provided for @goalWeek.
  ///
  /// In en, this message translates to:
  /// **'A week'**
  String get goalWeek;

  /// No description provided for @goalMonth.
  ///
  /// In en, this message translates to:
  /// **'A month'**
  String get goalMonth;

  /// No description provided for @goalCustom.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get goalCustom;

  /// No description provided for @targetDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Finish by'**
  String get targetDateLabel;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create khatma'**
  String get createButton;

  /// No description provided for @readTodayTarget.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All done for today} =1{Read 1 juz\' today} other{Read {count} juz\' today}}'**
  String readTodayTarget(int count);

  /// No description provided for @juzPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 juz\' a day} other{{count} juz\' a day}}'**
  String juzPerDay(int count);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Last day} =1{1 day left} other{{count} days left}}'**
  String daysLeft(int count);

  /// No description provided for @remainingJuzLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Complete} =1{1 juz\' left} other{{count} juz\' left}}'**
  String remainingJuzLabel(int count);

  /// No description provided for @finishByDate.
  ///
  /// In en, this message translates to:
  /// **'Finish by {date}'**
  String finishByDate(String date);

  /// No description provided for @statRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get statRemaining;

  /// No description provided for @statDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days left'**
  String get statDaysLeft;

  /// No description provided for @statPerDay.
  ///
  /// In en, this message translates to:
  /// **'Per day'**
  String get statPerDay;

  /// No description provided for @sectionJuz.
  ///
  /// In en, this message translates to:
  /// **'Ajzāʾ'**
  String get sectionJuz;

  /// No description provided for @paceOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get paceOnTrack;

  /// No description provided for @paceBehind.
  ///
  /// In en, this message translates to:
  /// **'Behind'**
  String get paceBehind;

  /// No description provided for @paceAhead.
  ///
  /// In en, this message translates to:
  /// **'Ahead'**
  String get paceAhead;

  /// No description provided for @paceDone.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get paceDone;

  /// No description provided for @paceOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get paceOverdue;

  /// No description provided for @bannerDone.
  ///
  /// In en, this message translates to:
  /// **'Khatma complete — taqabbal Allāhu minkum.'**
  String get bannerDone;

  /// No description provided for @bannerAhead.
  ///
  /// In en, this message translates to:
  /// **'Ahead of schedule, mā shāʾ Allāh.'**
  String get bannerAhead;

  /// No description provided for @bannerOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Right on track — keep going.'**
  String get bannerOnTrack;

  /// No description provided for @bannerBehind.
  ///
  /// In en, this message translates to:
  /// **'A little behind — a steady pace will catch you up.'**
  String get bannerBehind;

  /// No description provided for @bannerOverdue.
  ///
  /// In en, this message translates to:
  /// **'Past the finish date — adjust it, or finish strong.'**
  String get bannerOverdue;

  /// No description provided for @renameKhatma.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameKhatma;

  /// No description provided for @renameKhatmaTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename khatma'**
  String get renameKhatmaTitle;

  /// No description provided for @deleteKhatma.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteKhatma;

  /// No description provided for @deleteKhatmaTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete khatma?'**
  String get deleteKhatmaTitle;

  /// No description provided for @deleteKhatmaBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes “{title}” and its progress.'**
  String deleteKhatmaBody(String title);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @khatmaNotFound.
  ///
  /// In en, this message translates to:
  /// **'This khatma is no longer available.'**
  String get khatmaNotFound;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get genericError;

  /// No description provided for @personalKhatmasTab.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalKhatmasTab;

  /// No description provided for @sharedKhatmasTab.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get sharedKhatmasTab;

  /// No description provided for @newGroupKhatma.
  ///
  /// In en, this message translates to:
  /// **'New group khatma'**
  String get newGroupKhatma;

  /// No description provided for @joinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with code'**
  String get joinWithCode;

  /// No description provided for @sharedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Read together'**
  String get sharedEmptyTitle;

  /// No description provided for @sharedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a shared khatma and split the 30 ajzāʾ with family or friends — or join one with an invite code.'**
  String get sharedEmptyBody;

  /// No description provided for @createGroupCta.
  ///
  /// In en, this message translates to:
  /// **'Create a group khatma'**
  String get createGroupCta;

  /// No description provided for @groupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Khatma name'**
  String get groupNameLabel;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Family khatma, our circle…'**
  String get groupNameHint;

  /// No description provided for @yourNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourNameLabel;

  /// No description provided for @yourNameHint.
  ///
  /// In en, this message translates to:
  /// **'How other members see you'**
  String get yourNameHint;

  /// No description provided for @createGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Create khatma'**
  String get createGroupButton;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCodeLabel;

  /// No description provided for @inviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'6-character code'**
  String get inviteCodeHint;

  /// No description provided for @joinButton.
  ///
  /// In en, this message translates to:
  /// **'Join khatma'**
  String get joinButton;

  /// No description provided for @invalidInviteCode.
  ///
  /// In en, this message translates to:
  /// **'That invite code isn’t valid.'**
  String get invalidInviteCode;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String members(int count);

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied'**
  String get codeCopied;

  /// No description provided for @sectionMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get sectionMembers;

  /// No description provided for @sectionAjza.
  ///
  /// In en, this message translates to:
  /// **'Ajzāʾ'**
  String get sectionAjza;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveGroup;

  /// No description provided for @leaveGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this khatma?'**
  String get leaveGroupTitle;

  /// No description provided for @leaveGroupBody.
  ///
  /// In en, this message translates to:
  /// **'You’ll be removed from “{title}”. Any juz you released stays open for others.'**
  String leaveGroupBody(String title);

  /// No description provided for @claimedByYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get claimedByYou;

  /// No description provided for @tapToClaim.
  ///
  /// In en, this message translates to:
  /// **'Tap a juz to claim it; tap again when you’ve read it.'**
  String get tapToClaim;

  /// No description provided for @juzTakenBy.
  ///
  /// In en, this message translates to:
  /// **'Juz {number} is taken by {name}.'**
  String juzTakenBy(int number, String name);

  /// No description provided for @groupNotFound.
  ///
  /// In en, this message translates to:
  /// **'This group khatma is no longer available.'**
  String get groupNotFound;

  /// No description provided for @needsConnection.
  ///
  /// In en, this message translates to:
  /// **'Group khatmas need an internet connection.'**
  String get needsConnection;

  /// No description provided for @legendOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get legendOpen;

  /// No description provided for @legendYours.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get legendYours;

  /// No description provided for @legendTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get legendTaken;

  /// No description provided for @legendDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get legendDone;

  /// No description provided for @groupComplete.
  ///
  /// In en, this message translates to:
  /// **'Khatma complete together — taqabbal Allāhu minkum.'**
  String get groupComplete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
