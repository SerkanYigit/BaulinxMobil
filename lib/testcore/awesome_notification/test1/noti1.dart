/* import 'dart:ffi';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/core/awesome_notification/test1/HomePage.dart';
import 'package:undede/core/awesome_notification/test1/demopage.dart';
import 'package:undede/core/awesome_notification/test1/awesomefloating.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

Future<void> initializeNotification() async {
  await AwesomeNotifications().initialize(
    /*   null,
    [
      NotificationChannel(
        channelGroupKey: 'high_importance_channel',
        channelKey: 'high_importance_channel',
        channelName: 'Basic Notification',
        channelDescription: 'Notification channel for basic task',
        defaultColor: Colors.deepPurple,
        ledColor: Colors.red,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        onlyAlertOnce: true,
        playSound: true,
        criticalAlerts: true,
      )
   
   
   
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'high_importance_channel_group',
        channelGroupName: "Group 1",
      )
    ],
    */

    'resource://mipmap/ic_launcher',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel 123 123',
        ledColor: Colors.yellow,
        importance: NotificationImportance.High,
        defaultColor: Color(0xFF050606),
      ),
      NotificationChannel(
          channelKey: "custom_sound",
          channelName: "Custom sound notifications",
          channelDescription: "Notifications with custom sound",
          playSound: true,
          ledColor: Colors.orange,
          channelShowBadge: true,
          vibrationPattern: highVibrationPattern,
          importance: NotificationImportance.High,
          enableVibration: true,
          locked: true,
          defaultColor: Color(0xFF050606),
          defaultRingtoneType: DefaultRingtoneType.Ringtone),
      NotificationChannel(
        channelKey: 'notificationType8',
        channelName: 'notificationType8',
        channelDescription: 'notificationType8',
        ledColor: Colors.yellow,
        importance: NotificationImportance.High,
        defaultColor: Color(0xFF050606),
      ),
      NotificationChannel(
        channelKey: 'notificationType9',
        channelName: 'notificationType9',
        channelDescription: 'notificationType9',
        ledColor: Colors.yellow,
        importance: NotificationImportance.High,
        defaultColor: Color(0xFF050606),
      ),
      NotificationChannel(
        channelKey: 'download_channel',
        channelName: 'download notifications',
        channelDescription: 'download channel',
        ledColor: Colors.yellow,
        importance: NotificationImportance.High,
        defaultColor: Color(0xFF050606),
      ),
    ],
    debug: true,
  );

  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

/*   await AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
    onNotificationCreatedMethod: onNotificationCreatedMethod,
    onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: onDismissActionReceivedMethod,
  ); */
}

/* Future<void> onActionReceivedMethod(ReceivedAction recivedAction) async {
  debugPrint("On Action Recived +++++++++++++++++++++++++++");
  final payload = recivedAction.payload ?? {};
  recivedAction.channelKey == 'high_importance_channel'
      ? debugPrint('onActionReceivedMethod')
      : debugPrint('Custom channel');
        /* print(recivedAction);
        print(recivedAction.buttonKeyPressed);
        if (recivedAction.channelKey.toString() == "download_channel") {
          //  OpenFile.open(notification.summary);
        }
        if (recivedAction.channelKey.toString() == "notificationType9") {
          print(recivedAction.channelKey.toString());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationPage(),
            ),
          );
        }
        if (recivedAction.channelKey.toString() == "CommonInvate") {
          print(recivedAction.channelKey.toString());
          AwesomeDialog(
            context: context,
            btnCancelIcon: Icons.close,
            btnOkIcon: Icons.done,
            btnCancelText: recivedAction.of(context)!.decline,
            btnOkText: recivedAction.of(context)!.accept,
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
            title: recivedAction.body,
            desc: AppLocalizations.of(context)!.calling,
            btnCancelOnPress: () {
              UpdateNotification(recivedAction.id.toString(),
                  int.parse(recivedAction.summary.toString()), false);
            },
            btnOkOnPress: () {
              UpdateNotification(recivedAction.id.toString(),
                  int.parse(recivedAction.summary.toString()), true);
              _controllerCommon.commobReloadforNotification = true;
              _controllerCommon.update();
              _controllerCommon.commonRefreshCurrentPage = true;
              _controllerCommon.update();
              _controllerChatNew.loadChatUsers = true;
              _controllerChatNew.update();

              // showAsBottomSheet(message.data["meetingUrl"]);
            },
          )..show().whenComplete(() {});
        }
        if (notification.channelKey.toString() == "notificationType8") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationPage(),
            ),
          );
        }
        if (notification.channelKey.toString() == "basic_channel") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(),
            ),
          );
        }
        if (notification.channelKey.toString() == "custom_sound" &&
            notification.buttonKeyPressed.toString() == "open") {
          AwesomeDialog(
            context: context,
            btnCancelIcon: Icons.call_end,
            btnOkIcon: Icons.phone_in_talk,
            btnCancelText: AppLocalizations.of(context)!.decline,
            btnOkText: AppLocalizations.of(context)!.accept,
            customHeader: CircleAvatar(
              backgroundColor: Get.theme.primaryColor,
              child: Icon(
                Icons.wifi_calling_3,
                size: 40,
                color: Colors.red,
              ),
              radius: 40,
            ),
            animType: AnimType.bottomSlide,
            title: notification.body,
            desc: AppLocalizations.of(context)!.calling,
            btnCancelOnPress: () {},
            btnOkOnPress: () async {
              await permissions.Permission.camera.request();
              await permissions.Permission.microphone.request();
          //    notificationsActionStreamSubscription?.cancel();
              //! kaldirildi // AwesomeNotifications().actionSink.close();
           /*   AwesomeNotifications().actionSink.close();
              AwesomeNotifications().createdSink.close(); */
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => CallWeSlide(
                            url: notification.summary.toString(),
                          )),
                  (Route<dynamic> route) => false);
              // showAsBottomSheet(message.data["meetingUrl"]);
            },
          )
          ..show().whenComplete(() {});
        } */
      
