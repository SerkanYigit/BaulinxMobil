import 'package:undede/model/Chat/ChatFileInsert.dart';
import 'package:undede/model/Chat/ChatMessageSaveResult.dart';
import 'package:undede/model/Chat/GetChatResult.dart';
import 'package:undede/model/Chat/GetGroupChatUserListResult.dart';
import 'package:undede/model/Chat/GetPublicChatListResult.dart';
import 'package:undede/model/Chat/GetUnreadCountByUserIdResult.dart';
import 'package:undede/model/Chat/GetUserListUser.dart';

abstract class ChatBase {
  Future<ChatMessageSaveResult> ChatMessageSave(Map<String, String> header,
      {int Id,
      int ReceiverId,
      int SenderId,
      int Type,
      int GroupId,
      int PublicId,
      String Message,
      String MessageBase64,
      ChatFileInsert Files,
      int RelatedMessageId});
  Future<GetChatResult> GetChat(Map<String, String> header, int id,
      int isPublic, int isGroup, int lastLoadedMessageId);
  Future<GetUserListResult> GetUserList(Map<String, String> header, int userId);
  Future<GetPublicChatListResult> GetPublicChatList(Map<String, String> header);
  Future<GetGroupChatUserListResult> GetGroupChatUserList(
      Map<String, String> header, int GroupId);
  Future UpdateChatGroupTitle(Map<String, String> header,
      {int GroupId, String Title});
  Future UpdateGroupChatPicture(Map<String, String> header,
      {int GroupId, String FileName, String Base64});
  Future removeUserFromGroupChat(Map<String, String> header,
      {int GroupId, int UserId});
  Future InsertChatGroupUser(Map<String, String> header,
      {int GroupId, List<int> UserIds});
  Future NewGroupChat(Map<String, String> header,
      {List<int> UserIdList, String Title});
  Future NewPublicChat(Map<String, String> header, {String Title});
  SetChatUnread(int senderUserId);
  Future<GetUnreadCountByUserIdResult> GetUnreadCountByUserId(
    Map<String, String> header,
  );
  Future<bool> ForwardMessages(Map<String, String> header,
      {int UserId,
      List<int> MessageList,
      List<int> ForwardUserList,
      List<int> ForwardGroupChat});
}
