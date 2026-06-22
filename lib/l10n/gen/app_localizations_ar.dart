// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ختمة';

  @override
  String get navKhatma => 'الختمة';

  @override
  String get navWird => 'الورد';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get khatmaTitle => 'ختماتي';

  @override
  String get wirdTitle => 'وردي';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get wirdEmpty => 'لا توجد أذكار بعد. اضغط + لإضافة ذكر.';

  @override
  String get newKhatma => 'ختمة جديدة';

  @override
  String get startFirstKhatmaTitle => 'ابدأ ختمتك الأولى';

  @override
  String get startFirstKhatmaBody =>
      'خطّط لإتمام القرآن الكريم جزءاً بجزء، وبوتيرةٍ تناسبك.';

  @override
  String get startKhatmaCta => 'ابدأ ختمة';

  @override
  String get khatmaTitleLabel => 'اسم الختمة';

  @override
  String get khatmaTitleHint => 'ختمة رمضان، ختمة شهرية…';

  @override
  String get goalLabel => 'مدة الإتمام';

  @override
  String get goalWeek => 'أسبوع';

  @override
  String get goalMonth => 'شهر';

  @override
  String get goalCustom => 'اختر تاريخاً';

  @override
  String get targetDateLabel => 'تاريخ الإتمام';

  @override
  String get createButton => 'إنشاء الختمة';

  @override
  String readTodayTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اقرأ $count جزء اليوم',
      many: 'اقرأ $count جزءاً اليوم',
      few: 'اقرأ $count أجزاء اليوم',
      two: 'اقرأ جزأين اليوم',
      one: 'اقرأ جزءاً اليوم',
      zero: 'أتممت ورد اليوم',
    );
    return '$_temp0';
  }

  @override
  String juzPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جزء يومياً',
      many: '$count جزءاً يومياً',
      few: '$count أجزاء يومياً',
      two: 'جزآن يومياً',
      one: 'جزء واحد يومياً',
    );
    return '$_temp0';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بقي $count يوم',
      many: 'بقي $count يوماً',
      few: 'بقيت $count أيام',
      two: 'بقي يومان',
      one: 'بقي يوم واحد',
      zero: 'آخر يوم',
    );
    return '$_temp0';
  }

  @override
  String remainingJuzLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بقي $count جزء',
      many: 'بقي $count جزءاً',
      few: 'بقيت $count أجزاء',
      two: 'بقي جزآن',
      one: 'بقي جزء واحد',
      zero: 'اكتملت',
    );
    return '$_temp0';
  }

  @override
  String finishByDate(String date) {
    return 'الإتمام في $date';
  }

  @override
  String get statRemaining => 'المتبقّي';

  @override
  String get statDaysLeft => 'الأيام';

  @override
  String get statPerDay => 'يومياً';

  @override
  String get sectionJuz => 'الأجزاء';

  @override
  String get paceOnTrack => 'في الموعد';

  @override
  String get paceBehind => 'متأخّر';

  @override
  String get paceAhead => 'متقدّم';

  @override
  String get paceDone => 'اكتملت';

  @override
  String get paceOverdue => 'فات الموعد';

  @override
  String get bannerDone => 'ختمة مباركة، تقبّل الله منكم.';

  @override
  String get bannerAhead => 'متقدّمٌ على الخطة، ما شاء الله.';

  @override
  String get bannerOnTrack => 'أنت في الموعد تماماً، واصِل.';

  @override
  String get bannerBehind => 'تأخّرٌ يسير، وثباتك على الوتيرة كفيلٌ باللحاق.';

  @override
  String get bannerOverdue => 'تجاوزت تاريخ الإتمام — عدّله أو أكمِل بعزيمة.';

  @override
  String get renameKhatma => 'إعادة تسمية';

  @override
  String get renameKhatmaTitle => 'إعادة تسمية الختمة';

  @override
  String get deleteKhatma => 'حذف';

  @override
  String get deleteKhatmaTitle => 'حذف الختمة؟';

  @override
  String deleteKhatmaBody(String title) {
    return 'سيُحذف «$title» وكل تقدّمه نهائياً.';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get khatmaNotFound => 'هذه الختمة لم تعد متاحة.';

  @override
  String get genericError => 'حدث خطأٌ ما.';
}
