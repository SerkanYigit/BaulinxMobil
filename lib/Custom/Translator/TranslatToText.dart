import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';
import 'package:translator/translator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final translator = GoogleTranslator();

Future<void> TranslateToText(BuildContext context, String Language,
    String LangCode, List<String> data) async {
  String allDatas = "";

  data.forEach((element) {
    allDatas += element + "\n";
  });
  print(allDatas);
  translator.translate(allDatas, from: "auto", to: Language).then((value) {
    print(value);
    Get.snackbar(
      AppLocalizations.of(context)!.translate,
      value.text,
      duration: Duration(
          seconds:
              int.parse((value.text.split(" ").length / 3).toStringAsFixed(0)) +
                  1),
      onTap: (snack) {},
      titleText: StatefulBuilder(builder: (context, setState) {
        return Row(
          children: [
            Text(AppLocalizations.of(context)!.translate,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Spacer(),
            InkWell(
                onTap: () async {
                  await FileShareFn([value.text], context, url: true);
                },
                child: Icon(Icons.share, size: 20, color: Colors.white)),
            SizedBox(
              width: 15,
            ),
          ],
        );
      }),
      backgroundColor: Colors.black87,
      messageText: Text(
        value.text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
    print(int.parse((value.text.split(" ").length / 3).toStringAsFixed(0)));
  });
}

PopupMenuButton buildPopupMenuButton(BuildContext context, List<String> data) {
  return PopupMenuButton(
      onSelected: (a) async {
        if (a == 1) {
          await TranslateToText(context, "tr", "tr-TR", data);
        }
        if (a == 2) {
          await TranslateToText(context, "en", "en-US", data);
        }
        if (a == 3) {
          await TranslateToText(context, "de", "de-DE", data);
        }
        if (a == 4) {
          await TranslateToText(context, "ar", "ar", data);
        }
        if (a == 5) {
          await TranslateToText(context, "ku", "ku", data);
        }
        if (a == 6) {
          await TranslateToText(context, "uk", "uk-UA", data);
        }
        if (a == 7) {
          await TranslateToText(context, "ru", "ru-RU", data);
        }
        if (a == 8) {
          await TranslateToText(context, "es", "es-ES", data);
        }
        if (a == 9) {
          await TranslateToText(context, "fr", "fr-FR", data);
        }
        if (a == 10) {
          await TranslateToText(context, "pl", "pl-PL", data);
        }
        if (a == 11) {
          await TranslateToText(context, "it", "it-It", data);
        }
      },
      child: Center(
          child: Icon(
        Icons.translate,
        color: Colors.black,
        size: 20,
      )),
      itemBuilder: (context) => [
            PopupMenuItem(
              child: Text("Türkçe"),
              value: 1,
            ),
            PopupMenuItem(
              child: Text("English"),
              value: 2,
            ),
            PopupMenuItem(
              child: Text("deutsch"),
              value: 3,
            ),
            PopupMenuItem(
              child: Text("عربي"),
              value: 4,
            ),
            PopupMenuItem(
              child: Text("Kurdî"),
              value: 5,
            ),
            PopupMenuItem(
              child: Text("українська"),
              value: 6,
            ),
            PopupMenuItem(
              child: Text("Русский"),
              value: 7,
            ),
            PopupMenuItem(
              child: Text("Español"),
              value: 8,
            ),
            PopupMenuItem(
              child: Text("Français"),
              value: 9,
            ),
            PopupMenuItem(
              child: Text("dialekt"),
              value: 10,
            ),
            PopupMenuItem(
              child: Text("Italiano"),
              value: 11,
            ),
          ]);
}
