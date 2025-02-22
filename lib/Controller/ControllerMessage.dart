import 'dart:async';
import 'package:get/get.dart';

import 'package:undede/Services/Message/MessageBase.dart';
import 'package:undede/Services/Message/MessageDB.dart';

import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/Message/GetMessageByUserIdResult.dart';

import '../model/Common/MessageCategoryResult.dart';

class ControllerMessage extends GetxController implements MessageBase {
  MessageDB _messageDB = MessageDB();
  Rx<GetMessageByUserIdResult?> getReceived = null.obs;
  Rx<GetMessageByUserIdResult?> getSent = null.obs;
  Rx<GetMessageByUserIdResult?> getAll = null.obs;
  Rx<GetMessageByUserIdResult?> getDelete = null.obs;

  @override
  Future<GetMessageByUserIdResult> GetMessageByUserIdReceived(
      Map<String, String> header,
      {int? UserId,
      int? Page,
      int? Size,
      int? Type}) async {
    var value = await _messageDB.GetMessageByUserIdReceived(header,
        UserId: UserId!, Page: Page!, Size: Size!, Type: Type!);
    update();
    getReceived = value.obs;
    update();

    return value;
  }

  @override
  Future<GetMessageByUserIdResult> GetMessageByUserIdSent(
      Map<String, String> header,
      {int? UserId,
      int? Page,
      int? Size,
      int? Type}) async {
    var value = await _messageDB.GetMessageByUserIdSent(header,
        UserId: UserId!, Page: Page!, Size: Size!, Type: Type!);
    update();
    getSent = value.obs;
    update();

    return value;
  }

  @override
  Future<GetMessageByUserIdResult> GetMessageByUserIdAll(
      Map<String, String> header,
      {int? UserId,
      int? Page,
      int? Size,
      int? Type}) async {
    var value = await _messageDB.GetMessageByUserIdAll(header,
        UserId: UserId!, Page: Page!, Size: Size!, Type: Type!);

    update();
    getAll = value.obs;
    print('get all' + value.result!.messageList!.toString());
    update();

    return value;
  }

  @override
  Future<GetMessageByUserIdResult> GetMessageByUserIdDeleted(
      Map<String, String> header,
      {int? UserId,
      int? Page,
      int? Size,
      int? Type}) async {
    var value = await _messageDB.GetMessageByUserIdDeleted(header,
        UserId: UserId!, Page: Page!, Size: Size!, Type: Type!);
    update();
    getDelete = value.obs;
    update();

    return value;
  }

  @override
  Future DeleteMessage(Map<String, String> header,
      {int? UserId, int? MessageId}) async {
    return await _messageDB.DeleteMessage(header,
        UserId: UserId!, MessageId: MessageId!);
  }

  @override
  Future GetMessageDetail(Map<String, String> header,
      {int? UserId, int? MessageId}) async {
    return await _messageDB.GetMessageDetail(header,
        UserId: UserId!, MessageId: MessageId!);
  }

  @override
  Future<MessageCategory> GetMessageCategory(Map<String, String> header,
      {int? UserId, String? LanguageId}) async {
    return await _messageDB.GetMessageCategory(header,
        UserId: UserId!, LanguageId: LanguageId!);
  }

  @override
  Future SendMessage(Map<String, String> header,
      {int? UserId,
      String? MessageSubject,
      String? MessageText,
      int? MainMessageId,
      List<int>? RecipientUserList,
      bool? IsCombine,
      Files? FileInputList,
      int? CommonGroupId,
      int? MessageCategoryId}) async {
    // TODO: implement SendMessage
    return await _messageDB.SendMessage(header,
        UserId: UserId!,
        MessageSubject: MessageSubject!,
        MessageText: MessageText!,
        MainMessageId: MainMessageId!,
        RecipientUserList: RecipientUserList!,
        IsCombine: IsCombine!,
        FileInputList: FileInputList!,
        CommonGroupId: CommonGroupId!,
        MessageCategoryId: MessageCategoryId!,);
  }

  @override
  Future SendMessageNew(Map<String, String> header,
      {String? from,
      int? selectedCustomerId,
      int? selectedCustomerAdminId,
      List<String>? recipientUserList,
      List<String>? cc,
      List<String>? bcc,
      String? subject,
      String? message,
      int? userId,
      List<String>? recipientUserLists,
      Map<String, dynamic>? options}) async {
    return await _messageDB.SendMessageNew(header,
        userId: userId!,
        from: from!,
        selectedCustomerId: selectedCustomerId!,
        selectedCustomerAdminId: selectedCustomerAdminId!,
        recipientUserList: recipientUserList!,
        cc: cc!,
        bcc: bcc!,
        subject: subject!,
        message: message!,
        recipientUserLists: recipientUserLists!,
        options: options!);
  }

  @override
  Future SetMessageRead(Map<String, String> header,
      {int? UserId, int? MessageId}) async {
    return await _messageDB.SetMessageRead(header,
        UserId: UserId!, MessageId: MessageId!);
  }

  @override
  Future GetUserEmails(Map<String, String> header, {int? UserId}) async {
    var value = await _messageDB.GetUserEmails(header, UserId: UserId!);
    return value;
  }

  @override
  Future GetMailFolders(Map<String, String> header,
      {String? UserEmail, int? UserId, String? folderName}) async {
    var value = await _messageDB.GetMailFolders(header,
        UserEmail: UserEmail!, UserId: UserId!, folderName: folderName!);
    return value;
  }

  @override
  Future GetMails(Map<String, String> header,
      {String? UserEmail,
      String? folderName,
      int? pageNumber,
      int? pageSize}) async {
    var value = await _messageDB.GetMails(header,
        UserEmail: UserEmail!,
        pageSize: pageSize!,
        pageNumber: pageNumber!,
        folderName: folderName!,);
    return value;
  }

  @override
  Future GetMailDetail(
    Map<String, String> header, {
    String? UserEmail,
    String? folderName,
    int? id,
  }) async {
    var value = await _messageDB.GetMailDetail(header,
        UserEmail: UserEmail!, id: id!, folderName: folderName!,);
    return value;
  }
}
