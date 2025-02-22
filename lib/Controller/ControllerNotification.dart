import 'dart:async';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/showToast.dart';

import 'package:undede/Services/Notification/NotificationBase.dart';
import 'package:undede/Services/Notification/NotificationDB.dart';
import 'package:undede/model/Common/DataLayoutAPI.dart';

import 'package:undede/model/Notifications/GetNotificationListResult.dart';

class ControllerNotification extends GetxController
    implements NotificationBase {
  NotificationDB _notificationDB = NotificationDB();
  ControllerDB _controllerDB = Get.put(ControllerDB());

  @override
  Future<GetNotificationListResult> GetNotificationList(
      Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      String? Language,
      bool? isRead}) async {
    var value = await _notificationDB.GetNotificationList(header,
        UserId: UserId!,
        CustomerId: CustomerId!,
        Language: Language!,
        isRead: isRead!);
    return value;
  }

  @override
  Future<DataLayoutAPI> UpdateInviteProcess(Map<String, String> header,
      {int? UserId, String? Url, int? NotificationId, bool? IsAccept}) async {
    DataLayoutAPI res = await _notificationDB.UpdateInviteProcess(
      header,
      UserId: _controllerDB.user.value!.result!.id,
      Url: Url!,
      NotificationId: NotificationId!,
      IsAccept: IsAccept!,
    );

    if (!res.hasError!) {
      _controllerDB.notifications
          .firstWhere((x) => x.id == NotificationId)
          .isRead = true;
      if (_controllerDB.notificationUnreadCount > 0) {
        _controllerDB.notificationUnreadCount -= 1;
        _controllerDB.notificationReadCount += 1;
        _controllerDB.update();
      }
    } else {
      showErrorToast(res.resultMessage!);
    }

    return res;
  }

  @override
  Future UpdateAllNotificationRead(Map<String, String> header) async {
    bool hasError = await _notificationDB.UpdateAllNotificationRead(header);
    if (!hasError) {
      _controllerDB.notifications.forEach((n) {
        n.isRead = true;
      });
      _controllerDB.update();
    }
    return hasError;
  }
}
