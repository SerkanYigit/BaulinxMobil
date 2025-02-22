import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerPackages.dart';
import 'package:undede/Pages/Chat/GroupChat/EditGroupName.dart';
import 'package:undede/Services/Packages/PackagesDB.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Packages/GetPackagesResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:sliding_sheet2/sliding_sheet2.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isInstructionView = false;
  ControllerPackages _controllerPackages = ControllerPackages();
  GetPackagesResult _getPackagesResult = GetPackagesResult(hasError: false);
  ControllerDB _controllerDB = Get.put(ControllerDB());
  bool loading = true;
  InAppWebViewController? webViewController;

  Future<void> GetPackages() async {
    await _controllerPackages.GetPackages(AppLocalizations.of(context)!.date)
        .then((value) => _getPackagesResult = value);
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      GetPackages();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff006565),
      resizeToAvoidBottomInset: true,
      body: Container(
        width: Get.width,
        height: Get.height,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  _controllerDB.updateLoginState(Login.SignIn);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 50),
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              "assets/images/app_logo/logobeyaz.png"))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.arrow_back,
                  color: Color(0xff006565),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 5,
          ),
          Center(
            child: Text(
              AppLocalizations.of(context)!.chooseYourPackage,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 30),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Container(
              width: Get.width * 0.9,
              child: Text(
                AppLocalizations.of(context)!.paymentDescription,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.yearly,
                style: TextStyle(
                    color: isInstructionView ? Colors.grey : Colors.white,
                    fontSize: 20),
              ),
              SizedBox(
                width: 5,
              ),
              Switch(
                  value: isInstructionView,
                  onChanged: (isOn) {
                    setState(() {
                      isInstructionView = isOn;
                    });
                    print(isOn);
                  }),
              SizedBox(
                width: 5,
              ),
              Text(
                AppLocalizations.of(context)!.monthly,
                style: TextStyle(
                    color: !isInstructionView ? Colors.grey : Colors.white,
                    fontSize: 20),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: _getPackagesResult.result?.length == null
                    ? 0
                    : _getPackagesResult.result?.length,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                itemBuilder: (context, index) {
                  int itemCount = _getPackagesResult.result!.length ?? 0;
                  int reversedIndex = itemCount - 1 - index;
                  return Container(
                    width: Get.width - 100,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xffe0e8a7),
                                Color(0xffa4d7ff)
                              ]),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5))),
                        ),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(_getPackagesResult
                                      .result![reversedIndex].photo!))),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          _getPackagesResult.result![reversedIndex].title!,
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppLocalizations.of(context)!.perMonth,
                          style: TextStyle(color: Colors.grey),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.symbol,
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              !isInstructionView
                                  ? _getPackagesResult
                                      .result![reversedIndex].yearlyPrice
                                      .toString()
                                      .split(".")
                                      .first
                                  : _getPackagesResult
                                      .result![reversedIndex].monthlyPrice
                                      .toString()
                                      .split(".")
                                      .first,
                              style: TextStyle(fontSize: 40),
                            ),
                          ],
                        ),
                        Divider(
                          endIndent: 20,
                          indent: 20,
                          thickness: 0.5,
                        ),
                        Expanded(
                          child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              shrinkWrap: true,
                              itemCount: _getPackagesResult
                                  .result![reversedIndex].description!
                                  .split("\r\n")
                                  .length,
                              itemBuilder: (context, i) {
                                return Row(
                                  children: [
                                    Icon(
                                      Icons.bolt_outlined,
                                      color: Get.theme.primaryColor,
                                    ),
                                    Flexible(
                                      child: Text(
                                        _getPackagesResult
                                            .result![reversedIndex].description!
                                            .split("\r\n")[i],
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    )
                                  ],
                                );
                              }),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (index == 0) {
                              _controllerDB.updateLoginState(Login.SignUp);
                              return;
                            }
                            Get.to(
                              () => SafeArea(
                                child: Container(
                                  height: Get.height,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: Get.width,
                                        height: 84,
                                        padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                              .padding
                                              .top,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Get.theme.secondaryHeaderColor,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 15, 20, 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Icon(
                                                        Icons.arrow_back,
                                                        color: Get
                                                            .theme.primaryColor,
                                                      )),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .payment,
                                                    style: TextStyle(
                                                      color: Get
                                                          .theme.primaryColor,
                                                      fontSize: 20,
                                                      fontFamily: Get
                                                          .textTheme
                                                          .bodyLarge!
                                                          .fontFamily,
                                                      decoration:
                                                          TextDecoration.none,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InAppWebView(
                                          onUpdateVisitedHistory:
                                              (_, Uri? uri, __) {
                                            print(uri);
                                            if (uri.toString().trim() ==
                                                "https://vir2ell-office.com/LandingPage/en-US/Home/PackageSaleStep2") {
                                              Get.back();
                                              _controllerDB.updateLoginState(
                                                  Login.PinCode);
                                            }
                                          },
                                          androidOnPermissionRequest:
                                              (InAppWebViewController
                                                      controller,
                                                  String origin,
                                                  List<String>
                                                      resources) async {
                                            return PermissionRequestResponse(
                                                resources: resources,
                                                action:
                                                    PermissionRequestResponseAction
                                                        .GRANT);
                                          },
                                          initialOptions:
                                              InAppWebViewGroupOptions(
                                            crossPlatform: InAppWebViewOptions(
                                              useShouldOverrideUrlLoading: true,
                                              mediaPlaybackRequiresUserGesture:
                                                  false,
                                              userAgent:
                                                  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36 OPR/84.0.4316.21",
                                            ),
                                            android: AndroidInAppWebViewOptions(
                                              useHybridComposition: true,
                                            ),
                                            ios: IOSInAppWebViewOptions(
                                              allowsInlineMediaPlayback: true,
                                            ),
                                          ),
                                          initialUrlRequest: URLRequest(
                                              //! WebUri ile sarmalandi
                                              url: WebUri.uri(
                                            Uri.parse(!isInstructionView
                                                ? _launchURL(index)!
                                                : _launchURLDiscount(index)!),
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            //   bottomSheetWithWebView(_launchURL());
                          },
                          child: Container(
                            height: 40,
                            margin: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 10),
                            decoration: BoxDecoration(
                              color: Get.theme.primaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.choose,
                                  style: TextStyle(color: Colors.black),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          ),
          SizedBox(
            height: 20,
          )
        ]),
      ),
    );
  }

  String? _launchURL(int index) {
    if (index == 1) {
      if (AppLocalizations.of(context)!.language == "Türkçe") {
        return "https://vir2ell-office.com/LandingPage/tr-TR/Home/PackageDetail?key=859e3973-a628-4234-82e8-6d873240ca46&priceType=2";
      }
      if (AppLocalizations.of(context)!.language == "English") {
        return "https://vir2ell-office.com/LandingPage/en-US/Home/PackageDetail?key=859e3973-a628-4234-82e8-6d873240ca46&priceType=2";
      }
      if (AppLocalizations.of(context)!.language == "Sprache") {
        return "https://vir2ell-office.com/LandingPage/de-DE/Home/PackageDetail?key=859e3973-a628-4234-82e8-6d873240ca46&priceType=2";
      }
    } else if (index == 2) {
      if (AppLocalizations.of(context)!.language == "Türkçe") {
        return " https://vir2ell-office.com/LandingPage/tr-TR/Home/PackageDetail?key=20f79891-eb4b-4330-82c8-5b02c9006b6c&priceType=2";
      }
      if (AppLocalizations.of(context)!.language == "English") {
        return "https://vir2ell-office.com/LandingPage/en-US/Home/PackageDetail?key=20f79891-eb4b-4330-82c8-5b02c9006b6c&priceType=2";
      }
      if (AppLocalizations.of(context)!.language == "Sprache") {
        return "https://vir2ell-office.com/LandingPage/de-DE/Home/PackageDetail?key=20f79891-eb4b-4330-82c8-5b02c9006b6c&priceType=2";
      } else if (index == 3) {
        if (AppLocalizations.of(context)!.language == "Türkçe") {
          return "https://vir2ell-office.com/LandingPage/tr-TR/Home/PackageDetail?key=f96232ae-d868-440c-97fd-1ed2840c884a&priceType=2";
        }
        if (AppLocalizations.of(context)!.language == "English") {
          return "https://vir2ell-office.com/LandingPage/en-US/Home/PackageDetail?key=f96232ae-d868-440c-97fd-1ed2840c884a&priceType=2";
        }
        if (AppLocalizations.of(context)!.language == "Sprache") {
          return "https://vir2ell-office.com/LandingPage/de-DE/Home/PackageDetail?key=f96232ae-d868-440c-97fd-1ed2840c884a&priceType=2";
        }
      } else if (index == 4) {
        if (AppLocalizations.of(context)!.language == "Türkçe") {
          return "https://vir2ell-office.com/LandingPage/de-DE/Home/PackageDetail?key=84ff2c19-80ba-4295-8388-3eb4cb8390e7&priceType=2";
        }
        if (AppLocalizations.of(context)!.language == "English") {
          return "https://vir2ell-office.com/LandingPage/en-US/Home/PackageDetail?key=84ff2c19-80ba-4295-8388-3eb4cb8390e7&priceType=2";
        }
        if (AppLocalizations.of(context)!.language == "Sprache") {
          return "https://vir2ell-office.com/LandingPage/de-DE/Home/PackageDetail?key=84ff2c19-80ba-4295-8388-3eb4cb8390e7&priceType=2";
        }
      }
    }
    return null;
  }

  String? _launchURLDiscount(int index) {
    if (index == 1) {
      if (AppLocalizations.of(context)!.language == "Türkçe") {
        return "https://vir2ell-office.com/LandingPage/tr-TR/Home/PackageDetail?key=859e3973-a628-4234-82e8-6d873240ca46&priceType=1";
      }
      if (AppLocalizations.of(context)!.language == "English") {
        return "https://vir2ell-office.com/LandingPage/en-US/Home/PackageDetail?key=859e3973-a628-4234-82e8-6d873240ca46&priceType=1";
      }
      if (AppLocalizations.of(context)!.language == "Sprache") {
        return "https://vir2ell-office.com/LandingPage/de-DE/Home/PackageDetail?key=859e3973-a628-4234-82e8-6d873240ca46&priceType=1";
      }
    } else if (index == 2) {
      if (AppLocalizations.of(context)!.language == "Türkçe") {
        return " https://vir2ell-office.com/LandingPage/tr-TR/Home/PackageDetail?key=20f79891-eb4b-4330-82c8-5b02c9006b6c&priceType=1";
      }
      if (AppLocalizations.of(context)!.language == "English") {
        return "https://vir2ell-office.com/LandingPage/en-US/Home/PackageDetail?key=20f79891-eb4b-4330-82c8-5b02c9006b6c&priceType=1";
      }
      if (AppLocalizations.of(context)!.language == "Sprache") {
        return "https://vir2ell-office.com/LandingPage/de-DE/Home/PackageDetail?key=20f79891-eb4b-4330-82c8-5b02c9006b6c&priceType=1";
      } else if (index == 3) {
        if (AppLocalizations.of(context)!.language == "Türkçe") {
          return "https://vir2ell-office.com/LandingPage/tr-TR/Home/PackageDetail?key=f96232ae-d868-440c-97fd-1ed2840c884a&priceType=1";
        }
        if (AppLocalizations.of(context)!.language == "English") {
          return "https://vir2ell-office.com/LandingPage/en-US/Home/PackageDetail?key=f96232ae-d868-440c-97fd-1ed2840c884a&priceType=1";
        }
        if (AppLocalizations.of(context)!.language == "Sprache") {
          return "https://vir2ell-office.com/LandingPage/de-DE/Home/PackageDetail?key=f96232ae-d868-440c-97fd-1ed2840c884a&priceType=1";
        }
      } else if (index == 4) {
        if (AppLocalizations.of(context)!.language == "Türkçe") {
          return "https://vir2ell-office.com/LandingPage/de-DE/Home/PackageDetail?key=84ff2c19-80ba-4295-8388-3eb4cb8390e7&priceType=1";
        }
        if (AppLocalizations.of(context)!.language == "English") {
          return "https://vir2ell-office.com/LandingPage/en-US/Home/PackageDetail?key=84ff2c19-80ba-4295-8388-3eb4cb8390e7&priceType=1";
        }
        if (AppLocalizations.of(context)!.language == "Sprache") {
          return "https://vir2ell-office.com/LandingPage/de-DE/Home/PackageDetail?key=84ff2c19-80ba-4295-8388-3eb4cb8390e7&priceType=1";
        }
      }
    }
    return null;
  }
}
