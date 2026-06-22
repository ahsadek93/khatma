import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

/// Supported UI locales. Arabic is the default/primary language (RTL).
const supportedLocales = <Locale>[Locale('ar'), Locale('en')];

/// Persists and exposes the active UI locale. Defaults to Arabic.
class LocaleController extends Notifier<Locale> {
  static const _key = 'app_locale';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _localeFor(prefs.getString(_key));
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, locale.languageCode);
    state = locale;
  }

  Locale _localeFor(String? code) => supportedLocales.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => const Locale('ar'),
      );
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
