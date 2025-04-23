import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Provider/LocaleProvider.dart';

import 'Controller/ControllerChatNew.dart';
import 'Controller/ControllerDB.dart';
import 'Controller/ControllerGetCalendarByUserId.dart';

Future<void> Vir2ellBackGrounMessageHandler(RemoteMessage newMessage) async {
  Map<String, dynamic> message = newMessage.data;

  await Firebase.initializeApp();
  SendNotification(message);
}

ControllerCommon _controllerCommon = Get.put(ControllerCommon());
ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
ControllerDB _controllerDB = Get.put(ControllerDB());
ControllerCalendar _controllerCalendar = Get.put(ControllerCalendar());
ControllerLocal _controllerLocal = Get.put(ControllerLocal());

BuildContext? context = Get.context;

Future<void> SendNotification(Map<String, dynamic> message) async {
  if (message["notificationTemplateType"].toString() == "16") {
    print('messsageeeee' + message.toString());
    final callParams = CallKitParams(
        id: message["notificationId"],
        nameCaller: message["message"],
        appName: 'Baulinx',
        avatar: message['photo'], // Optional
        handle: '',
        type: 0, // 0: audio call, 1: video call
        duration: 20000, // Duration of the call in milliseconds
        textAccept: AppLocalizations.of(context!)!.accept,
        textDecline: AppLocalizations.of(context!)!.decline,
        extra: message, // Optional additional data
        headers: {'apiKey': 'api123456', 'platform': 'flutter'});

    await FlutterCallkitIncoming.showCallkitIncoming(callParams);

    // AwesomeNotifications().createNotification(
    //   actionButtons: [
    //     NotificationActionButton(
    //       label: 'Accept',
    //       enabled: true,
    //       buttonType: ActionButtonType.Default,
    //       key: 'open',
    //     ),
    //     NotificationActionButton(
    //       label: 'Decline',
    //       enabled: true,
    //       buttonType: ActionButtonType.KeepOnTop,
    //       key: 'close',
    //     )
    //   ],
    //   content: NotificationContent(
    //     displayOnForeground: false,
    //     id: 0,
    //     channelKey: 'custom_sound',
    //     title: message["message"],
    //     customSound: "resource://raw/call",
    //     summary: message["meetingUrl"],
    //   ),
    // );
  }
  if (message["notificationTemplateType"].toString() == "19") {
    _controllerChatNew.GetUnreadCountByUserId(_controllerDB.headers());

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'basic_channel',
        title: message["title"],
        body: message["message"],
      ),
    );
  }
  if (message["notificationTemplateType"].toString() == "20") {
    await Future.delayed(Duration(seconds: 3));

    _controllerCommon.commobReloadforNotification = true;
    _controllerCommon.commonNotificationId = -1;
    _controllerCommon.update();
    _controllerCommon.commonRefreshCurrentPage = true;
    _controllerCommon.update();
    _controllerChatNew.loadChatUsers = true;
    _controllerChatNew.update();
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'basic_channel',
        title: message["title"],
        body: message["message"],
      ),
    );
  }
  if (message["notificationTemplateType"].toString() == "23") {
    await Future.delayed(Duration(seconds: 3));
    _controllerCalendar.refreshCalendar = true;
    _controllerCalendar.refreshCalendarDetail = true;
    _controllerCalendar.update();
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'basic_channel',
        title: message["title"],
        body: message["message"],
      ),
    );
  }
  if (message["notificationTemplateType"].toString() == "22") {
    await Future.delayed(Duration(seconds: 3));

    _controllerCommon.commobReloadforNotification = true;
    _controllerCommon.commonNotificationId = -1;

    _controllerCommon.update();
    _controllerCommon.commonRefreshCurrentPage = true;
    _controllerCommon.update();
    _controllerChatNew.loadChatUsers = true;
    _controllerChatNew.update();
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'basic_channel',
        title: message["title"],
        body: message["message"],
      ),
    );
  }
  if (message["notificationTemplateType"].toString() == "CommonTaskInvate") {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 0,
          channelKey: 'notificationType8',
          title: message["title"],
          body: message["message"],
          summary: message["userCommonOrderId"]),
    );
  }
  if (message["notificationTemplateType"].toString() == "9") {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'notificationType9',
        title: message["title"],
        body: message["message"],
        summary: message["notificationId"] ?? "",
      ),
    );
  }
  if (message["notificationTemplateType"].toString() == "8") {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'notificationType8',
        title: message["title"],
        body: message["message"],
        summary: message["notificationId"] ?? "",
      ),
    );
  }
  if (message["notificationTemplateType"].toString() == "7") {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'notificationType8',
        title: message["title"],
        body: message["message"],
        summary: message["notificationId"] ?? "",
      ),
    );
  }
  if (message["notificationTemplateType"].toString() == "13") {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'notificationType8',
        title: message["title"],
        body: message["message"],
        summary: "",
      ),
    );
  }
}
