import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';

Future<bool?> showModalDeleteYesOrNo(BuildContext context, String question) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                content: Container(
                  height: 60,
                  child: Column(
                    children: [
                      Text(
                        question,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        AppLocalizations.of(context)!
                            .youWillNotAbleToUndoThisAction,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                title: Icon(
                  Icons.help_outline_outlined,
                  size: 90,
                  color: Color(0xffff4c14),
                ),
                titlePadding: EdgeInsets.all(15.0),
                contentPadding: EdgeInsets.fromLTRB(24.0, 15.0, 24.0, 19.0),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, false);
                        },
                        child: Container(
                          width: 120,
                          height: 45,
                          decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              color: Colors.white,
                              border: Border.all(
                                color: Color(0xffff4c14),
                              ),
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.no,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              color: Color(0xffff4c14),
                            ),
                          )),
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      GestureDetector(
                        onTap: () async {
                          Navigator.pop(context, true);
                        },
                        child: Container(
                          width: 120,
                          height: 45,
                          decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              color: Color(0xffff4c14),
                              borderRadius: BorderRadius.circular(8)),
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
                    ],
                  ),
                ]);
          },
        );
      });
}
