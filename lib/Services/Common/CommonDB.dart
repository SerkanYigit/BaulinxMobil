import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:undede/Services/Common/CommonBase.dart';
import 'package:undede/model/Common/CareateOrJoinMettingResult.dart';
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
import '../ServiceUrl.dart';

class CommonDB implements CommonBase {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<ListOfCommonGroup> GetListCommonGroup(Map<String, String> header,
      {int? userId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getListCommonGroup),
        headers: header, body: jsonEncode({"UserId": userId}));

    if (response.body.isEmpty) {
      return ListOfCommonGroup(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print('get list commons' + responseData.toString());

      return ListOfCommonGroup.fromJson(responseData);
    }
  }

  @override
  Future<ListOfCommonGroup> GetGroupById(Map<String, String> header,
      {int? userId, int? id}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getGroupById),
        headers: header, body: jsonEncode({"UserId": userId, "Id": id}));

    if (response.body.isEmpty) {
      return ListOfCommonGroup(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return ListOfCommonGroup.fromJson(responseData);
    }
  }

  @override
  Future<GetAllCommonsResult> GetCommons(Map<String, String> header,
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
    var reqBody = jsonEncode({
      "UserId": userId,
      "Page": page,
      "Take": take,
      "CommonTypeName": commonTypeName,
      "Search": search,
      "GroupId": groupId,
      "OwnerId": ownerId,
      "UserIds": UserIds,
      "TypeWho": TypeWho,
      "WhichSection": WhichSection,
      "LabelList": LabelList,
      "StartDate": StartDate,
      "EndDate": EndDate,
      "ReminderInclude": ReminderInclude,
      "IncludeElement": IncludeElement,
    });
    var response = await http.post(Uri.parse(_serviceUrl.getCommons),
        headers: header, body: reqBody);

    log("req GetCommons = " + reqBody.toString());
    log("res GetCommons = " + response.body);

    if (response.body.isEmpty) {
      return GetAllCommonsResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetAllCommonsResult.fromJson(responseData);
    }
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
    var responseBody = jsonEncode({
      "UserId": userId,
      "Page": page,
      "Take": take,
      "Search": search,
      "CategoryId": categoryId,
      "IsLike": IsLike,
      "IsOnline": IsOnline
    });

    var response = await http.post(Uri.parse(_serviceUrl.getPublicMeetings),
        headers: header, body: responseBody);

    log(responseBody.toString());
    log("GetPublicMeetings = " + response.body);

    if (response.body.isEmpty) {
      return GetPublicMeetingsResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetPublicMeetingsResult.fromJson(responseData);
    }
  }

  @override
  Future<GetInviteUserListResult> GetInviteUserList(
      Map<String, String> header) async {
    var response = await http.post(
      Uri.parse(_serviceUrl.getInviteUserList),
      headers: header,
    );

    log("res GetInviteUserListResult = " + response.body);

    if (response.body.isEmpty) {
      return GetInviteUserListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetInviteUserListResult.fromJson(responseData);
    }
  }

  @override
  Future<CareateOrJoinMettingResult> CareateOrJoinMetting(
      Map<String, String> header,
      {int? OwnerId,
      int? UserId,
      List<int>? TargetUserIdList,
      int? ModuleType}) async {
    var body = jsonEncode({
      "OwnerId": OwnerId,
      "UserId": UserId,
      "TargetUserIdList": TargetUserIdList,
      "ModuleType": ModuleType
    });
    var response = await http.post(Uri.parse(_serviceUrl.careateOrJoinMetting),
        headers: header, body: body);
    log("req CareateOrJoinMetting = " + body.toString());
    log("res CareateOrJoinMetting = " + response.body);

    if (response.body.isEmpty) {
      return CareateOrJoinMettingResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return CareateOrJoinMettingResult.fromJson(responseData);
    }
  }

  @override
  Future<bool> EndMeeting(Map<String, String> header,
      {int? UserId, String? MeetingId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.endMeeting),
        headers: header,
        body: jsonEncode({
          "UserId": UserId,
          "MeetingId": MeetingId,
        }));

    log("res GetInviteUserListResult = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  @override
  Future InsertCommon(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      bool? State,
      String? Title,
      String? Description,
      int? CommonGroupId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.insertCommon),
        headers: header,
        body: jsonEncode({
          "UserId": UserId,
          "CustomerId": CustomerId,
          "State": State,
          "Title": Title,
          "Description": Description,
          "CommonGroupId": CommonGroupId
        }));

    log("res InsertCommon = " + response.body);
    log("res InsertCommon = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

// Assuming convertToIso8601 is a function that converts a date string to ISO 8601 format
  String convertToIso8601(String dateStr) {
    DateFormat inputFormat =
        DateFormat('yyyy-MM-dd'); // Adjust according to your input format
    DateTime date = inputFormat.parse(dateStr);
    date = DateTime(date.year, date.month, date.day, 10); // Set the hour to 10
    return date.toIso8601String();
  }

// Assuming getCurrentDateTimeIso is a function that returns the current date and time in ISO 8601 format
  String getCurrentDateTimeIso() {
    DateTime now = DateTime.now();
    return now.toIso8601String();
  }

  @override
  Future<bool> InsertCommonGroup(Map<String, String> header,
      {int? UserId,
      String? GroupName,
      String? ProjectNumber,
      String? StreetText,
      String? PostalCode,
      String? CityText,
      String? StateText,
      String? GroupStartDate,
      String? GroupEndDate,
      int? SelectedCustomerId,
      int? SelectedUser}) async {
    String startDate = convertToIso8601(GroupStartDate ?? "");
    String endDate = convertToIso8601(GroupEndDate ?? "");
    String currentDateTimeIso = getCurrentDateTimeIso();
    print(
        'res GetInviteUserListResult UserId::::  ${currentDateTimeIso} :::::  ${UserId.toString()} GroupName ${GroupName.toString()} ProjectNumber ${ProjectNumber.toString()} StreetText ${StreetText.toString()} PostalCode ${PostalCode.toString()} CityText ${CityText.toString()} StateText ${StateText.toString()} GroupStartDate ${startDate.toString()} GroupEndDate ${endDate.toString()} SelectedCustomerId ${SelectedCustomerId.toString()} SelectedUser ${SelectedUser.toString()}');

    var response = await http.post(Uri.parse(_serviceUrl.insertCommonGroup),
        headers: header,
        body: jsonEncode({
          "CreateDate": currentDateTimeIso,
          "UserId": UserId,
          "GroupName": GroupName,
          "ProjectNumber": ProjectNumber,
          "Street": StreetText,
          "PostalCode": PostalCode,
          "City": CityText,
          "State": StateText,
          "StartDate": startDate,
          "EndDate": endDate,
          "CustomerId": SelectedCustomerId,
          "PersonnelId": SelectedUser
        }));

    log("res GetInviteUserListResult = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
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
    var reqBody = jsonEncode({
      "UserId": userId,
      "Page": page,
      "Take": 9999,
      "CommonTypeName": commonTypeName,
      "Search": search,
      "GroupId": groupId,
      "OwnerId": ownerId,
      "UserIds": UserIds,
      "TypeWho": TypeWho,
      "WhichSection": WhichSection,
      "LabelList": LabelList,
      "StartDate": StartDate,
      "EndDate": EndDate,
      "ReminderInclude": ReminderInclude,
      "IncludeElement": IncludeElement,
    });

    var response = await http.post(Uri.parse(_serviceUrl.getAllCommons),
        headers: header, body: reqBody);
    print(reqBody);
    log("req GetAllCommons = " + reqBody.toString());
    log("res GetAllCommons = " + response.body);

    if (response.body.isEmpty) {
      return GetAllCommonsResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetAllCommonsResult.fromJson(responseData);
    }
  }

  @override
  Future ConfirmInviteUsersCommonBoard(Map<String, String> header,
      {int? UserId,
      int? NotificationId,
      int? UserCommonOrderId,
      bool? IsAccept}) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
      "NotificationId": NotificationId,
      "UserCommonOrderId": UserCommonOrderId,
      "IsAccept": IsAccept,
    });

    var response = await http.post(
        Uri.parse(_serviceUrl.confirmInviteUsersCommonBoard),
        headers: header,
        body: reqBody);

    log("req ConfirmInviteUsersCommonBoard = " + reqBody.toString());
    log("res ConfirmInviteUsersCommonBoard = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<GetDefinedRoleListResult> GetDefinedRoleList(
      Map<String, String> header) async {
    var response = await http.post(Uri.parse(_serviceUrl.getDefinedRoleList),
        headers: header);
    log("req GetDefinedRoleListResult = " + response.request!.url.toString());
    log("res GetDefinedRoleListResult = " + response.body);

    if (response.body.isEmpty) {
      return GetDefinedRoleListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetDefinedRoleListResult.fromJson(responseData);
    }
  }

  @override
  Future InviteUsersCommonBoard(Map<String, String> header,
      {int? UserId,
      int? CommonId,
      int? RoleId,
      List<int>? TargetUserIdList}) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
      "CommonId": CommonId,
      "RoleId": RoleId,
      "TargetUserIdList": TargetUserIdList,
    });

    var response = await http.post(
        Uri.parse(_serviceUrl.inviteUsersCommonBoard),
        headers: header,
        body: reqBody);

    log("req InviteUsersCommonBoard = " + reqBody.toString());
    log("res InviteUsersCommonBoard = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future<GetCommonUserListResult> GetCommonUserList(Map<String, String> header,
      {int? CommonId, int? UserId, bool PrintLog = false}) async {
    var reqBody = jsonEncode({
      "CommonId": CommonId,
      "UserId": UserId,
    });

    var response = await http.post(Uri.parse(_serviceUrl.getCommonUserList),
        headers: header, body: reqBody);

    if (PrintLog) {
      log("req GetCommonUserList: " + reqBody);
      log("res GetCommonUserList: " + response.body);
    }

    if (response.body.isEmpty) {
      return GetCommonUserListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetCommonUserListResult.fromJson(responseData);
    }
  }

  @override
  Future ChangeCommonGroup(Map<String, String> header,
      {int? CommonId, int? UserId, int? CommonGroupId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.changeCommonGroup),
        headers: header,
        body: jsonEncode({
          "CommonId": CommonId,
          "UserId": UserId,
          "CommonGroupId": CommonGroupId
        }));
    print("ChangeCommonGroup" + response.body);
    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future CopyCommon(Map<String, String> header,
      {int? CommonId, int? UserId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.copyCommon),
        headers: header,
        body: jsonEncode({
          "CommonId": CommonId,
          "UserId": UserId,
        }));
    print("CopyCommon" + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future<GetCommonGroupBackgroundResult> GetCommonGroupBackground(
      Map<String, String> header,
      {int? CommonId,
      int? UserId}) async {
    var response =
        await http.post(Uri.parse(_serviceUrl.getCommonGroupBackground),
            headers: header,
            body: jsonEncode({
              "CommonId": CommonId,
              "UserId": UserId,
            }));

    if (response.body.isEmpty) {
      return GetCommonGroupBackgroundResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetCommonGroupBackgroundResult.fromJson(responseData);
    }
  }

  @override
  Future CommonInvite(Map<String, String> header,
      {int? UserId,
      int? TargetUserId,
      List<int>? TargetUserIdList,
      String? CommentText,
      String? Email,
      String? Language}) async {
    var reqbody = jsonEncode({
      "UserId": UserId,
      "TargetUserId": TargetUserId,
      "TargetUserIdList": TargetUserIdList,
      "CommentText": CommentText,
      "Email": Email,
      "Language": Language,
    });
    var response = await http.post(Uri.parse(_serviceUrl.commonInvite),
        headers: header, body: reqbody);
    log("reqbody CommonInvite " + reqbody.toString());
    log("resbody CommonInvite" + response.body);
    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future DeleteCommon(Map<String, String> header,
      {int? UserId, int? CommonId}) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
      "CommonId": CommonId,
    });

    var response = await http.post(Uri.parse(_serviceUrl.deleteCommon),
        headers: header, body: reqBody);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future DeleteCommonGroup(Map<String, String> header,
      {int? UserId, int? CommonId}) async {
    var reqBody = jsonEncode({
      "id": CommonId,
    });
    String uri = _serviceUrl.deleteCommonGroup + '?id=' + CommonId.toString();
    var response = await http.get(Uri.parse(uri), headers: header);
    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return responseData["HasError"];
    }
  }

  @override
  Future<bool> Like(Map<String, String> header,
      {int? UserId, int? CommonId, bool? IsLike}) async {
    var response = await http.post(Uri.parse(_serviceUrl.likeCommon),
        headers: header,
        body: jsonEncode({
          "UserId": UserId,
          "CommonId": CommonId,
          "IsLike": IsLike,
        }));

    print("Like Common" + response.body);
    if (response.body.isEmpty) {
      return true;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData['HasError'];
    }
  }

  @override
  Future<GetPermissionListResult> GetPermissionList(Map<String, String> header,
      {int? UserId, int? DefinedRoleId}) async {
    var reqBody =
        jsonEncode({"UserId": UserId, "DefinedRoleId": DefinedRoleId});
    var response = await http.post(Uri.parse(_serviceUrl.getPermissionList),
        headers: header, body: reqBody);

    print("Req GetPermissionList: " + reqBody);
    print("Res GetPermissionList: " + response.body);

    if (response.body.isEmpty) {
      return GetPermissionListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetPermissionListResult.fromJson(responseData);
    }
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
    var reqBody = jsonEncode({
      "Id": Id,
      "UserId": UserId,
      "CustomerId": CustomerId,
      "Title": Title,
      "Photo": Photo,
      "IsPublic": IsPublic,
      "DisableNotification": DisableNotification
    });
    var response = await http.post(Uri.parse(_serviceUrl.updateCommon),
        headers: header, body: reqBody);

    if (response.body.isEmpty) {
      return true;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData['HasError'];
    }
  }

  @override
  Future<bool> UpdateCommonGroup(Map<String, String> header,
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
    var reqBody = jsonEncode({
      "Id": Id,
      "CreateDate": CreateDate,
      "UserId": UserId,
      "GroupName": GroupName,
      "ProjectNumber": ProjectNumber,
      "Street": Street,
      "PostalCode": PostalCode,
      "City": City,
      "State": State,
      "StartDate": StartDate,
      "EndDate": EndDate,
      "CustomerId": CustomerId,
      "PersonnelId": PersonnelId
    });

    var response = await http.post(Uri.parse(_serviceUrl.updateCommonGroup),
        headers: header, body: reqBody);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData['HasError'];
    }
  }

  @override
  Future<GetPermissionListByCategoryIdResult> GetPermissionListByCategoryId(
      Map<String, String> header,
      {int? ModuleCategoryId,
      String? Language}) async {
    var reqBody = jsonEncode({
      "ModuleCategoryId": ModuleCategoryId,
      "Language": Language,
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.getPermissionListByCategoryId),
        headers: header,
        body: reqBody);

    print("Req GetPermissionListByCategoryId: " + reqBody);
    print("Res GetPermissionListByCategoryId: " + response.body);

    if (response.body.isEmpty) {
      return GetPermissionListByCategoryIdResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetPermissionListByCategoryIdResult.fromJson(responseData);
    }
  }

  @override
  Future InsertOrUpdateDefinedRole(Map<String, String> header,
      {int? Id,
      String? Name,
      int? UserId,
      int? CustomerId,
      int? ModuleType,
      List<int>? PermissionIdList}) async {
    var reqBody = jsonEncode({
      "Id": Id,
      "Name": Name,
      "UserId": UserId,
      "CustomerId": CustomerId,
      "ModuleType": ModuleType,
      "PermissionIdList": PermissionIdList
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.insertOrUpdateDefinedRole),
        headers: header,
        body: reqBody);

    print("Req InsertOrUpdateDefinedRole: " + reqBody);
    print("Res InsertOrUpdateDefinedRole: " + response.body);

    if (response.body.isEmpty) {
      return true;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData['HasError'];
    }
  }

  @override
  Future<bool> DeleteDefinedRole(Map<String, String> header,
      {int? DefinedRoleId}) async {
    var reqBody = jsonEncode({
      "DefinedRoleId": DefinedRoleId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.deleteDefinedRole),
        headers: header, body: reqBody);

    print("Req DeleteDefinedRole: " + reqBody);
    print("Res DeleteDefinedRole: " + response.body);

    if (response.body.isEmpty) {
      return true;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData['HasError'];
    }
  }

  @override
  Future<PublicCategoryResult> GetPublicCategory(Map<String, String> header,
      {String? Language}) async {
    var reqBody = jsonEncode({
      "Language": Language,
    });
    var response = await http.post(Uri.parse(_serviceUrl.getPublicCategory),
        headers: header, body: reqBody);

    print("Req GetPublicCategory: " + reqBody);
    print("Res GetPublicCategory: " + response.body);

    if (response.body.isEmpty) {
      return PublicCategoryResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return PublicCategoryResult.fromJson(responseData);
    }
  }

  @override
  Future<GetOnlineMeetingsResult> GetOnlineMeetings(Map<String, String> header,
      {int? UserId}) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.getOpenMeetings),
        headers: header, body: reqBody);

    print("Req GetOnlineMeetings: " + reqBody);
    print("Res GetOnlineMeetings: " + response.body);

    if (response.body.isEmpty) {
      return GetOnlineMeetingsResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetOnlineMeetingsResult.fromJson(responseData);
    }
  }

  @override
  Future InviteUsersCommonBoardWithRole(Map<String, String> header,
      {int? UserId,
      int? CommonId,
      List<int>? DeletedUserIdList,
      List<UserListWithRole>? userListWithRoleId}) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
      "CommonId": CommonId,
      "DeletedUserIdList": DeletedUserIdList,
      "UserListWithRole": userListWithRoleId
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.inviteUsersCommonBoardWithRole),
        headers: header,
        body: reqBody);

    print("Req InviteUsersCommonBoardWithRole: " + reqBody);
    print("Res InviteUsersCommonBoardWithRole: " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }
}
