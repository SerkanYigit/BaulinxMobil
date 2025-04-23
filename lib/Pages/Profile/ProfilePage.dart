import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';
import 'package:undede/Pages/Login/SignInPageV2.dart';
import 'package:undede/Pages/Login/rememberMeControl.dart';
import 'package:undede/Pages/Profile/ChangePassword.dart';
import 'package:undede/Pages/Profile/EmailSignature.dart';
import 'package:undede/Pages/Profile/ProfileInvoiceHistory/InvoiceHistory.dart';
import 'package:undede/Pages/Profile/Language.dart';
import 'package:undede/Pages/Profile/ProfileCalendar.dart';
import 'package:undede/Pages/Profile/ProfileConnectedCustomer.dart';
import 'package:undede/Pages/Profile/ProfileCustomersBills/ProfileCustomersBills.dart';
import 'package:undede/Pages/Profile/ProfileLabel/ProfileLabel.dart';
import 'package:undede/Pages/Profile/ProfileMail/ProfileMail.dart';
import 'package:undede/Pages/Profile/ProfileRules/ProfileRules.dart';
import 'package:undede/Pages/Splash/SplashPage.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/landingPage.dart';
import 'package:sliding_sheet2/sliding_sheet2.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../WidgetsV2/Helper.dart';
import 'MyAccount.dart';
import 'ProfileCustomer/ProfileCustomerUpdate.dart';
import 'ProfileNoteLabel/ProfileNoteLabel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _launchURL();
    _launchURL2();
    _launchURL3();
    _launchURL4();
    super.didChangeDependencies();
  }

  ControllerDB _controllerDB = Get.put(ControllerDB());
  String? _url;
  String? _url2;
  String? _url3;
  String? _url4;
  void _launchURL() async {
    if (AppLocalizations.of(context)!.language == "Türkçe") {
      _url = "https://landingpage.baulinx.com/TermAndConditions.html";
    }
    if (AppLocalizations.of(context)!.language == "English") {
      _url = "https://landingpage.baulinx.com/TermAndConditions.html";
    }
    if (AppLocalizations.of(context)!.language == "Sprache") {
      _url = "https://landingpage.baulinx.com/TermAndConditions.html";
    }
  }

  void _launchURL2() async {
    if (AppLocalizations.of(context)!.language == "Türkçe") {
      _url2 = "https://landingpage.baulinx.com/LegalNotice.html";
    }
    if (AppLocalizations.of(context)!.language == "English") {
      _url2 = "https://landingpage.baulinx.com/LegalNotice.html";
    }
    if (AppLocalizations.of(context)!.language == "Sprache") {
      _url2 = "https://landingpage.baulinx.com/LegalNotice.html";
    }
  }

  void _launchURL3() async {
    if (AppLocalizations.of(context)!.language == "Türkçe") {
      _url3 = "https://landingpage.baulinx.com/DataProtection.html";
    }
    if (AppLocalizations.of(context)!.language == "English") {
      _url3 = "https://landingpage.baulinx.com/DataProtection.html";
    }
    if (AppLocalizations.of(context)!.language == "Sprache") {
      _url3 = "https://landingpage.baulinx.com/DataProtection.html";
    }
  }

  void _launchURL4() async {
    if (AppLocalizations.of(context)!.language == "Türkçe") {
      _url4 = "https://landingpage.baulinx.com/EuCookie.html";
    }
    if (AppLocalizations.of(context)!.language == "English") {
      _url4 = "https://landingpage.baulinx.com/EuCookie.html";
    }
    if (AppLocalizations.of(context)!.language == "Sprache") {
      _url4 = "https://landingpage.baulinx.com/EuCookie.html";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerDB>(
        builder: (_) => Scaffold(
            backgroundColor: Get.theme.scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.profile,
              showNotification: false,
            ),
            body: Container(
              width: Get.width,
              height: Get.height,
              child: Column(children: [
                Expanded(
                  child: Container(
                    width: Get.width,
                    child: Container(
                      width: Get.width,
                      decoration: BoxDecoration(
                        color: HexColor('#f4f5f7'),
                      ),
                      child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        boxShadow: standartCardShadow(),
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(_controllerDB
                                                .user.value!.result!.photo ??
                                            "http://test.vir2ell-office.com/Content/cardpicture/userDefault.png"),
                                        radius: 30,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Text(
                                        _controllerDB
                                                .user.value!.result!.name! +
                                            "  " +
                                            _controllerDB
                                                .user.value!.result!.surname!,
                                        style: TextStyle(
                                          color: Get.theme.secondaryHeaderColor,
                                          fontSize: 20,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Divider(),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/icon/letter.png",
                                      width: 25,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      _controllerDB
                                          .user.value!.result!.mailAddress!,
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 188, 188, 188)),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                                Divider(),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/icon/phone.png",
                                      width: 22,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      _controllerDB.user.value!.result!.phone!,
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 188, 188, 188)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.account,
                                      style: TextStyle(
                                          color: Get.theme.secondaryHeaderColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MyAccount()));
                                    },
                                    child: ImageAndText(
                                        'assets/images/icon/user.png',
                                        AppLocalizations.of(context)!
                                            .myAccount)),
                                InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangePassword()));
                                    },
                                    child: ImageAndText(
                                        'assets/images/icon/unlock.png',
                                        AppLocalizations.of(context)!
                                            .changePassword)),
                                InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Language()));
                                    },
                                    child: ImageAndText(
                                        'assets/images/icon/worldwide.png',
                                        AppLocalizations.of(context)!
                                            .selectlanguage)),
                                InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EmailSignature()));
                                    },
                                    child: ImageAndText(
                                        'assets/images/icon/signature.png',
                                        AppLocalizations.of(context)!
                                            .emailSignature)),
                                InkWell(
                                    /* onTap: () {
                                      FileShareFn([
                                        Platform.isAndroid
                                            ? "https://play.google.com/store/apps/details?id=com.vir2ell_office"
                                            : "https://apps.apple.com/us/app/keynote/id1478516412?platform=ipad"
                                      ], context, url: true);
                                    }, */
                                    child: ImageAndText(
                                        'assets/images/icon/shareinvoice.png',
                                        AppLocalizations.of(context)!.share)),
                                SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.settings,
                                      style: TextStyle(
                                          color: Get.theme.secondaryHeaderColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileMail()));
                                    },
                                    child: ImageAndText(
                                        'assets/images/icon/letter.png',
                                        "E-mail")),
                                InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileCalendar()));
                                    },
                                    child: ImageAndText(
                                        'assets/images/icon/calendar.png',
                                        AppLocalizations.of(context)!
                                            .calendar)),
                                /* ImageAndText(
                                    'assets/images/icon/magnifying-glass.png',
                                    AppLocalizations.of(context).searchKeyword), */
                                InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileLabel()));
                                    },
                                    child: ImageAndText(
                                        'assets/images/icon/label.png',
                                        AppLocalizations.of(context)!.labels)),
                                InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileNoteLabel()));
                                    },
                                    child: ImageAndText(
                                        'assets/images/icon/labeled.png',
                                        AppLocalizations.of(context)!.note +
                                            " " +
                                            AppLocalizations.of(context)!
                                                .labels)),
                                InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileConnectedCustomer()));
                                    },
                                    child: ImageAndText(
                                        'assets/images/icon/user.png',
                                        AppLocalizations.of(context)!
                                            .personal)),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileRules()));
                                  },
                                  child: ImageAndText(
                                      'assets/images/icon/profile.png',
                                      AppLocalizations.of(context)!.rules),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileCustomersBills()));
                                  },
                                  child: ImageAndText(
                                      'assets/images/icon/bill.png',
                                      AppLocalizations.of(context)!
                                          .customerBills),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                InvoiceHistory()));
                                  },
                                  child: ImageAndText(
                                      'assets/images/icon/history.png',
                                      AppLocalizations.of(context)!
                                          .invoiceHistory),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileCustomerUpdate()));
                                  },
                                  child: ImageAndText(
                                      'assets/images/icon/people.png',
                                      AppLocalizations.of(context)!.customer),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .informations,
                                      style: TextStyle(
                                          color: Get.theme.secondaryHeaderColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    showSlidingBottomSheet(context,
                                        builder: (context) {
                                      return SlidingSheetDialog(
                                          extendBody: true,
                                          minHeight: Get.height - (250),
                                          padding: EdgeInsets.only(bottom: 100),
                                          elevation: 8,
                                          cornerRadius: 16,
                                          snapSpec: const SnapSpec(
                                            snap: true,
                                            snappings: [0.8, 1.0],
                                            positioning: SnapPositioning
                                                .relativeToAvailableSpace,
                                          ),
                                          builder: (context, state) {
                                            return Container(
                                              height: Get.height,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                          topLeft:
                                                              Radius.circular(
                                                                  20))),
                                              child: InAppWebView(
                                                  initialUrlRequest: URLRequest(
                                                url: WebUri.uri(
                                                    Uri.parse(_url4!)),
                                              )),
                                            );
                                          });
                                    });
                                  },
                                  child: ImageAndText(
                                      'assets/images/icon/insurance.png',
                                      AppLocalizations.of(context)!.help),
                                ),
                                InkWell(
                                  onTap: () {
                                    showSlidingBottomSheet(context,
                                        builder: (context) {
                                      return SlidingSheetDialog(
                                          minHeight: Get.height - (250),
                                          padding: EdgeInsets.only(bottom: 100),
                                          elevation: 8,
                                          cornerRadius: 16,
                                          snapSpec: const SnapSpec(
                                            snap: true,
                                            snappings: [0.8, 1.0],
                                            positioning: SnapPositioning
                                                .relativeToAvailableSpace,
                                          ),
                                          builder: (context, state) {
                                            return Container(
                                              height: Get.height,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                          topLeft:
                                                              Radius.circular(
                                                                  20))),
                                              child: InAppWebView(
                                                  initialUrlRequest: URLRequest(
                                                      url: WebUri.uri(
                                                Uri.parse(_url!),
                                              ))),
                                            );
                                          });
                                    });
                                  },
                                  child: ImageAndText(
                                      'assets/images/icon/terms.png',
                                      AppLocalizations.of(context)!
                                          .termsandcondition),
                                ),
                                InkWell(
                                  onTap: () {
                                    showSlidingBottomSheet(context,
                                        builder: (context) {
                                      return SlidingSheetDialog(
                                          minHeight: Get.height - (250),
                                          padding: EdgeInsets.only(bottom: 100),
                                          elevation: 8,
                                          cornerRadius: 16,
                                          snapSpec: const SnapSpec(
                                            snap: true,
                                            snappings: [0.8, 1.0],
                                            positioning: SnapPositioning
                                                .relativeToAvailableSpace,
                                          ),
                                          builder: (context, state) {
                                            return Container(
                                              height: Get.height,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                          topLeft:
                                                              Radius.circular(
                                                                  20))),
                                              child: InAppWebView(
                                                  initialUrlRequest: URLRequest(
                                                url: WebUri.uri(
                                                    Uri.parse(_url3!)),
                                              )),
                                            );
                                          });
                                    });
                                  },
                                  child: ImageAndText(
                                      'assets/images/icon/policy.png',
                                      AppLocalizations.of(context)!.privacy),
                                ),
                                InkWell(
                                  onTap: () {
                                    showSlidingBottomSheet(context,
                                        builder: (context) {
                                      return SlidingSheetDialog(
                                          minHeight: Get.height - (250),
                                          padding: EdgeInsets.only(bottom: 100),
                                          elevation: 8,
                                          cornerRadius: 16,
                                          snapSpec: const SnapSpec(
                                            snap: true,
                                            snappings: [0.8, 1.0],
                                            positioning: SnapPositioning
                                                .relativeToAvailableSpace,
                                          ),
                                          builder: (context, state) {
                                            return Container(
                                              height: Get.height,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                          topLeft:
                                                              Radius.circular(
                                                                  20))),
                                              child: InAppWebView(
                                                  initialUrlRequest: URLRequest(
                                                      url: WebUri.uri(
                                                Uri.parse(_url2!),
                                              ))),
                                            );
                                          });
                                    });
                                  },
                                  child: ImageAndText(
                                      'assets/images/icon/info.png',
                                      AppLocalizations.of(context)!.about),
                                ),
                                InkWell(
                                    onTap: () async {
                                      SharedPreferences preferences =
                                          await SharedPreferences.getInstance();
                                      await preferences.clear();
                                      await preferences.setBool("key", true);
                                      await _controllerDB
                                          .updateLoginState(Login.SignIn);
                                      await _controllerDB.LogOut(
                                          _controllerDB.headers());
                                      // Get.offAll(() => LandingPage()
                                      Get.offAll(
                                          LandingPage()); //! TODO: eski hali  Get.offAll(() => LandingPage());
                                    },
                                    child: ImageAndText(
                                        'assets/images/icon/logout.png',
                                        AppLocalizations.of(context)!.logOut)),
                                SizedBox(
                                  height: 100,
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ]),
            )));
  }

  Container ImageAndText(String path, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 7),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                path,
                width: 22,
                color: Colors.black54,
              ),
              SizedBox(
                width: 15,
              ),
              Text(text),
              Spacer(),
              Icon(
                Icons.keyboard_arrow_right,
                color: Get.theme.secondaryHeaderColor,
              )
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  Container IconAndText(IconData iconData, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 7),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                iconData,
                color: Get.theme.secondaryHeaderColor,
              ),
              SizedBox(
                width: 15,
              ),
              Text(text),
              Spacer(),
              Icon(
                Icons.keyboard_arrow_right,
                color: Get.theme.secondaryHeaderColor,
              )
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}
