import 'dart:async';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Services/Common/CommonBase.dart';
import 'package:undede/Services/Common/CommonDB.dart';
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

class ControllerCommon extends GetxController implements CommonBase {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  CommonDB _commonService = CommonDB();
  Rx<GetAllCommonsResult?> getAllCommons = null.obs;
  Rx<GetDefinedRoleListResult?> getDefinedRole = null.obs;
  bool commonRefreshCurrentPage = false;
  bool commonReload = false;
  bool commobReloadforNotification = false;
  int commonNotificationId = 0;
  int todoNotificationId = 0;
  List<PublicBoardListItem>? publicBoardList;
  PublicBoardListItem selectedBoardItem = new PublicBoardListItem();
  List<CommonPermission> MyPermissionsOnBoards = [];

  @override
  Future<ListOfCommonGroup> GetListCommonGroup(Map<String, String> header,
      {int? userId}) async {
    return await _commonService.GetListCommonGroup(
      header,
      userId: userId!,
    );
  }

  @override
  Future<ListOfCommonGroup> GetGroupById(Map<String, String> header,
      {int? userId, int? id}) async {
    return await _commonService.GetGroupById(header, userId: userId!, id: id!);
  }

  @override
  Future<GetAllCommonsResult> GetAllCommons(Map<String, String> header,
      {int? userId,
      int? page,
      int? take,
      String? commonTypeName,
      String? search,
      int? groupId,
      int? ownerId,
      List<int>? UserIds,
      int? TypeWho,
      int? WhichSection,
      List<int>? LabelList,
      String? StartDate,
      String? EndDate,
      int? ReminderInclude,
      int? IncludeElement}) async {
    var value = await _commonService.GetAllCommons(
      header,
      userId: userId!,
      page: page,
      take: take,
      commonTypeName: commonTypeName,
      search: search,
      groupId: groupId,
      ownerId: ownerId,
      UserIds: UserIds,
      TypeWho: TypeWho,
      WhichSection: WhichSection,
      LabelList: LabelList,
      StartDate: StartDate,
      EndDate: EndDate,
      ReminderInclude: ReminderInclude,
      IncludeElement: IncludeElement,
    );

    update();
    getAllCommons = value.obs;
    update();

    return value;
  }

  @override
  Future<GetPublicMeetingsResult> GetPublicMeetings(Map<String, String> header,
      {int? userId,
      int? page,
      int? take,
      String? search,
      int? categoryId,
      bool? IsLike,
      bool? IsOnline}) async {
    GetPublicMeetingsResult data = await _commonService.GetPublicMeetings(
      header,
      userId: _controllerDB.user.value!.result!.id,
      page: page,
      take: take,
      search: search,
      categoryId: categoryId,
      IsLike: IsLike,
      IsOnline: IsOnline,
    );
    publicBoardList = data.result!.publicBoardList;
    return data;
  }

  @override
  Future<GetInviteUserListResult> GetInviteUserList(
      Map<String, String> header) async {
    return await _commonService.GetInviteUserList(header);
  }

  @override
  Future CareateOrJoinMetting(Map<String, String> header,
      {int? OwnerId,
      int? UserId,
      List<int>? TargetUserIdList,
      int? ModuleType}) async {
    return await _commonService.CareateOrJoinMetting(
      header,
      OwnerId: OwnerId!,
      UserId: UserId!,
      TargetUserIdList: TargetUserIdList!,
      ModuleType: ModuleType!,
    );
  }

