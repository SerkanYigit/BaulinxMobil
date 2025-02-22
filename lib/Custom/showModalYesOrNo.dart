import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';

Future<bool?> showModalYesOrNo(
    BuildContext context, String title, String question) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  question,
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.pop(context, true);
                        },
                        child: Container(
                          width: 120,
                          height: 45,
                          decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(45)),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.yes,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: Colors.white),
                          )),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, false);
                        },
                        child: Container(
                          width: 120,
                          height: 45,
                          decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(45)),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.no,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: Colors.white),
                          )),
                        ),
                      ),
                    ],
                  ),
                ]);
          },
        );
      });
}
