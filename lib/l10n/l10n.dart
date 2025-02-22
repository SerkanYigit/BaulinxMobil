import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('tr'),
    const Locale('en'),
    const Locale('de')
  ];

  static String getFlag(String code) {
    switch (code) {
      case 'tr':
        return '🇹🇷';
      case 'en':
        return '🇬🇧';
      case 'de':
        return '🇩🇪';
      default:
        return '🇹🇷';
    }
  }

  static Locale getLocaleByLangCode(String code) {
    switch (code) {
      case 'tr':
        return L10n.all[0];
      case 'en':
        return L10n.all[1];
      case 'de':
        return L10n.all[2];
      default:
        return L10n.all[0];
    }
  }

  static String getNotificationButton(String code) {
    switch (code) {
      case 'tr':
        return "Kabul";
      case 'en':
        return '🇬🇧';
      case 'de':
        return '🇩🇪';
      default:
        return '🇹🇷';
    }
  }
}
