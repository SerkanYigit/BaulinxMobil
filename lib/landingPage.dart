import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Pages/ForceUpdate/forceUpdatePage.dart';
import 'package:undede/Pages/Login/ConfirmSignUpPage.dart';
import 'package:undede/Pages/Login/PaymentPage.dart';
import 'package:undede/Pages/Login/PinNumberCheck.dart';
import 'package:undede/Provider/LocaleProvider.dart';
import 'package:undede/model/ForceUpdate/ForceUpdateData.dart';
import 'package:undede/widgets/CallWeSlide.dart';
import 'package:undede/widgets/FloatingNavigationBar.dart';
import 'package:undede/widgets/buildBottomNavigationBar.dart';
import 'package:sliding_sheet2/sliding_sheet2.dart';
import 'Controller/ControllerNotification.dart';
import 'Controller/ControllerTodo.dart';
import 'Custom/CustomLoadingCircle.dart';
import 'Pages/Chat/ChatPage.dart';
import 'Pages/HomePage/DashBoardNew.dart';
import 'Pages/Login/ForgotPassPage.dart';
import 'Pages/Login/SignInPageV2.dart';
import 'Pages/Login/SignUpPage.dart';
import 'Controller/ControllerDB.dart';
import 'NotificationHandler.dart';
import 'Pages/Login/VerificationCheck.dart';
import 'Pages/Login/rememberMeControl.dart';
import 'widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  ControllerDB c = Get.put(ControllerDB());
  bool isLoading = true;
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerTodo _controllerTodo = ControllerTodo();
  ControllerNotification _controllerNotification = ControllerNotification();
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  bool isUpdate = true;
  ForceUpdateData versionCheck = ForceUpdateData();
  StreamSubscription? _subscription;
  StreamSubscription? _subscription2;
  ControllerCalendar _controllerCalendar = Get.put(ControllerCalendar());

  ConfirmInviteUsersCommonTask(int UserCommonOrderId, bool IsAccept) {
    _controllerTodo.ConfirmInviteUsersCommonTask(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        UserCommonOrderId: UserCommonOrderId,
        IsAccept: IsAccept);
  }

  UpdateNotification(String Url, int NotificationId, bool IsAccept) {
    _controllerNotification.UpdateInviteProcess(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        Url: Url,
        NotificationId: NotificationId,
        IsAccept: IsAccept);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _subscription =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print(message);
        print("landing içi");
        if (message.data["notificationTemplateType"].toString() == "7") {
          AwesomeDialog(
            context: context,
            btnCancelIcon: Icons.close,
            btnOkIcon: Icons.done,
            btnCancelText: AppLocalizations.of(context)!.decline,
            btnOkText: AppLocalizations.of(context)!.accept,
            customHeader: CircleAvatar(
              backgroundColor: Get.theme.primaryColor,
              child: Icon(
                Icons.notifications,
                size: 40,
                color: Colors.black,
              ),
              radius: 40,
            ),
            animType: AnimType.bottomSlide,
            title: message.data["message"],
            desc: "",
            btnCancelOnPress: () {
              _controllerCommon.ConfirmInviteUsersCommonBoard(
                  _controllerDB.headers(),
                  NotificationId:
                      int.parse(message.data["notificationId"].toString()),
                  UserCommonOrderId:
                      int.parse(message.data["userCommonOrderId"].toString()),
                  IsAccept: false);
            },
            btnOkOnPress: () async {
              await _controllerCommon.ConfirmInviteUsersCommonBoard(
                  _controllerDB.headers(),
                  NotificationId:
                      int.parse(message.data["notificationId"].toString()),
                  //! TODO: Null hatasi. Ekrandaki notification a accept basildiginda null hatasi veriyor.
                  UserCommonOrderId:
                      int.parse(message.data["userCommonOrderId"].toString()),
                  IsAccept: true);
              _controllerBottomNavigationBar.lockUI = true;
              _controllerCommon.commonRefreshCurrentPage = true;
              _controllerCommon.update();
              _controllerCommon.commonNotificationId =
                  int.parse(message.data["commonId"].toString());
              _controllerBottomNavigationBar.goCollabPage = true;
              _controllerBottomNavigationBar.update();
            },
          )..show().whenComplete(() {});
        }
        if (message.data["notificationTemplateType"].toString() == "13") {
          AwesomeDialog(
            context: context,
            btnCancelIcon: Icons.close,
            btnOkIcon: Icons.done,
            btnCancelText: AppLocalizations.of(context)!.decline,
            btnOkText: AppLocalizations.of(context)!.accept,
            customHeader: CircleAvatar(
              backgroundColor: Get.theme.primaryColor,
              child: Icon(
                Icons.notifications,
                size: 40,
                color: Colors.black,
              ),
              radius: 40,
            ),
            animType: AnimType.bottomSlide,
            title: message.data["message"],
            desc: "",
            btnCancelOnPress: () async {
              await _controllerCalendar.ConfirmInviteCalendarUser(
                  _controllerDB.headers(),
                  NotificationId:
                      int.parse(message.data["notificationId"].toString()),
                  UserId: _controllerDB.user.value!.result!.id,
                  IsAccept: false,
                  Id: int.parse(message.data["ownerId"].toString()));
            },
            btnOkOnPress: () async {
              await _controllerCalendar.ConfirmInviteCalendarUser(
                  _controllerDB.headers(),
                  NotificationId:
                      int.parse(message.data["notificationId"].toString()),
                  UserId: _controllerDB.user.value!.result!.id,
                  IsAccept: true,
                  Id: int.parse(message.data["ownerId"].toString()));
              _controllerCalendar.refreshCalendarDetail = true;
              _controllerCalendar.refreshCalendar = true;
              _controllerCalendar.update();
            },
          )..show().whenComplete(() {});
        }

        if (message.data["notificationTemplateType"].toString() == "9") {
          AwesomeDialog(
            context: context,
            btnCancelIcon: Icons.close,
            btnOkIcon: Icons.done,
            btnCancelText: AppLocalizations.of(context)!.decline,
            btnOkText: AppLocalizations.of(context)!.accept,
            customHeader: CircleAvatar(
              backgroundColor: Get.theme.primaryColor,
              child: Icon(
                Icons.notifications,
                size: 40,
                color: Colors.black,
              ),
              radius: 40,
            ),
            animType: AnimType.bottomSlide,
            title: message.data["message"],
            desc: "",
            btnCancelOnPress: () {
              UpdateNotification(message.data["ownerId"].toString(),
                  int.parse(message.data["notificationId"].toString()), false);
            },
            btnOkOnPress: () {
              UpdateNotification(message.data["ownerId"].toString(),
                  int.parse(message.data["notificationId"].toString()), true);
              _controllerChatNew.loadChatUsers = true;
              _controllerChatNew.update();
            },
          )..show().whenComplete(() {});
        }
        if (message.data["notificationTemplateType"].toString() == "8") {
          AwesomeDialog(
            context: context,
            btnCancelIcon: Icons.close,
            btnOkIcon: Icons.done,
            btnCancelText: AppLocalizations.of(context)!.decline,
            btnOkText: AppLocalizations.of(context)!.accept,
            customHeader: CircleAvatar(
              backgroundColor: Get.theme.primaryColor,
              child: Icon(
                Icons.notifications,
                size: 40,
                color: Colors.black,
              ),
              radius: 40,
            ),
            animType: AnimType.bottomSlide,
            title: message.data["message"],
            desc: "",
            btnCancelOnPress: () {
              _controllerTodo.ConfirmInviteUsersCommonTask(
                  _controllerDB.headers(),
                  UserCommonOrderId:
                      int.parse(message.data["userCommonOrderId"].toString()),
                  NotificationId:
                      int.parse(message.data["notificationId"].toString()),
                  IsAccept: false);
            },
            btnOkOnPress: () async {
              await _controllerTodo.ConfirmInviteUsersCommonTask(
                  _controllerDB.headers(),
                  UserCommonOrderId:
                      int.parse(message.data["userCommonOrderId"].toString()),
                  NotificationId:
                      int.parse(message.data["notificationId"].toString()),
                  IsAccept: true);
              _controllerBottomNavigationBar.lockUI = true;
              _controllerBottomNavigationBar.update();
              _controllerDB.initializeNotificationList(
                  AppLocalizations.of(context)!.localeName);
              _controllerDB.update();
              _controllerCommon.commonNotificationId =
                  int.parse(message.data["commonId"].toString());
              _controllerCommon.todoNotificationId =
                  int.parse(message.data["todoId"].toString());
              _controllerCommon.update();
              _controllerCommon.commobReloadforNotification = true;
              _controllerCommon.update();
              _controllerChatNew.loadChatUsers = true;
              _controllerChatNew.update();
              _controllerBottomNavigationBar.goCollabPage = true;
              _controllerBottomNavigationBar.update();
            },
          )..show().whenComplete(() {});
        }

        if (message.data["notificationTemplateType"].toString() == "20") {
          await Future.delayed(Duration(seconds: 3));

          _controllerCommon.commobReloadforNotification = true;
          _controllerCommon.commonNotificationId = -1;
          _controllerDB.initializeNotificationList(
              AppLocalizations.of(context)!.localeName);
          _controllerDB.update();
          _controllerCommon.update();
          _controllerCommon.commonRefreshCurrentPage = true;
          _controllerCommon.update();
          _controllerChatNew.loadChatUsers = true;
          _controllerChatNew.update();
        }
        if (message.data["notificationTemplateType"].toString() == "22") {
          await Future.delayed(Duration(seconds: 3));
          _controllerDB.initializeNotificationList(
              AppLocalizations.of(context)!.localeName);
          _controllerDB.update();
          _controllerCommon.commobReloadforNotification = true;
          _controllerCommon.commonNotificationId = -1;
          _controllerCommon.update();
          _controllerCommon.commonRefreshCurrentPage = true;
          _controllerCommon.update();
          _controllerChatNew.loadChatUsers = true;
          _controllerChatNew.update();
        }
        if (message.data["notificationTemplateType"].toString() == "16" ||
            message.data["notificationTemplateType"].toString() == "Meeting") {
          await Permission.camera.request();
          await Permission.microphone.request();
          final callParams = CallKitParams(
              id: message.data["notificationId"],
              nameCaller: message.data["message"],
              appName: 'Baulinx',
              avatar: message.data['photo'], // Optional
              handle: '',
              type: 0, // 0: audio call, 1: video call
              duration: 20000, // Duration of the call in milliseconds
              textAccept: AppLocalizations.of(context)!.accept,
              textDecline: AppLocalizations.of(context)!.decline,
              extra: message.data, // Optional additional data
              headers: {'apiKey': 'api123456', 'platform': 'flutter'});

          await FlutterCallkitIncoming.showCallkitIncoming(callParams);
        }
        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
      });

      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String versionCurrent = packageInfo.buildNumber;
      /*if (versionCheck.forceUpdate == 1 &&
          int.parse(versionCheck.versionCode) > int.parse(versionCurrent)) {
        setState(() {
          isUpdate = false;
        });
      }*/
      // NotificationHandler().init();

      List<String>? temp =
          await RememberMeControl.instance.getRemember("login");
      print("temp nin içindyiz ");

      if (temp.isNotEmpty) {
        print("temp nin içindyiz ");
        await c
            .signIn(
                mail: temp[0],
                password: temp[1],
                rememberMe: true,
                langCode: AppLocalizations.of(context)!.localeName)
            .then((value) {
          if (value != null) {
            print("Hatalı Kayıt" + value.toString());
          }
        });
      }
      /*   await c
          .signIn(
              mail: temp[0],
              password: temp[1],
              rememberMe: true,
              langCode: AppLocalizations.of(context)!.localeName)
          .then((value) {
        if (value != null) {
          print("Hatalı Kayıt" + value.toString());
        }
      }); */

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _subscription!.cancel();
    print("disposekeeee");
    super.dispose();
  }

  void showAsBottomSheet(String url) async {
    final result = await showSlidingBottomSheet(context, builder: (context) {
      return SlidingSheetDialog(
        extendBody: true,
        avoidStatusBar: true,
        isBackdropInteractable: true,
        elevation: 8,
        cornerRadius: 16,
        margin: EdgeInsets.only(bottom: 100),
        minHeight: 127,
        isDismissable: false,
        builder: (context, state) {
          return Container(
            height: Get.height - 200,
            child: Stack(
              children: [
                InAppWebView(
                    androidOnPermissionRequest:
                        (InAppWebViewController controller, String origin,
                            List<String> resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          useShouldOverrideUrlLoading: true,
                          mediaPlaybackRequiresUserGesture: false,
                          userAgent:
                              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36 OPR/81.0.4196.60",
                        ),
                        android: AndroidInAppWebViewOptions(
                          useHybridComposition: true,
                        ),
                        ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                        )),
                    initialUrlRequest: URLRequest(
                      url: WebUri.uri(Uri.parse(url)), //! Weburi eklendi
                    )),
                Positioned(
                  left: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Get.theme.primaryColor),
                      child: Icon(Icons.close),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      );
    });

    print(result); // This is the result.
  }

  @override
  Widget build(BuildContext context) {
    Get.put(ControllerDB());
    print(c.login!.value);
    return GetBuilder<ControllerDB>(builder: (c) {
      return c.isLoading.value == true || isLoading
          ? CustomLoadingCircle()
          : c.isLoading.value == true //!isUpdate
              ? ForceUpdatePage(versionCheck)
              : c.user.value?.result?.id == null
                  ? c.login!.value == Login.SignIn
                      ? SignInPageV2() //SignInPage()
                      : c.login!.value == Login.Forgot
                          ? ForgotPassPage()
                          : c.login!.value == Login.Payment
                              ? PaymentPage()
                              : c.login!.value == Login.SignUpConfirm
                                  ? ConfirmSignUpPage()
                                  : c.login!.value == Login.PinCode
                                      ? PinCodeVerificationScreen()
                                      : c.login!.value ==
                                              Login.VerificationCheck
                                          ? VerificationCheck()
                                          : SignUpPage()
                  : FloatingNavigationBar();
      // BuildBottomNavigationBar(
      //    page: 0,
      // );
    });
  }
}
