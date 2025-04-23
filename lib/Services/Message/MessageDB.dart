import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:undede/Services/Message/MessageBase.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/Message/GetMessageByUserIdResult.dart';
import '../../model/Common/MessageCategoryResult.dart';
import '../ServiceUrl.dart';

class MessageDB implements MessageBase {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<GetMessageByUserIdResult> GetMessageByUserIdSent(
      Map<String, String> header,
      {int? UserId,
      int? Page,
      int? Size,
      int? Type}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getMessageByUserId),
        headers: header,
        body: jsonEncode(
            {"UserId": UserId, "Page": Page, "Size": Size, "Type": Type}));

    //log("req GetAllCommons = " + response.request.url.toString());
    print("*********************");

    log("res GetMessageByUserId = " + response.body);
    print("*********************");

    if (response.body.isEmpty) {
      return GetMessageByUserIdResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return GetMessageByUserIdResult.fromJson(responseData);
    }
  }

  @override
  Future<GetMessageByUserIdResult> GetMessageByUserIdReceived(
      Map<String, String> header,
      {int? UserId,
      int? Page,
      int? Size,
      int? Type}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getMessageByUserId),
        headers: header,
        body: jsonEncode(
            {"UserId": UserId, "Page": Page, "Size": Size, "Type": Type}));

    //log("req GetAllCommons = " + response.request.url.toString());
    print("*********************");

    log("res GetMessageByUserId = " + response.body);
    print("*********************");

    if (response.body.isEmpty) {
      return GetMessageByUserIdResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return GetMessageByUserIdResult.fromJson(responseData);
    }
  }

  @override
  Future<GetMessageByUserIdResult> GetMessageByUserIdAll(
      Map<String, String> header,
      {int? UserId,
      int? Page,
      int? Size,
      int? Type}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getMessageByUserId),
        headers: header,
        body: jsonEncode(
            {"UserId": UserId, "Page": Page, "Size": Size, "Type": Type}));

    //log("req GetAllCommons = " + response.request.url.toString());
    print(
        "GetMessageByUserId********************* $UserId ***** $Page ***** $Size ***** $Type");
    log("res GetMessageByUserId = " + response.body);
    print("*********************");
    if (response.body.isEmpty) {
      return GetMessageByUserIdResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return GetMessageByUserIdResult.fromJson(responseData);
    }
  }

  @override
  Future<GetMessageByUserIdResult> GetMessageByUserIdDeleted(
      Map<String, String> header,
      {int? UserId,
      int? Page,
      int? Size,
      int? Type}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getMessageByUserId),
        headers: header,
        body: jsonEncode(
            {"UserId": UserId, "Page": Page, "Size": Size, "Type": Type}));

    //log("req GetAllCommons = " + response.request.url.toString());
    print("*********************");

    log("res GetMessageByUserId = " + response.body);
    print("*********************");

    if (response.body.isEmpty) {
      return GetMessageByUserIdResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return GetMessageByUserIdResult.fromJson(responseData);
    }
  }

  @override
  Future DeleteMessage(Map<String, String> header,
      {int? UserId, int? MessageId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.deleteMessage),
        headers: header,
        body: jsonEncode({"UserId": UserId, "MessageId": MessageId}));

    //log("req GetAllCommons = " + response.request.url.toString());
    print("*********************");

    log("res GetMessageByUserId = " + response.body);
    print("*********************");

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return true;
    }
  }

  @override
  Future GetMessageDetail(Map<String, String> header,
      {int? UserId, int? MessageId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getMessageDetail),
        headers: header,
        body: jsonEncode({"UserId": UserId, "MessageId": MessageId}));

    //log("req GetAllCommons = " + response.request.url.toString());
    log("res GetMessageDetail = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return true;
    }
  }

  @override
  Future<MessageCategory> GetMessageCategory(Map<String, String> header,
      {int? UserId, String? LanguageId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getMessageCategory),
        headers: header,
        body: jsonEncode({"UserId": UserId, "LanguageId": LanguageId}));

    //log("req GetAllCommons = " + response.request.url.toString());
    log("res GetMessageCategory = " + response.body);

    if (response.body.isEmpty) {
      return MessageCategory(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return MessageCategory.fromJson(responseData);
    }
  }

  @override
  Future SendMessage(Map<String, String> header,
      {int? UserId,
      int? CommonGroupId,
      int? MessageCategoryId,
      String? MessageSubject,
      String? MessageText,
      int? MainMessageId,
      List<int>? RecipientUserList,
      bool? IsCombine,
      Files? FileInputList}) async {
    var reqbody = jsonEncode({
      "UserId": UserId,
      "MessageSubject": MessageSubject,
      "MessageText": MessageText,
      "MainMessageId": MainMessageId,
      "RecipientUserList": RecipientUserList,
      "IsCombine": IsCombine,
      "FileInputList": FileInputList?.fileInput,
      "CommonGroupId": CommonGroupId,
      "MessageCategoryId": MessageCategoryId
    });
    var response = await http.post(Uri.parse(_serviceUrl.sendMessage),
        headers: header, body: reqbody);

    print("*********************");
    log("req SendMessage = " + reqbody.toString());
    log("res SendMessage = " + response.body);
    print("*********************");

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return true;
    }
  }

  @override
  Future<bool> SendMessageNew(
    Map<String, String> header, {
    int? userId,
    String? from, // Required field for the sender email
    int? selectedCustomerId = -1, // Default to -1 if not provided
    int? selectedCustomerAdminId = -1, // Default to -1 if not provided
    List<String>?
        recipientUserList, // This is required based on the body you provided
    List<String>? cc = const [], // Optional, default to empty string
    List<String>? bcc = const [], // Optional, default to empty string
    String? subject, // Required field for the email subject
    String? message, // Required field for the message body
    List<String>? recipientUserLists, // Optional, can mirror recipientUserList
    Map<String, dynamic>? options =
        const {}, // Optional, default to empty object
  }) async {
    print('from' +
        from! +
        'recipientUserList' +
        recipientUserList.toString() +
        'subject' +
        subject! +
        'message' +
        message!);
    // Prepare FormData

    var reqBody = jsonEncode({
      "recipientUserList": recipientUserList,
      "ccList": cc,
      "bccList": bcc,
      "subject": subject,
      "message": message
    });

    try {
      // Initialize Dio
      Dio dio = Dio();

      // Send the POST request with FormData
      var response = await dio.post(
        _serviceUrl.sendMessageNew, // Your endpoint URL
        data: reqBody,
        options: Options(
          headers: header, // Your headers
        ),
      );

      // Logging the request and response for debugging purposes
      // Handle response
      if (response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        print('responsedataaaaaa' + responseData.toString());
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  @override
  Future SetMessageRead(Map<String, String> header,
      {int? UserId, int? MessageId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.setMessageRead),
        headers: header,
        body: jsonEncode({"UserId": UserId, "MessageId": MessageId}));

    //log("req GetAllCommons = " + response.request.url.toString());
    print("*********************");

    log("res GetMessageByUserId = " + response.body);
    print("*********************");

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return true;
    }
  }

  @override
  Future GetUserEmails(Map<String, String> header, {int? UserId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getUserEmails),
        headers: header,
        body: jsonEncode({
          "UserId": UserId,
        }));

    //log("req GetAllCommons = " + response.request.url.toString());
    print("*********************");

    log("res GetMessageByUserIdd = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return EmailList.fromJson(responseData);
    }
  }

  @override
  Future GetMailFolders(Map<String, String> header,
      {String? UserEmail, int? UserId, String? folderName}) async {
    print('GetMailFolders' + UserEmail!);
    var response = await http.post(Uri.parse(_serviceUrl.getMailFolders),
        headers: header,
        body: jsonEncode({
          "UserEmail": UserEmail,
          // "UserId": UserId,
          // "folderName": folderName
        }));

    //log("req GetAllCommons = " + response.request.url.toString());
    print("*********************");

    log("res GetMailFolders = " + response.body);

    log("res GetMailFolders = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return FolderListModel.fromJson(responseData);
    }
  }

  @override
  Future GetMails(Map<String, String> header,
      {String? UserEmail,
      String? folderName,
      int? pageNumber,
      int? pageSize}) async {
    print('foldername' + folderName!);
    var response = await http.post(Uri.parse(_serviceUrl.getMails),
        headers: header,
        body: jsonEncode({
          "pageNumber": pageNumber,
          "pageSize": pageSize,
          "folderName": folderName,
          "userEmail": UserEmail
        }));

    //log("req GetAllCommons = " + response.request.url.toString());
    print("*********************");

    log("foldernameres GetMailFolderssssssss = " +
        response.body +
        UserEmail! +
        jsonEncode({
          "pageNumber": pageNumber,
          "pageSize": pageSize,
          "folderName": folderName,
          "userEmail": UserEmail
        }));

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print('getMailsss::::' + responseData.toString());
      return EmailResponse.fromJson(responseData);
    }
  }

  @override
  Future GetMailDetail(
    Map<String, String> header, {
    String? UserEmail,
    String? folderName,
    int? id,
  }) async {
    print('foldername' + folderName!);
    var response = await http.post(Uri.parse(_serviceUrl.getMailDetail),
        headers: header,
        body: jsonEncode(
            {"id": id, "folderName": folderName, "UserEmail": UserEmail}));

    //log("req GetAllCommons = " + response.request.url.toString());
    print("*********************");

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // print('getMailDetail::::' +
      //     EmailDetailResponse.fromJson(responseData)
      //         .result
      //         .attachments
      //         .first
      //         .fileName
      //         .toString());
      return EmailDetailResponse.fromJson(responseData);
    }
  }
}
