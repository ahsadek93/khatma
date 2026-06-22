import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Formats [number] using the active locale's digits — Arabic-Indic (٠١٢…) in
/// `ar`, Western (012…) in `en`.
String formatNumber(BuildContext context, int number) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return NumberFormat.decimalPattern(locale).format(number);
}

/// Formats a date in the locale's medium form (e.g. "22 June 2026" /
/// "٢٢ يونيو ٢٠٢٦"). Requires `initializeDateFormatting()` in `main()`.
String formatMediumDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMMd(locale).format(date);
}
