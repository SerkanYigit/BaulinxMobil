import 'package:flutter/material.dart';

dropdownSearchFn(String keyw, List<DropdownMenuItem> items) {
  List<DropdownMenuItem> itms = items;
  List<int?> a = itms.map((e) {
    if (e.key
        .toString()
        .toLowerCase()
        .contains(keyw.toString().toLowerCase())) {
      return itms.indexOf(e);
    }
  }).toList();
  a.removeWhere((value) => value == null);
  return a;
}
