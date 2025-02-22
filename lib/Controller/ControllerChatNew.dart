import 'dart:async';
import 'package:get/get.dart';
import 'package:undede/Services/Chat/ChatBase.dart';
import 'package:undede/Services/Chat/ChatDB.dart';
import 'package:undede/model/Chat/ChatFileInsert.dart';
import 'package:undede/model/Chat/ChatMessageSaveResult.dart';
import 'package:undede/model/Chat/GetChatResult.dart';
import 'package:undede/model/Chat/GetGroupChatUserListResult.dart';
import 'package:undede/model/Chat/GetPublicChatListResult.dart';
import 'package:undede/model/Chat/GetUnreadCountByUserIdResult.dart';
import 'package:undede/model/Chat/GetUserListUser.dart';
import 'package:undede/model/Chat/GetChatResult.dart' as u;

class ControllerChatNew extends GetxController implements ChatBase {
  ChatDB _chatDB = ChatDB();
  Rx<u.Result?> messages = null.obs;
  Rx<UserList?> userList = null.obs;
  Rx<GetUserListResult?>? UserListRx; //! = null.obs;
  int TotalCount = 0;
  bool loadChatUsers = false;
  bool refreshDetail = false;
  @override
  Future<ChatMessageSaveResult> ChatMessageSave(
    Map<String, String> header, {
    int? Id,
    int? ReceiverId,
    int? SenderId,
    int? Type,
    int? GroupId,
    int? PublicId,
    String? Message,
    String? MessageBase64,
    ChatFileInsert? Files,
    int? RelatedMessageId,
  }) async {
    return await _chatDB.ChatMessageSave(
      header,
      Id: Id!,
      ReceiverId: ReceiverId!,
      SenderId: SenderId!,
      Type: Type!,
      GroupId: GroupId!,
      PublicId: PublicId!,
      Message: Message!,
      MessageBase64: MessageBase64!,
      Files: Files!,
      RelatedMessageId: RelatedMessageId!,
    );
  }

  @override
  Future<GetChatResult> GetChat(Map<String, String> header, int id,
      int isPublic, int isGroup, int lastLoadedMessageId) async {
    GetChatResult _chat = await _chatDB.GetChat(
        header, id, isPublic, isGroup, lastLoadedMessageId);
    update();
    messages = _chat.result.obs;
    update();
    return await _chatDB.GetChat(
        header, id, isPublic, isGroup, lastLoadedMessageId);
  }

  @override
  Future<GetUserListResult> GetUserList(
      Map<String, String> header, int UserId) async {
    var value = await _chatDB.GetUserList(header, UserId);
    update();
    UserListRx = value.obs;
    update();
    return value;
  }

  @override
  Future<GetPublicChatListResult> GetPublicChatList(
      Map<String, String> header) async {
    return await _chatDB.GetPublicChatList(header);
  }

  @override
  Future<GetGroupChatUserListResult> GetGroupChatUserList(
      Map<String, String> header, int GroupId) async {
    return await _chatDB.GetGroupChatUserList(header, GroupId);
  }

  @override
  Future InsertChatGroupUser(Map<String, String> header,
      {int? GroupId, List<int>? UserIds}) async {
    return await _chatDB.InsertChatGroupUser(header,
        GroupId: GroupId!, UserIds: UserIds!);
  }

  @override
  Future NewGroupChat(Map<String, String> header,
      {List<int>? UserIdList, String? Title}) async {
    return await _chatDB.NewGroupChat(header,
        UserIdList: UserIdList!, Title: Title!);
  }

  @override
  Future NewPublicChat(Map<String, String> header, {String? Title}) async {
    return await _chatDB.NewPublicChat(header, Title: Title!);
  }

  @override
  Future UpdateChatGroupTitle(Map<String, String> header,
      {int? GroupId, String? Title}) async {
    return await _chatDB.UpdateChatGroupTitle(header,
        GroupId: GroupId!, Title: Title!);
  }

  @override
  Future UpdateGroupChatPicture(Map<String, String> header,
      {int? GroupId, String? FileName, String? Base64}) async {
    return await _chatDB.UpdateGroupChatPicture(header,
        GroupId: GroupId!, FileName: FileName!, Base64: Base64!);
  }

  @override
  Future removeUserFromGroupChat(Map<String, String> header,
      {int? GroupId, int? UserId}) async {
    return await _chatDB.removeUserFromGroupChat(header,
        GroupId: GroupId!, UserId: UserId!);
  }

  @override
  SetChatUnread(int senderUserId) async {
    update();
    update();
    return await _chatDB.SetChatUnread(senderUserId);
  }

  @override
  Future<GetUnreadCountByUserIdResult> GetUnreadCountByUserId(
      Map<String, String> header) async {
    GetUnreadCountByUserIdResult value =
        await _chatDB.GetUnreadCountByUserId(header);
    TotalCount = value.result!.unreadMessageCount ?? 0;
    update();

    return await value;
  }

  @override
  Future<bool> ForwardMessages(Map<String, String> header,
      {int? UserId,
      List<int>? MessageList,
      List<int>? ForwardUserList,
      List<int>? ForwardGroupChat}) async {
    return await _chatDB.ForwardMessages(header,
        UserId: UserId!,
        MessageList: MessageList!,
        ForwardUserList: ForwardUserList!,
        ForwardGroupChat: ForwardGroupChat!);
  }
}
