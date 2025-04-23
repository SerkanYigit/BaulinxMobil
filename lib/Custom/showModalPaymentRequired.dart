import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool?> showModalPaymentRequired(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              content: Container(
                height: 100,
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.paymentRequired,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    TextButton(
                        onPressed: () {
                          launch("https://vir2ell-office.com");
                        },
                        child:
                            Text(AppLocalizations.of(context)!.clickHereToPay)),
                  ],
                ),
              ),
              title: Icon(
                Icons.warning_amber_rounded,
                size: 85,
                color: Color(0xffff4c14),
              ),
              titlePadding: EdgeInsets.all(15.0),
              contentPadding: EdgeInsets.fromLTRB(24.0, 15.0, 24.0, 19.0),
            );
          },
        );
      });
}
