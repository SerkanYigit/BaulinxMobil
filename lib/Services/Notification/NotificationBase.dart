import 'package:undede/model/Common/DataLayoutAPI.dart';
import 'package:undede/model/Notifications/GetNotificationListResult.dart';

abstract class NotificationBase {
  Future<GetNotificationListResult> GetNotificationList(
      Map<String, String> header,
      {int UserId,
      int CustomerId,
      String Language,
      bool isRead});
  Future<DataLayoutAPI> UpdateInviteProcess(Map<String, String> header,
      {int UserId, String Url, int NotificationId, bool IsAccept});
  Future UpdateAllNotificationRead(Map<String, String> header);
}