  @override
  Future InsertCommon(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      bool? State,
      String? Title,
      String? Description,
      int? CommonGroupId}) async {
    return await _commonService.InsertCommon(
      header,
      UserId: UserId!,
      CustomerId: CustomerId!,
      State: State!,
      Title: Title!,
      Description: Description!,
      CommonGroupId: CommonGroupId!,
    );
  }

  @override
  Future InsertCommonGroup(
    Map<String, String> header, {
    int? UserId,
    String? GroupName,
    String? ProjectNumber,
    String? StreetText,
    String? PostalCode,
    String? CityText,
    String? StateText,
    String? GroupStartDate,
    String? GroupEndDate,
    int? selectedCustomerId,
    int? SelectedUser,
  }) async {
    return await _commonService.InsertCommonGroup(header,
        UserId: UserId!,
        GroupName: GroupName!,
        ProjectNumber: ProjectNumber!,
        StreetText: StreetText!,
        PostalCode: PostalCode!,
        CityText: CityText!,
        StateText: StateText!,
        GroupStartDate: GroupStartDate!,
        GroupEndDate: GroupEndDate!,
        SelectedCustomerId: selectedCustomerId!,
        SelectedUser: SelectedUser!);
  }

  @override
  Future UpdateCommonGroup(Map<String, String> header,
      {int? Id,
      String? CreateDate,
      int? UserId,
      String? GroupName,
      String? ProjectNumber,
      String? Street,
      String? PostalCode,
      String? City,
      String? State,
      String? StartDate,
      String? EndDate,
      int? CustomerId,
      int? PersonnelId}) async {
    return await _commonService.UpdateCommonGroup(header,
        Id: Id!,
        CreateDate: CreateDate!,
        UserId: UserId!,
        GroupName: GroupName!,
        ProjectNumber: ProjectNumber!,
        Street: Street!,
        PostalCode: PostalCode!,
        City: City!,
        State: State!,
        StartDate: StartDate!,
        EndDate: EndDate!,
        CustomerId: CustomerId!,
        PersonnelId: PersonnelId!);
  }

  @override
  Future<GetAllCommonsResult> GetCommons(
    Map<String, String> header, {
    int? userId,
    int? page,
    int? take,
    String? commonTypeName,
    String? search,
    int? groupId,
    int? ownerId,
    List<int>? UserIds,
    int? TypeWho,
    int? WhichSection,
    List<int>? LabelList,
    String? StartDate,
    String? EndDate,
    int? ReminderInclude,
    int? IncludeElement,
  }) async {
    return await _commonService.GetCommons(
      header,
      userId: userId,
      page: page,
      take: take,
      commonTypeName: commonTypeName,
      search: search,
      groupId: groupId,
      ownerId: ownerId,
      UserIds: UserIds,
      TypeWho: TypeWho,
      WhichSection: WhichSection,
      LabelList: LabelList,
      StartDate: StartDate,
      EndDate: EndDate,
      ReminderInclude: ReminderInclude,
      IncludeElement: IncludeElement,
    );
  }

  @override
  Future<bool> ConfirmInviteUsersCommonBoard(Map<String, String> header,
      {int? UserId,
      int? NotificationId,
      int? UserCommonOrderId,
      bool? IsAccept}) async {
    return await _commonService.ConfirmInviteUsersCommonBoard(header,
        UserId: _controllerDB.user.value!.result!.id,
        NotificationId: NotificationId!,
        UserCommonOrderId: UserCommonOrderId!,
        IsAccept: IsAccept!);
  }

  @override
  Future<GetDefinedRoleListResult> GetDefinedRoleList(
      Map<String, String> header) async {
    update();
    var value = await _commonService.GetDefinedRoleList(header);
    getDefinedRole = value.obs;
    update();
    return value;
  }

  @override
  Future InviteUsersCommonBoard(Map<String, String> header,
      {int? UserId,
      int? CommonId,
      int? RoleId,
      List<int>? TargetUserIdList}) async {
    return await _commonService.InviteUsersCommonBoard(
      header,
      UserId: _controllerDB.user.value!.result!.id,
      CommonId: CommonId!,
      RoleId: RoleId!,
      TargetUserIdList: TargetUserIdList!,
    );
  }

  @override
  Future<GetCommonUserListResult> GetCommonUserList(Map<String, String> header,
      {int? CommonId, int? UserId}) async {
    return await _commonService.GetCommonUserList(
      header,
      UserId: UserId!,
      CommonId: CommonId!,
    );
  }

  @override
  Future ChangeCommonGroup(
    Map<String, String> header, {
    int? CommonId,
    int? UserId,
    int? CommonGroupId,
  }) async {
    return await _commonService.ChangeCommonGroup(
      header,
      UserId: UserId!,
      CommonId: CommonId!,
      CommonGroupId: CommonGroupId!,
    );
  }

  @override
  Future CopyCommon(
    Map<String, String> header, {
    int? CommonId,
    int? UserId,
  }) async {
    return await _commonService.CopyCommon(header,
        UserId: UserId!, CommonId: CommonId!);
  }

  @override
  Future<GetCommonGroupBackgroundResult> GetCommonGroupBackground(
      Map<String, String> header,
      {int? CommonId,
      int? UserId}) async {
    return await _commonService.GetCommonGroupBackground(header,
        UserId: UserId!, CommonId: CommonId!);
  }

  @override
  Future CommonInvite(Map<String, String> header,
      {int? UserId,
      int? TargetUserId,
      List<int>? TargetUserIdList,
      String? CommentText,
      String? Email,
      String? Language}) async {
    return await _commonService.CommonInvite(header,
        UserId: UserId!,
        TargetUserId: TargetUserId!,
        TargetUserIdList: TargetUserIdList!,
        CommentText: CommentText!,
        Email: Email!,
        Language: Language!);
  }

  @override
  Future<bool> EndMeeting(Map<String, String> header,
      {int? UserId, String? MeetingId}) async {
    return await _commonService.EndMeeting(header,
        UserId: UserId!, MeetingId: MeetingId!);
  }

  @override
  Future DeleteCommon(Map<String, String> header,
      {int? UserId, int? CommonId}) async {
    return await _commonService.DeleteCommon(header,
        UserId: UserId!, CommonId: CommonId!);
  }

  @override
  Future DeleteCommonGroup(Map<String, String> header,
      {int? UserId, int? CommonId}) async {
    return await _commonService.DeleteCommonGroup(header,
        UserId: UserId!, CommonId: CommonId!);
  }

  @override
  Future<bool> Like(Map<String, String> header,
      {int? UserId, int? CommonId, bool? IsLike}) async {
    bool hasError = await _commonService.Like(header,
        UserId: UserId!, CommonId: CommonId!, IsLike: IsLike!);

    if (!hasError) {
      publicBoardList!.firstWhere((x) => x.id == CommonId).isLike =
          !publicBoardList!.firstWhere((x) => x.id == CommonId).isLike!;
    }

    return hasError;
  }

  @override
  Future<GetPermissionListResult> GetPermissionList(Map<String, String> header,
      {int? UserId, int? DefinedRoleId}) async {
    return await _commonService.GetPermissionList(header,
        UserId: _controllerDB.user.value!.result!.id,
        DefinedRoleId: DefinedRoleId!);
  }

  bool hasUserMovePerm(int commonId) {
    if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    }

    List<Permission>? permList;

    var foundPermission = MyPermissionsOnBoards.firstWhereOrNull(
      (e) => e.commonId == commonId,
    );

    // List<Permission>? permList = MyPermissionsOnBoards!.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null).permissionList;

    if (foundPermission != null) {
      permList = foundPermission.permissionList;
    } else {
      print("Eşleşen izin bulunamadı!");
      permList = [];
    }

    if (permList.length == 0) {
      if (getAllCommons.value!.result!.commonBoardList!
              .where((element) => element.id == commonId)
              .first
              .userId ==
          _controllerDB.user.value!.result!.id) {
        return true;
      } else {
        return false;
      }
    } else {
      return permList
              .where((perm) =>
                  perm.moduleCategoryId == 14 &&
                  perm.moduleSubCategoryId == 23 &&
                  perm.permissionTypeId == 9)
              .length >=
          1;
    }
  }

  bool hasUserInvitePerm(int commonId) {
    if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    }

    // List<Permission> permList = MyPermissionsOnBoards!.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null).permissionList;

    List<Permission>? permList;

    var foundPermission = MyPermissionsOnBoards.firstWhereOrNull(
      (e) => e.commonId == commonId,
    );

    // List<Permission>? permList = MyPermissionsOnBoards!.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null).permissionList;

    if (foundPermission != null) {
      permList = foundPermission.permissionList;
    } else {
      print("Eşleşen izin bulunamadı!");
      permList = [];
    }

    if (permList.length == 0) {
      if (getAllCommons.value!.result!.commonBoardList!
              .where((element) => element.id == commonId)
              .first
              .userId ==
          _controllerDB.user.value!.result!.id) {
        return true;
      } else {
        return false;
      }
    } else {
      return permList
              .where((perm) =>
                  perm.moduleCategoryId == 14 &&
                  perm.moduleSubCategoryId == 23 &&
                  perm.permissionTypeId == 16)
              .length >=
          1;
    }
  }

  bool hasDeleteCommonPerm(int commonId) {
    if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    }
    // List<Permission> permList = MyPermissionsOnBoards.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null).permissionList;
    List<Permission>? permList;

    var foundPermission = MyPermissionsOnBoards.firstWhereOrNull(
      (e) => e.commonId == commonId,
    );

    // List<Permission>? permList = MyPermissionsOnBoards!.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null).permissionList;

    if (foundPermission != null) {
      permList = foundPermission.permissionList;
    } else {
      print("Eşleşen izin bulunamadı!");
      permList = [];
    }

    if (permList.length == 0) if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    } else {
      return false;
    }
    else
      return permList
              .where((perm) =>
                  perm.moduleCategoryId == 14 &&
                  perm.moduleSubCategoryId == 23 &&
                  perm.permissionTypeId == 2)
              .length >=
          1;
  }

  bool hasCopyCommonPerm(int commonId) {
    if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    }
    // List<Permission> permList = MyPermissionsOnBoards.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null).permissionList;

    List<Permission>? permList;

    var foundPermission = MyPermissionsOnBoards.firstWhereOrNull(
      (e) => e.commonId == commonId,
    );

    if (foundPermission != null) {
      permList = foundPermission.permissionList;
    } else {
      print("Eşleşen izin bulunamadı!");
      permList = [];
    }

    if (permList.length == 0) if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    } else {
      return false;
    }
    else
      return permList
              .where((perm) =>
                  perm.moduleCategoryId == 14 &&
                  perm.moduleSubCategoryId == 23 &&
                  perm.permissionTypeId == 10)
              .length >=
          1;
  }

  bool hasInsertCommonPerm(int commonId) {
    return true;
    // print('commonId: $commonId');
    // List<Permission> permList = MyPermissionsOnBoards.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null)?.permissionList;
    // if (permList?.length == 0 || permList?.length == null) if (getAllCommons
    //         .value.result.commonBoardList
    //         .where((element) => element.id == commonId)
    //         .first
    //         .userId ==
    //     _controllerDB.user.value.result.id) {
    //   return true;
    // } else {
    //   return false;
    // }
    // else
    //   return permList
    //           ?.where((perm) =>
    //               perm.moduleCategoryId == 14 &&
    //               perm.moduleSubCategoryId == 23 &&
    //               perm.permissionTypeId == 1)
    //           .length >=
    //       1;
  }

  bool hasFileManagerCommonPerm(int commonId) {
    if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .toList()
            .length ==
        0) {
      return false;
    }
    if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    }
    // List<Permission> permList = MyPermissionsOnBoards.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null).permissionList;

    List<Permission>? permList;

    var foundPermission = MyPermissionsOnBoards.firstWhereOrNull(
      (e) => e.commonId == commonId,
    );

    // List<Permission>? permList = MyPermissionsOnBoards!.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null).permissionList;

    if (foundPermission != null) {
      permList = foundPermission.permissionList;
    } else {
      print("Eşleşen izin bulunamadı!");
      permList = [];
    }

    if (permList.length == 0) if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    } else {
      return false;
    }
    else
      return permList
              .where((perm) =>
                  perm.moduleCategoryId == 14 &&
                  perm.moduleSubCategoryId == 23 &&
                  perm.permissionTypeId == 7)
              .length >=
          1;
  }

  bool hasEditCommonPerm(int commonId) {
    if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    }
    // List<Permission> permList = MyPermissionsOnBoards.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null).permissionList;

    List<Permission>? permList;

    var foundPermission = MyPermissionsOnBoards.firstWhereOrNull(
      (e) => e.commonId == commonId,
    );

    if (foundPermission != null) {
      permList = foundPermission.permissionList;
    } else {
      print("Eşleşen izin bulunamadı!");
      permList = [];
    }

    if (permList.length == 0) if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    } else {
      return false;
    }
    else
      return permList
              .where((perm) =>
                  perm.moduleCategoryId == 14 &&
                  perm.moduleSubCategoryId == 23 &&
                  perm.permissionTypeId == 3)
              .length >=
          1;
  }

  bool hasMoveCommonPerm(int commonId) {
    if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    }

    // List<Permission> permList = MyPermissionsOnBoards.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null).permissionList;

    List<Permission>? permList;

    var foundPermission = MyPermissionsOnBoards.firstWhereOrNull(
      (e) => e.commonId == commonId,
    );

    if (foundPermission != null) {
      permList = foundPermission.permissionList;
    } else {
      print("Eşleşen izin bulunamadı!");
      permList = [];
    }

    if (permList.length == 0) if (getAllCommons.value!.result!.commonBoardList!
            .where((element) => element.id == commonId)
            .first
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    } else {
      return false;
    }
    else
      return permList
              .where((perm) =>
                  perm.moduleCategoryId == 14 &&
                  perm.moduleSubCategoryId == 23 &&
                  perm.permissionTypeId == 9)
              .length >=
          1;
  }

  @override
  Future<bool> UpdateCommon(Map<String, String> header,
      {int? Id,
      int? UserId,
      int? CustomerId,
      String? Title,
      String? Photo,
      bool? IsPublic,
      bool? DisableNotification}) async {
    return await _commonService.UpdateCommon(
      header,
      Id: Id!,
      UserId: UserId!,
      CustomerId: CustomerId!,
      Title: Title!,
      Photo: Photo!,
      IsPublic: IsPublic!,
      DisableNotification: DisableNotification!,
    );
  }

  @override
  Future<GetPermissionListByCategoryIdResult> GetPermissionListByCategoryId(
      Map<String, String> header,
      {int? ModuleCategoryId,
      String? Language}) async {
    return await _commonService.GetPermissionListByCategoryId(
      header,
      ModuleCategoryId: ModuleCategoryId!,
      Language: Language!,
    );
  }

  @override
  Future InsertOrUpdateDefinedRole(Map<String, String> header,
      {int? Id,
      String? Name,
      int? UserId,
      int? CustomerId,
      int? ModuleType,
      List<int>? PermissionIdList}) async {
    return await _commonService.InsertOrUpdateDefinedRole(
      header,
      Id: Id!,
      Name: Name!,
      UserId: UserId!,
      CustomerId: CustomerId!,
      ModuleType: ModuleType!,
      PermissionIdList: PermissionIdList!,
    );
  }

  @override
  Future<bool> DeleteDefinedRole(Map<String, String> header,
      {int? DefinedRoleId}) async {
    return await _commonService.DeleteDefinedRole(
      header,
      DefinedRoleId: DefinedRoleId!,
    );
  }

  @override
  Future<PublicCategoryResult> GetPublicCategory(Map<String, String> header,
      {String? Language}) async {
    return await _commonService.GetPublicCategory(header, Language: Language!);
  }

  @override
  Future<GetOnlineMeetingsResult> GetOnlineMeetings(Map<String, String> header,
      {int? UserId}) async {
    return await _commonService.GetOnlineMeetings(header, UserId: UserId!);
  }

  @override
  Future InviteUsersCommonBoardWithRole(Map<String, String> header,
      {int? UserId,
      int? CommonId,
      List<int>? DeletedUserIdList,
      List<UserListWithRole>? userListWithRoleId}) async {
    return await _commonService.InviteUsersCommonBoardWithRole(header,
        UserId: UserId!,
        CommonId: CommonId!,
        DeletedUserIdList: DeletedUserIdList!,
        userListWithRoleId: userListWithRoleId!);
  }
}
