import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:undede/Controller/ControllerDB.dart';

import 'package:undede/Provider/LocaleProvider.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Language extends StatefulWidget {
  const Language({Key? key}) : super(key: key);

  @override
  _LanguageState createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordConfirmationController =
      TextEditingController();
  ControllerLocal cL = Get.put(ControllerLocal());
  Future<SharedPreferences> sp = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
  }

  var locale;

  @override
  Widget build(BuildContext context) {
    locale = Localizations.localeOf(context);
    var flag = L10n.getFlag(locale.languageCode);
    return GetBuilder<ControllerLocal>(builder: (controllerLocale) {
      locale = controllerLocale.locale!.value;
      flag = L10n.getFlag(locale.languageCode);
          return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context)!.changelanguage,
          showNotification: false,
        ),
        body: Container(
          width: Get.width,
          height: Get.height,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: Get.width,
                  color: Get.theme.scaffoldBackgroundColor,
                  child: Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Get.theme.scaffoldBackgroundColor,
                    ),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 25,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: InkWell(
                                  onTap: () {
                                    cL.setLocale(L10n.all[0]);
                                    controllerLocale.update();
                                    sp.then((v) =>
                                        v.setString("savedLocale", "tr"));
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        "Türkçe",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Spacer(),
                                      locale.toString() == "tr"
                                          ? Icon(Icons.done,
                                              color: Get.theme.primaryColor)
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: InkWell(
                                  onTap: () {
                                    cL.setLocale(L10n.all[2]);
                                    controllerLocale.update();
                                    sp.then((v) =>
                                        v.setString("savedLocale", "de"));
                                  },
                                  child: Row(
                                    children: [
                                      Text("Deutsch",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500)),
                                      Spacer(),
                                      locale.toString() == "de"
                                          ? Icon(
                                              Icons.done,
                                              color: Get.theme.primaryColor,
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: InkWell(
                                  onTap: () {
                                    cL.setLocale(L10n.all[1]);
                                    controllerLocale.update();
                                    sp.then((v) =>
                                        v.setString("savedLocale", "en"));
                                  },
                                  child: Row(
                                    children: [
                                      Text("English",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500)),
                                      Spacer(),
                                      locale.toString() == "en"
                                          ? Icon(Icons.done,
                                              color: Get.theme.primaryColor)
                                          : Container(),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
