/* import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationServiceAwesome {
  static Future<void> showNotification(String title, String body) async {
    Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
      if (receivedAction.actionType == ActionType.Default) {
        print('Kullanıcı bildirimi tıkladı: ${receivedAction.title}');
        receivedAction.channelKey == 'basic_channel'
            ? print('onActionReceivedMethod')
            : print('Custom channel');
        receivedAction.buttonKeyPressed == 'open'
            ? print('Opened')
            : print('Icon');
      }
    }

    Future<void> onNotificationCreatedMethod(
        ReceivedNotification receivedNotification) async {
      print('Bildirim oluşturuldu: ${receivedNotification.title}');
      receivedNotification.channelKey == 'basic_channel'
          ? print('onNotificationCreatedMethod')
          : print('Custom channel');
    }

    Future<void> onNotificationDisplayedMethod(
        ReceivedNotification receivedNotification) async {
      print('Bildirim gösterildi: ${receivedNotification.title}');
      receivedNotification.channelKey == 'basic_channel'
          ? print('onNotificationDisplayedMethod')
          : print('Custom channel');
    }

    Future<void> onNotificationDismissedMethod(
        ReceivedAction receivedAction) async {
      print('Bildirim kapatıldı: ${receivedAction.title}');
      receivedAction.channelKey == 'basic_channel'
          ? print('onNotificationDismissedMethod')
          : print('Custom channel');
    }

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onNotificationDismissedMethod,
    );
  }
}
 */
