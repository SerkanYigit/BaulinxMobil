import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'dart:convert';

Future<void> myBackgroundMessageHandler(RemoteMessage newMessage) async {
  Map<String, dynamic> message = newMessage.data;
  await Firebase.initializeApp();

  print(message);
  print("burdayım2");

  if (message['Type'] == "1") {
    NotificationHandler.updateCount(message['Id']);
  }

  // NotificationHandler.showNotification(message);
}

class NotificationHandler {
  // FirebaseMessaging _firebaseMessaging = FirebaseMessaging;

  static final NotificationHandler _instance = NotificationHandler._();

  factory NotificationHandler() => _instance;

  NotificationHandler._();

  Future<void> init() async {
    print("init içi");
/*
    AwesomeNotifications().actionStream.listen((receivedNotification) {
      print("receivedNotification = " + receivedNotification.toString());
      print("receivedNotification payload = " +
          receivedNotification.payload.toString());
      print("receivedNotification  toMap = " +
          receivedNotification.toMap().toString());
      onSelectNotification(jsonEncode(receivedNotification.payload));
      print("init içi2");
    });
*/
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("event.data" + event.data.toString());

      onSelectNotification(jsonEncode(event.data));
      print("init içi3");
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      onSelectNotification(jsonEncode(message!.data));
      print("init içi4");
        });
  }

  void onLorR(RemoteMessage newMessage) {
    var message = newMessage.data;

    NotificationHandler.updateCount(message['Id'].toString());
    onSelectNotification(jsonEncode(newMessage.data));
  }

  static void updateCount(String key) async {
    /* MySharedPreferencesForNotification _countDB = MySharedPreferencesForNotification.instance;
    List<String> a = await _countDB.getCount(key);
    if (a != null) {
      int old = int.parse(a.first);
      old++;
      _countDB.setCount(key, [old.toString()]);
    } else {
      _countDB.setCount(key, ["1"]);
    }
    NotificationHandler.updateTotalCount();*/
  }

  static void updateTotalCount() async {
    /*String key = 'chat';

    MySharedPreferencesForNotification _countDB = MySharedPreferencesForNotification.instance;
    List<String> a = await _countDB.getCount(key);
    if (a != null) {
      int old = int.parse(a.first);
      old++;
      _countDB.setCount(key, [old.toString()]);
    } else {
      _countDB.setCount(key, ["1"]);
    }*/
  }

  static void showNotification(
    Map<String, dynamic> messageData,
    // RemoteNotification messageNot,
  ) async {
    print("show Notification");
    /*ControllerDB _controllerDB = Get.put(ControllerDB());

    if(messageData['Type']!="1"){
      String key="notification";
      MySharedPreferencesForNotification _countDB = MySharedPreferencesForNotification.instance;
      List<String> a = await _countDB.getCount(key);
      if (a != null) {
        int old = int.parse(a.first);
        old++;
        _countDB.setCount(key, [old.toString()]);
        _controllerDB.notificationCount=old.obs;
        _controllerDB.update();
      } else {
        _countDB.setCount(key, ["1"]);
        _controllerDB.notificationCount=1.obs;
        _controllerDB.update();

      }

    }*/
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'basic_channel',
        title: messageData["title"],
        body: messageData["message"],
      ),
    );
  }

  Future onSelectNotification(String payload) async {
    Map<String, dynamic> notification = jsonDecode(payload);
    debugPrint("ife girdi girecek $payload ");

    onTapWithType(notification);
    }

  onTapWithType(Map<String, dynamic> notification) async {
    //  ControllerChat _controllerChat = Get.put(ControllerChat());
    ControllerDB _controllerDB = Get.put(ControllerDB());
  }
}
