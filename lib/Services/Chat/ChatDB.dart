import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Services/Chat/ChatBase.dart';
import 'package:undede/model/Chat/ChatFileInsert.dart';
import 'package:undede/model/Chat/ChatMessageSaveResult.dart';
import 'package:undede/model/Chat/GetChatResult.dart';
import 'package:undede/model/Chat/GetGroupChatUserListResult.dart';
import 'package:undede/model/Chat/GetPublicChatListResult.dart';
import 'package:undede/model/Chat/GetUnreadCountByUserIdResult.dart';
import 'package:undede/model/Chat/GetUserListUser.dart';
import '../ServiceUrl.dart';

class ChatDB implements ChatBase {
  final ServiceUrl _serviceUrl = ServiceUrl();
  ControllerDB _controllerDB = Get.put(ControllerDB());

  @override
  Future<ChatMessageSaveResult> ChatMessageSave(Map<String, String> header,
      {int? Id,
      int? ReceiverId,
      int? SenderId,
      int? Type,
      int? GroupId,
      int? PublicId,
      String? Message,
      String? MessageBase64,
      ChatFileInsert? Files,
      int? RelatedMessageId}) async {
    var body = jsonEncode({
      "Id": Id,
      "ReceiverId": ReceiverId,
      "SenderId": SenderId,
      "Type": Type,
      "GroupId": GroupId,
      "PublicId": PublicId,
      "Message": Message,
      "MessageBase64": MessageBase64,
      "FileList": Files?.fileList ?? null,
      "RelatedMessageId": RelatedMessageId
    });
    var response = await http.post(Uri.parse(_serviceUrl.postChatMessageSave),
        headers: header, body: body);

    log("req ChatMessageSaveResult = " + body.toString());
    log("res ChatMessageSaveResult = " + response.body);

    if (response.body.isEmpty) {
      return ChatMessageSaveResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseData["HasError"]) {
        showErrorToast(responseData["ResultMessage"]);
      }
      return ChatMessageSaveResult.fromJson(responseData);
    }
  }

  @override
  Future<GetChatResult> GetChat(Map<String, String> header, int id,
      int isPublic, int isGroup, int lastLoadedMessageId) async {
    var response = await http.get(
        Uri.parse(_serviceUrl.getChat +
            "?request.id=${id}&request.isPublic=0&request.isGroup=$isGroup&request.lastLoadedMessageId=$lastLoadedMessageId"),
        headers: header);

    log("req GetChatResult = " + response.request!.url.toString());
    log("res GetChatResult = " + response.body);

    if (response.body.isEmpty) {
      return GetChatResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetChatResult.fromJson(responseData);
    }
  }

  @override
  Future<GetUserListResult> GetUserList(
      Map<String, String> header, int userId) async {
    var response = await http.get(
        Uri.parse(_serviceUrl.getUserList + "?request.userId=${userId}"),
        headers: header);

    log("req GetUserList = " + response.request!.url.toString());
    log("res GetUserList = " + response.body);

    if (response.body.isEmpty) {
      return GetUserListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetUserListResult.fromJson(responseData);
    }
  }

  DeleteMessage(int messageId) async {
    await http.get(
        Uri.parse(_serviceUrl.deleteChatMessage + "?Id=${messageId}"),
        headers: _controllerDB.headers());
  }

  SetChatUnread(int senderUserId) async {
    var response = await http.post(
        Uri.parse(_serviceUrl.setChatUnread + "?senderUserId=${senderUserId}"),
        headers: _controllerDB.headers());
    log("res senderUserId = " + senderUserId.toString());

    log("res SetChatUnread = " + response.body);
  }

  @override
  Future<GetPublicChatListResult> GetPublicChatList(
      Map<String, String> header) async {
    var response = await http.get(Uri.parse(_serviceUrl.getPublicChatList),
        headers: header);

    //log("req GetAllCommons = " + response.request.url.toString());
    log("res GetPublicChatListResult = " + response.body);

    if (response.body.isEmpty) {
      return GetPublicChatListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetPublicChatListResult.fromJson(responseData);
    }
  }

  @override
  Future InsertChatGroupUser(Map<String, String> header,
      {int? GroupId, List<int>? UserIds}) async {
    var response = await http.post(Uri.parse(_serviceUrl.insertChatGroupUser),
        headers: header,
        body: jsonEncode({
          "GroupId": GroupId,
          "UserIds": UserIds,
        }));

    //log("req GetAllCommons = " + response.request.url.toString());
    //log("res GetAllCommons = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future NewGroupChat(Map<String, String> header,
      {List<int>? UserIdList, String? Title}) async {
    var response = await http.post(Uri.parse(_serviceUrl.newGroupChat),
        headers: header,
        body: jsonEncode({"UserIdList": UserIdList, "Title": Title}));

    //log("req GetAllCommons = " + response.request.url.toString());
    //log("res GetAllCommons = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future NewPublicChat(Map<String, String> header, {String? Title}) async {
    var response = await http.post(
      Uri.parse(_serviceUrl.newPublicChat + "?Title=$Title"),
      headers: header,
    );

    //log("req GetAllCommons = " + response.request.url.toString());
    //log("res GetAllCommons = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future UpdateChatGroupTitle(Map<String, String> header,
      {int? GroupId, String? Title}) async {
    var response = await http.post(Uri.parse(_serviceUrl.updateChatGroupTitle),
        headers: header,
        body: jsonEncode({"GroupId": GroupId, "Title": Title}));

    //log("req GetAllCommons = " + response.request.url.toString());
    //log("res GetAllCommons = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future UpdateGroupChatPicture(Map<String, String> header,
      {int? GroupId, String? FileName, String? Base64}) async {
    var response = await http.post(
        Uri.parse(_serviceUrl.updateGroupChatPicture),
        headers: header,
        body: jsonEncode(
            {"GroupId": GroupId, "FileName": FileName, "Base64": Base64}));

    //log("req GetAllCommons = " + response.request.url.toString());
    log("res UpdateGroupChatPicture = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future removeUserFromGroupChat(Map<String, String> header,
      {int? GroupId, int? UserId}) async {
    var response =
        await http.post(Uri.parse(_serviceUrl.removeUserFromGroupChat),
            headers: header,
            body: jsonEncode({
              "GroupId": GroupId,
              "UserId": UserId,
            }));

    //log("req GetAllCommons = " + response.request.url.toString());
    //log("res GetAllCommons = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future<GetGroupChatUserListResult> GetGroupChatUserList(
      Map<String, String> header, int? GroupId) async {
    var response = await http.get(
      Uri.parse(_serviceUrl.getGroupChatUserList + "?GroupId=$GroupId"),
      headers: header,
    );

    log("req GetGroupChatUserList = " + response.request!.url.toString());
    log("res GetGroupChatUserList = " + response.body);

    if (response.body.isEmpty) {
      return GetGroupChatUserListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetGroupChatUserListResult.fromJson(responseData);
    }
  }

  @override
  Future<GetUnreadCountByUserIdResult> GetUnreadCountByUserId(
    Map<String, String> header,
  ) async {
    var response = await http.get(
      Uri.parse(_serviceUrl.getUnreadCountByUserId +
          "?request.userId=${_controllerDB.user.value!.result!.id}"),
      headers: header,
    );

    log("req GetUnreadCountByUserIdResult = " +
        response.request!.url.toString());
    log("res GetUnreadCountByUserIdResult = " + response.body);

    if (response.body.isEmpty) {
      return GetUnreadCountByUserIdResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetUnreadCountByUserIdResult.fromJson(responseData);
    }
  }

  @override
  Future<bool> ForwardMessages(Map<String, String> header,
      {int? UserId,
      List<int>? MessageList,
      List<int>? ForwardUserList,
      List<int>? ForwardGroupChat}) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
      "MessageList": MessageList,
      "ForwardUserList": ForwardUserList,
      "ForwardGroupChat": ForwardGroupChat,
    });
    var response = await http.post(Uri.parse(_serviceUrl.forwardMessages),
        headers: header, body: reqBody);

    log("req ForwardMessages = " + reqBody);
    log("res ForwardMessages = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      //final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }
}
