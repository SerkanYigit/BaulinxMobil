import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';

Future<void> initializeNotification() async {
  await AwesomeNotifications().initialize(
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

  // Bildirim izni kontrolü
  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  // DİKKAT: setListeners'ı aktifleştiriyoruz!
  await AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
    onNotificationCreatedMethod: onNotificationCreatedMethod,
    onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: onDismissActionReceivedMethod,
  );
}

//--------------------------------------------------
// Doğru Metodlar (Global olarak tanımlanmalı)
//--------------------------------------------------

// Kullanıcı bildirimde bir aksiyon alındığında (butona tıklandığında)
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  debugPrint("Aksiyon alındı: ${receivedAction.body}");
  // Örnek: Bildirim tıklandığında sayfaya yönlendir
  if (receivedAction.channelKey == 'basic_channel') {
    Get.to(() => NotificationPage()); // GetX ile yönlendirme
  }
}

// Bildirim oluşturulduğunda (sunucudan gelip cihaza ulaştığında)
Future<void> onNotificationCreatedMethod(
    ReceivedNotification notification) async {
  debugPrint("Bildirim oluşturuldu: ${notification.body}");
}

// Bildirim gösterildiğinde (kullanıcıya göründüğünde)
Future<void> onNotificationDisplayedMethod(
    ReceivedNotification notification) async {
  debugPrint("Bildirim gösterildi: ${notification.body}");
}

// Bildirim kapatıldığında
Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction) async {
  debugPrint("Bildirim kapatıldı: ${receivedAction.body}");
}
