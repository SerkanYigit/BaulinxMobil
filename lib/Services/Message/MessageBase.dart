import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/Message/GetMessageByUserIdResult.dart';

abstract class MessageBase {
  Future<GetMessageByUserIdResult> GetMessageByUserIdSent(
      Map<String, String> header,
      {int UserId,
      int Page,
      int Size,
      int Type});
  Future<GetMessageByUserIdResult> GetMessageByUserIdReceived(
      Map<String, String> header,
      {int UserId,
      int Page,
      int Size,
      int Type});
  Future<GetMessageByUserIdResult> GetMessageByUserIdAll(
      Map<String, String> header,
      {int UserId,
      int Page,
      int Size,
      int Type});
  Future<GetMessageByUserIdResult> GetMessageByUserIdDeleted(
      Map<String, String> header,
      {int UserId,
      int Page,
      int Size,
      int Type});
  Future SendMessage(
    Map<String, String> header, {
    int UserId,
    String MessageSubject,
    String MessageText,
    int MainMessageId,
    List<int> RecipientUserList,
    Files FileInputList,
  });
  Future SendMessageNew(
    Map<String, String> header, {
    int userId,
    String from, // Required field for the sender email
    int selectedCustomerId = -1, // Default to -1 if not provided
    int selectedCustomerAdminId = -1, // Default to -1 if not provided
    List<String>
        recipientUserList, // This is required based on the body you provided
    List<String> cc = const [], // Optional, default to empty string
    List<String> bcc = const [], // Optional, default to empty string
    String subject, // Required field for the email subject
    String message, // Required field for the message body
    List<String> recipientUserLists, // Optional, can mirror recipientUserList
    Map<String, dynamic> options =
        const {}, // Optional, default to empty object
  });
  Future DeleteMessage(Map<String, String> header, {int UserId, int MessageId});
  Future SetMessageRead(Map<String, String> header,
      {int UserId, int MessageId});
  Future GetMessageDetail(Map<String, String> header,
      {int UserId, int MessageId});
  Future GetMessageCategory(Map<String, String> header,
      {int UserId, String LanguageId});
  Future GetUserEmails(Map<String, String> header, {int UserId});
  Future GetMailFolders(Map<String, String> header,
      {String UserEmail, int UserId, String folderName});
  Future GetMails(Map<String, String> header,
      {String UserEmail, String folderName, int pageNumber, int pageSize});
  Future GetMailDetail(Map<String, String> header,
      {String UserEmail, String folderName, int id});
}
