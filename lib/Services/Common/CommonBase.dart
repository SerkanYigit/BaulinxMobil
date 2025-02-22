import 'package:undede/model/Common/CommonGroup.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:undede/model/Common/GetCommonGroupBackgroundResult.dart';
import 'package:undede/model/Common/GetCommonUserListResult.dart';
import 'package:undede/model/Common/GetDefinedRoleListResult.dart';
import 'package:undede/model/Common/GetInviteUserListResult.dart';
import 'package:undede/model/Common/GetOnlineMeetingsResult.dart';
import 'package:undede/model/Common/GetPermissionListByCategoryIdResult.dart';
import 'package:undede/model/Common/GetPermissionListResult.dart';
import 'package:undede/model/Common/GetPublicMeetingsResult.dart';
import 'package:undede/model/Common/PublicCategoryResult.dart';
import 'package:undede/model/Common/UserListWithRole.dart';

abstract class CommonBase {
  Future<ListOfCommonGroup> GetListCommonGroup(Map<String, String> header,
      {int userId});

  Future<ListOfCommonGroup> GetGroupById(Map<String, String> header,
      {int userId, int id});

  Future<GetAllCommonsResult> GetCommons(Map<String, String> header,
      {int userId,
      int page,
      int take,
      String commonTypeName,
      String search,
      int groupId,
      int ownerId,
      List<int> UserIds,
      int TypeWho,
      int WhichSection,
      List<int> LabelList,
      String StartDate,
      String EndDate,
      int ReminderInclude,
      int IncludeElement});

  Future<GetPublicMeetingsResult> GetPublicMeetings(Map<String, String> header,
      {int userId,
      int page,
      int take,
      String search,
      int categoryId,
      bool IsLike,
      bool IsOnline});
  Future<GetInviteUserListResult> GetInviteUserList(
    Map<String, String> header,
  );
  Future InsertCommon(Map<String, String> header,
      {int UserId,
      int CustomerId,
      bool State,
      String Title,
      String Description,
      int CommonGroupId});
  Future InsertCommonGroup(Map<String, String> header,
      {int UserId, String GroupName});
  Future CareateOrJoinMetting(Map<String, String> header,
      {int OwnerId, int UserId, List<int> TargetUserIdList, int ModuleType});
  Future<bool> EndMeeting(
    Map<String, String> header, {
    int UserId,
    String MeetingId,
  });

  Future<GetAllCommonsResult> GetAllCommons(Map<String, String> header,
      {int userId,
      int page,
      int take,
      String commonTypeName,
      String search,
      int groupId,
      int ownerId,
      List<int> UserIds,
      int TypeWho,
      int WhichSection,
      List<int> LabelList,
      String StartDate,
      String EndDate,
      int ReminderInclude,
      int IncludeElement});

  Future<GetDefinedRoleListResult> GetDefinedRoleList(
      Map<String, String> header);

  Future InviteUsersCommonBoard(Map<String, String> header,
      {int UserId, int CommonId, int RoleId, List<int> TargetUserIdList});

  Future ConfirmInviteUsersCommonBoard(Map<String, String> header,
      {int UserId, int NotificationId, int UserCommonOrderId, bool IsAccept});

  Future<GetCommonUserListResult> GetCommonUserList(Map<String, String> header,
      {int CommonId, int UserId});
  Future CopyCommon(Map<String, String> header, {int CommonId, int UserId});
  Future ChangeCommonGroup(Map<String, String> header,
      {int CommonId, int UserId, int CommonGroupId});
  Future<GetCommonGroupBackgroundResult> GetCommonGroupBackground(
    Map<String, String> header, {
    int CommonId,
    int UserId,
  });
  Future CommonInvite(Map<String, String> header,
      {int UserId,
      int TargetUserId,
      List<int> TargetUserIdList,
      String CommentText,
      String Email,
      String Language});
  Future DeleteCommon(Map<String, String> header, {int UserId, int CommonId});

  Future<bool> Like(Map<String, String> header,
      {int UserId, int CommonId, bool IsLike});

  Future<GetPermissionListResult> GetPermissionList(Map<String, String> header,
      {int UserId, int DefinedRoleId});
  Future<bool> UpdateCommon(Map<String, String> header,
      {int Id,
      int UserId,
      int CustomerId,
      String Title,
      String Photo,
      bool IsPublic,
      bool DisableNotification});
  Future<GetPermissionListByCategoryIdResult> GetPermissionListByCategoryId(
      Map<String, String> header,
      {int ModuleCategoryId,
      String Language});
  Future InsertOrUpdateDefinedRole(Map<String, String> header,
      {int Id,
      String Name,
      int UserId,
      int CustomerId,
      int ModuleType,
      List<int> PermissionIdList});
  Future<bool> DeleteDefinedRole(Map<String, String> header,
      {int DefinedRoleId});
  Future<PublicCategoryResult> GetPublicCategory(Map<String, String> header,
      {String Language});
  Future<GetOnlineMeetingsResult> GetOnlineMeetings(Map<String, String> header,
      {int UserId});
  Future InviteUsersCommonBoardWithRole(Map<String, String> header,
      {int UserId,
      int CommonId,
      List<int> DeletedUserIdList,
      List<UserListWithRole> userListWithRoleId});
}
