import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ServiceUrl.dart';

class BlockReportDB {
  final ServiceUrl _serviceUrl = ServiceUrl();

  Future<bool?> BlockUser(Map<String, String> header,
      {int? userId, int? blockedUserId, int? blockType}) async {
    var reqBody = jsonEncode({
      "UserId": userId,
      "BlockedUserId": blockedUserId,
      "BlockType": blockType
    });
    var response = await http.post(Uri.parse(_serviceUrl.blockUser),
        headers: header, body: reqBody);

    print("req BlockUser: " + reqBody);
    print("res BlockUser: " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["Result"];
    }
  }

  Future<bool?> UnBlockUser(Map<String, String> header,
      {int? userId, int? blockedUserId, int? blockType}) async {
    var reqBody = jsonEncode({
      "UserId": userId,
      "BlockedUserId": blockedUserId,
      "BlockType": blockType
    });
    var response = await http.post(Uri.parse(_serviceUrl.unBlockUser),
        headers: header, body: reqBody);

    print("req UnBlockUser: " + reqBody);
    print("res UnBlockUser: " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["Result"];
    }
  }

  Future<bool?> ReportUser(Map<String, String> header,
      {int? userId,
      int? reportedUserId,
      String? reportMessage,
      int? blockType}) async {
    var reqBody = jsonEncode({
      "UserId": userId,
      "ReportedUserId": reportedUserId,
      "ReportMessage": reportMessage,
      "BlockType": blockType,
    });
    var response = await http.post(Uri.parse(_serviceUrl.reportUser),
        headers: header, body: reqBody);

    print("req ReportUser: " + reqBody);
    print("res ReportUser: " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["Result"];
    }
  }
}