/*   if (payload['navigate'] == 'true') {
    MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (_) => DemoPage(),
    ));
  } */
}


Future<ReceivedAction> onActionReceivedMethod2(ReceivedAction recivedAction) async {
  debugPrint("On Action Recived +++++++++++++++++++++++++++");
  final payload = recivedAction.payload ?? {};
  recivedAction.channelKey == 'high_importance_channel'
      ? debugPrint('onActionReceivedMethod')
      : debugPrint('Custom channel');
        /* print(recivedAction);
        print(recivedAction.buttonKeyPressed);
        if (recivedAction.channelKey.toString() == "download_channel") {
          //  OpenFile.open(notification.summary);
        }
        if (recivedAction.channelKey.toString() == "notificationType9") {
          print(recivedAction.channelKey.toString());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationPage(),
            ),
          );
        }
        if (recivedAction.channelKey.toString() == "CommonInvate") {
          print(recivedAction.channelKey.toString());
          AwesomeDialog(
            context: context,
            btnCancelIcon: Icons.close,
            btnOkIcon: Icons.done,
            btnCancelText: recivedAction.of(context)!.decline,
            btnOkText: recivedAction.of(context)!.accept,
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
            title: recivedAction.body,
            desc: AppLocalizations.of(context)!.calling,
            btnCancelOnPress: () {
              UpdateNotification(recivedAction.id.toString(),
                  int.parse(recivedAction.summary.toString()), false);
            },
            btnOkOnPress: () {
              UpdateNotification(recivedAction.id.toString(),
                  int.parse(recivedAction.summary.toString()), true);
              _controllerCommon.commobReloadforNotification = true;
              _controllerCommon.update();
              _controllerCommon.commonRefreshCurrentPage = true;
              _controllerCommon.update();
              _controllerChatNew.loadChatUsers = true;
              _controllerChatNew.update();

              // showAsBottomSheet(message.data["meetingUrl"]);
            },
          )..show().whenComplete(() {});
        }
        if (notification.channelKey.toString() == "notificationType8") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationPage(),
            ),
          );
        }
        if (notification.channelKey.toString() == "basic_channel") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(),
            ),
          );
        }
        if (notification.channelKey.toString() == "custom_sound" &&
            notification.buttonKeyPressed.toString() == "open") {
          AwesomeDialog(
            context: context,
            btnCancelIcon: Icons.call_end,
            btnOkIcon: Icons.phone_in_talk,
            btnCancelText: AppLocalizations.of(context)!.decline,
            btnOkText: AppLocalizations.of(context)!.accept,
            customHeader: CircleAvatar(
              backgroundColor: Get.theme.primaryColor,
              child: Icon(
                Icons.wifi_calling_3,
                size: 40,
                color: Colors.red,
              ),
              radius: 40,
            ),
            animType: AnimType.bottomSlide,
            title: notification.body,
            desc: AppLocalizations.of(context)!.calling,
            btnCancelOnPress: () {},
            btnOkOnPress: () async {
              await permissions.Permission.camera.request();
              await permissions.Permission.microphone.request();
          //    notificationsActionStreamSubscription?.cancel();
              //! kaldirildi // AwesomeNotifications().actionSink.close();
           /*   AwesomeNotifications().actionSink.close();
              AwesomeNotifications().createdSink.close(); */
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => CallWeSlide(
                            url: notification.summary.toString(),
                          )),
                  (Route<dynamic> route) => false);
              // showAsBottomSheet(message.data["meetingUrl"]);
            },
          )
          ..show().whenComplete(() {});
        } */
      
/*   if (payload['navigate'] == 'true') {
    MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (_) => DemoPage(),
    ));
  } */
 return recivedAction;
}
 */

Future<void> onActionNotificationMethod(ReceivedAction notification) async {
  debugPrint("On ACtion  Notification Method +++++++++++++++++++++++++++");
}

Future<void> onNotificationCreatedMethod(
    ReceivedNotification notification) async {
  debugPrint("On Notification Created Method +++++++++++++++++++++++++++");
}

Future<void> onNotificationDisplayedMethod(
    ReceivedNotification recivedAction) async {
  debugPrint("On Notification Displayed Method +++++++++++++++++++++++++++");
}

Future<void> onDismissActionReceivedMethod(ReceivedAction recivedAction) async {
  debugPrint("On Notification Received Method +++++++++++++++++++++++++++");
}
/* 
Future<void> showNotification({
  required final String title,
  required final String body,
  final String? summary,
  final Map<String, String>? payload,
  final ActionType actionType = ActionType.Default,
  final NotificationLayout notificationLayout = NotificationLayout.Default,
  final NotificationCategory? category,
  final String? bigPicture,
  final List<NotificationActionButton>? actionButtons,
  final bool scheduled = false,
  final int? interval,
}) async {
  assert(!scheduled || (scheduled && interval != null));
  //var inter= Duration(microseconds: (interval! * 1000).toInt());
  
 /*  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: -1,
      channelKey: 'high_importance_channel',
      title: title,
      body: body,
      actionType: actionType,
      notificationLayout: notificationLayout,
      summary: summary,
      category: category,
      payload: payload,
      bigPicture: bigPicture,
    ),
    actionButtons: actionButtons,
    schedule: 
         null,
  ); */
}
 */
 */
