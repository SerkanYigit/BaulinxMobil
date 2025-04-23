import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:undede/Services/Notification/NotificationBase.dart';
import 'package:undede/model/Common/DataLayoutAPI.dart';
import 'package:undede/model/Notifications/GetNotificationListResult.dart';
import '../ServiceUrl.dart';

class NotificationDB implements NotificationBase {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<GetNotificationListResult> GetNotificationList(
    Map<String, String> header, {
    int? UserId,
    int? CustomerId,
    String? Language,
    bool? isRead,
    int? PageIndex,
  }) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "Language": Language,
      "isRead": isRead,
      "Page": PageIndex,
      "Take": 10,
    });

    var response = await http.post(Uri.parse(_serviceUrl.getNotification),
        headers: header, body: reqBody);

    log("req GetNotificationList = " + reqBody.toString());
    log("res GetNotificationList = " + response.body);

    if (response.body.isEmpty) {
      return GetNotificationListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetNotificationListResult.fromJson(responseData);
    }
  }

  @override
  Future<DataLayoutAPI> UpdateInviteProcess(Map<String, String> header,
      {int? UserId, String? Url, int? NotificationId, bool? IsAccept}) async {
    var body = jsonEncode({
      "UserId": UserId,
      "Url": Url,
      "NotificationId": NotificationId,
      "IsAccept": IsAccept
    });
    var response = await http.post(Uri.parse(_serviceUrl.updateInviteProcess),
        headers: header, body: body);

    log("req UpdateInviteProcess = " + body);
    log("res UpdateInviteProcess = " + response.body);

    if (response.body.isEmpty) {
      return DataLayoutAPI(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return DataLayoutAPI.fromJson(responseData);
    }
  }

  @override
  Future<bool> UpdateAllNotificationRead(Map<String, String> header) async {
    var response = await http.post(
      Uri.parse(_serviceUrl.updateAllNotificationRead),
      headers: header,
    );

    log("res UpdateAllNotificationRead = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }
}
