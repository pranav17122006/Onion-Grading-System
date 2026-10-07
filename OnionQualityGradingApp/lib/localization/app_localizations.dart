import 'package:flutter/material.dart';

import 'app_en.dart';
import 'app_ta.dart';
import 'app_hi.dart';
import 'app_te.dart';
import 'app_ml.dart';
import 'app_kn.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    )!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('ta'),
    Locale('hi'),
    Locale('te'),
    Locale('ml'),
    Locale('kn'),
  ];

  String get(String key) {
    switch (locale.languageCode) {
      case 'ta':
        return tamilTranslations[key] ?? englishTranslations[key] ?? key;

      case 'hi':
        return hindiTranslations[key] ?? englishTranslations[key] ?? key;

      case 'te':
        return teluguTranslations[key] ?? englishTranslations[key] ?? key;

      case 'ml':
        return malayalamTranslations[key] ?? englishTranslations[key] ?? key;

      case 'kn':
        return kannadaTranslations[key] ?? englishTranslations[key] ?? key;

      case 'en':
      default:
        return englishTranslations[key] ?? key;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'ta',
      'hi',
      'te',
      'ml',
      'kn',
    ].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<AppLocalizations> old,
  ) {
    return false;
  }
}