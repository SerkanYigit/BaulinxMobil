import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/l10n/l10n.dart';

class ControllerLocal extends GetxController {
  Rx<Locale>? locale;
  String localCode = "";

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;

    this.locale = locale.obs;
    localCode = this.locale!.value.languageCode;
    log("setlocale done : " + this.locale!.value.languageCode);
    update();
  }

  void clearLocale() {
    this.locale = null;
    update();
  }
}
