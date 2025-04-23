import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/model/ForceUpdate/ForceUpdateData.dart';
import 'package:undede/widgets/ButtonGradient.dart';
import 'package:undede/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdatePage extends StatelessWidget {
  final ForceUpdateData versionCheck;

  ForceUpdatePage(this.versionCheck);

  String iosUrl = "https://apps.apple.com/us/app/jetton/id1580367560";
  String androidUrl =
      "https://play.google.com/store/apps/details?id=com.toolioz.jetton";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: Container(
              color: Colors.white,
              height: Get.height - 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //    SizedBox(height: 75,),

                  /*         Padding(
                    padding: const EdgeInsets.fromLTRB(100, 20, 100, 0),
                    child: Container(
                      margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 10),
                      child: Image.asset(
                        "assets/images/sadFace.png",
                        height: 250,
                      ),
                    ),
                  ),*/
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: Text(
                      versionCheck.message.toString() ?? "Version Check message",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              //    width: Get.width,
              child: InkWell(
                onTap: () async {
                  _launchURL(Platform.isIOS ? iosUrl : androidUrl);
                },
                child: ButtonGradient(Padding(
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                  child: Center(
                    child: Text(AppLocalizations.of(context)!.update,
                    style: TextStyle(fontSize: 18),
                  )),
                )),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}
