import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:undede/Services/TodoService/TodoBase.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:undede/model/Todo/GetGenericTodosResult.dart';
import 'package:undede/model/Todo/GetTodoCheckListResult.dart';
import 'package:undede/model/Todo/GetTodoCommentsResult.dart';
import 'package:undede/model/Todo/GetTodoUserListResult.dart';
import 'package:undede/model/Todo/InsertGenericTodosResult.dart';
import 'package:undede/model/Todo/ResultCheckListUpdate.dart';
import '../ServiceUrl.dart';

class TodoDB implements TodoBase {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<GetCommonTodosResult> GetCommonTodos(Map<String, String> header,
      {int? userId, int? commonId, String? search}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getCommonTodos),
        headers: header,
        body: jsonEncode(
            {"UserId": userId, "CommonId": commonId, "Search": search}));

    log("req GetCommonTodos = " +
        jsonEncode({"UserId": userId, "CommonId": commonId, "Search": search}));
    log("res GetCommonTodos = " + response.body);

    if (response.body.isEmpty) {
      return GetCommonTodosResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetCommonTodosResult.fromJson(responseData);
    }
  }

  @override
  Future<GetCommonTodosResult> GetCommonTodosTreeView(
    Map<String, String> header, {
    int? userId,
    int? commonId,
    String? search,
    List? LabelIds,
    int? OwnerType,
    int? ParentId,
  }) async {
    var response = await http.post(Uri.parse(_serviceUrl.getCommonTodos),
        headers: header,
        body: jsonEncode({
          "UserId": userId,
          "CommonId": commonId,
          "Search": search,
          "LabelIds": [],
          "OwnerType": 99,
          "ParentId": 0,
        }));

    log("req GetCommonTodos = " +
        jsonEncode({"UserId": userId, "CommonId": commonId, "Search": search}));
    log("res GetCommonTodos = " + response.body);

    if (response.body.isEmpty) {
      return GetCommonTodosResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetCommonTodosResult.fromJson(responseData);
    }
  }

  @override
  Future<InsertGenericTodosResult> InsertCommonTodos(
    Map<String, String> header, {
    int? UserId,
    int? CustomerId,
    int? CommonBoardId,
    String? TodoName,
    String? Description,
    DateTime? StartDate,
    DateTime? EndDate,
    int? ModuleType,
    String? BackgroundImageBase64,
    String? BackgroundImage,
    int? ownerId,
    int? status,
  }) async {
    var body = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "CommonBoardId": CommonBoardId,
      "TodoName": TodoName,
      "Description": Description,
      "StartDate": StartDate.toString(),
      "EndDate": EndDate.toString(),
      "ModuleType": ModuleType,
      "BackgroundImageBase64": BackgroundImageBase64,
      "BackgroundImage": BackgroundImage,
      "OwnerId": ownerId,
      "Status": status,
    });
    var response = await http.post(Uri.parse(_serviceUrl.insertCommonTodos),
        headers: header, body: body);
    log("req InsertCommonTodos" + body);
    log("res InsertCommonTodos" + response.body);
    if (response.body.isEmpty) {
      return InsertGenericTodosResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return InsertGenericTodosResult.fromJson(responseData);
    }
  }

  @override
  Future<InsertGenericTodosResult> InsertCommonTodosTreeView(
    Map<String, String> header, {
    int? UserId,
    int? CustomerId,
    int? CommonBoardId,
    String? TodoName,
    String? Description,
    DateTime? StartDate,
    DateTime? EndDate,
    int? ModuleType,
    String? BackgroundImageBase64,
    String? BackgroundImage,
    int? ownerId,
    int? parentId,
  }) async {
    var body = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "CommonBoardId": CommonBoardId,
      "TodoName": TodoName,
      "Description": Description,
      "StartDate": StartDate.toString(),
      "EndDate": EndDate.toString(),
      "ModuleType": ModuleType,
      "BackgroundImageBase64": BackgroundImageBase64,
      "BackgroundImage": BackgroundImage,
      "OwnerId": ownerId,
      "ParentId": parentId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.insertCommonTodos),
        headers: header, body: body);
    log("req InsertCommonTodos" + body);
    log("res InsertCommonTodos" + response.body);
    if (response.body.isEmpty) {
      return InsertGenericTodosResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return InsertGenericTodosResult.fromJson(responseData);
    }
  }

  @override
  Future<GetTodoUserListResult> GetTodoUserList(Map<String, String> header,
      {int? TodoId, int? UserId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getTodoUserList),
        headers: header,
        body: jsonEncode({
          "TodoId": TodoId,
          "UserId": UserId,
        }));

    //log("req GetAllCommons = " + response.request.url.toString());
    log("res GetTodoUserList = " + response.body);

    if (response.body.isEmpty) {
      return GetTodoUserListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetTodoUserListResult.fromJson(responseData);
    }
  }

  @override
  Future<UpdateGenericTodosResult> UpdateCommonTodos(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? CommonBoardId,
      String? TodoName,
      String? Description,
      int? TodoId,
      int? Status,
      String? StartDate,
      String? EndDate,
      String? RemindDate,
      int? ModuleType,
      bool? DeleteBackgroundImage,
      String? BackgroundImageBase64,
      String? BackgroundImage}) async {
    var body = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "CommonBoardId": CommonBoardId,
      "TodoName": TodoName,
      "Description": Description,
      "TodoId": TodoId,
      "Status": Status,
      "StartDate": StartDate,
      "EndDate": EndDate,
      "RemindDate": RemindDate,
      "ModuleType": ModuleType,
      "DeleteBackgroundImage": DeleteBackgroundImage,
      "BackgroundImageBase64": BackgroundImageBase64,
      "BackgroundImage": BackgroundImage,
    });
    var response = await http.post(Uri.parse(_serviceUrl.updateCommonTodos),
        headers: header, body: body);
    print("body içinde ne var" + body.toString());
    log("req UpdateCommonTodos = " + response.body);

    if (response.body.isEmpty) {
      return UpdateGenericTodosResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return UpdateGenericTodosResult.fromJson(responseData);
    }
  }

  @override
  Future<UpdateGenericTodosResult> UpdateCommonTodosTreeView(
    Map<String, String> header, {
    int? UserId,
    int? CommonBoardId,
    String? TodoName,
    String? Description,
    int? TodoId,
    int? Status,
    String? StartDate,
    String? EndDate,
    String? RemindDate,
    int? ModuleType,
    bool? DeleteBackgroundImage,
    String? BackgroundImageBase64,
    String? BackgroundImage,
    int? ownerId,
    int? parentId,
  }) async {
    var body = jsonEncode({
      "UserId": UserId,
      "CommonBoardId": CommonBoardId,
      "TodoName": TodoName,
      "Description": Description,
      "TodoId": TodoId,
      "Status": Status,
      "StartDate": StartDate,
      "EndDate": EndDate,
      "RemindDate": RemindDate,
      "ModuleType": ModuleType,
      "DeleteBackgroundImage": DeleteBackgroundImage,
      "BackgroundImageBase64": BackgroundImageBase64,
      "BackgroundImage": BackgroundImage,
      "OwnerId": ownerId,
      "ParentId": parentId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.updateCommonTodos),
        headers: header, body: body);
    print("body içinde ne var" + body.toString());
    log("req UpdateCommonTodos = " + response.body);

    if (response.body.isEmpty) {
      return UpdateGenericTodosResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return UpdateGenericTodosResult.fromJson(responseData);
    }
  }

  @override
  Future<GetTodoCommentsResult> GetTodoComments(Map<String, String> header,
      {int? TodoId, int? UserId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getTodoComments),
        headers: header,
        body: jsonEncode({
          "TodoId": TodoId,
          "UserId": UserId,
        }));

    log("res GetTodoComments : " + response.body);

    if (response.body.isEmpty) {
      return GetTodoCommentsResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetTodoCommentsResult.fromJson(responseData);
    }
  }

  @override
  Future InsertTodoComment(Map<String, String> header,
      {int? UserId,
      int? TodoId,
      int? RelatedCommentId,
      String? Comment,
      String? AudioFile,
      Files? files,
      bool? isCombine,
      String? CombineFileName}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "TodoId": TodoId,
      "RelatedCommentId": RelatedCommentId,
      "Comment": Comment,
      "AudioFile": AudioFile,
      "Files": files?.toJson(),
      "isCombine": isCombine,
      "CombineFileName": CombineFileName,
    });
    var response = await http.post(Uri.parse(_serviceUrl.insertTodoComment),
        headers: header, body: responseBody);

    log("req InsertTodoComment = " + responseBody.toString());
    log("res InsertTodoComment = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future CopyTodo(Map<String, String> header,
      {int? UserId, int? TodoId, List<int>? TargetCommonIdList}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "TodoId": TodoId,
      "TargetCommonIdList": TargetCommonIdList,
    });
    var response = await http.post(Uri.parse(_serviceUrl.copyTodo),
        headers: header, body: responseBody);

    log("req CopyTodo = " + responseBody.toString());
    log("res CopyTodo = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future DeleteTodo(Map<String, String> header,
      {int? UserId, int? TodoId}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "TodoId": TodoId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.deleteTodo),
        headers: header, body: responseBody);

    log("req DeleteTodo = " + responseBody.toString());
    log("res DeleteTodo = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future MoveTodo(Map<String, String> header,
      {int? UserId, int? TodoId, int? TargetCommonId}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "TodoId": TodoId,
      "TargetCommonId": TargetCommonId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.moveTodo),
        headers: header, body: responseBody);

    log("req MoveTodo = " + responseBody.toString());
    log("res MoveTodo = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future ConfirmInviteUsersCommonTask(Map<String, String> header,
      {int? UserId,
      int? NotificationId,
      int? UserCommonOrderId,
      bool? IsAccept}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "NotificationId": NotificationId,
      "UserCommonOrderId": UserCommonOrderId,
      "IsAccept": IsAccept,
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.ConfirmInviteUsersCommonTask),
        headers: header,
        body: responseBody);

    log("req ConfirmInviteUsersCommonTask = " + responseBody.toString());
    log("res ConfirmInviteUsersCommonTask = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future InviteUsersCommonTask(Map<String, String> header,
      {int? UserId,
      int? TodoId,
      int? RoleId,
      List<int>? TargetUserIdList}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "TodoId": TodoId,
      "RoleId": RoleId,
      "TargetUserIdList": TargetUserIdList
    });
    var response = await http.post(Uri.parse(_serviceUrl.InviteUsersCommonTask),
        headers: header, body: responseBody);

    log("req InviteUsersCommonTask = " + responseBody.toString());
    log("res InviteUsersCommonTask = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future<GetTodoResult> GetTodo(Map<String, String> header, int TodoId) async {
    var response = await http.get(Uri.parse(_serviceUrl.getTodo + "/${TodoId}"),
        headers: header);
    log("req GetTodo TodoId = " + TodoId.toString());
    log("res GetTodo = " + response.body);
    if (response.body.isEmpty) {
      return GetTodoResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetTodoResult.fromJson(responseData);
    }
  }

  @override
  Future<GetTodoCheckListResult> GetTodoCheckList(Map<String, String> header,
      {int? TodoId, int? UserId}) async {
    var responseBody = jsonEncode({
      "TodoId": TodoId,
      "UserId": UserId,
    });

    var response = await http.post(Uri.parse(_serviceUrl.getTodoCheckList),
        headers: header, body: responseBody);
    print("req GetTodoCheckList" + responseBody);
    print("res GetTodoCheckList" + response.body);
    if (response.body.isEmpty) {
      return GetTodoCheckListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetTodoCheckListResult.fromJson(responseData);
    }
  }

  @override
  Future<ResultCheckListUpdate> InsertOrUpdateTodoCheckList(
      Map<String, String> header,
      {int? Id,
      int? TodoId,
      int? UserId,
      String? Title,
      bool? IsDone}) async {
    var body = jsonEncode({
      "Id": Id,
      "TodoId": TodoId,
      "UserId": UserId,
      "Title": Title,
      "IsDone": IsDone
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.insertOrUpdateTodoCheckList),
        headers: header,
        body: body);

    print("req InsertOrUpdateTodoCheckList:" + body.toString());
    print("req InsertOrUpdateTodoCheckList:" + response.body);

    if (response.body.isEmpty) {
      return ResultCheckListUpdate(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return ResultCheckListUpdate.fromJson(responseData);
    }
  }

  @override
  Future DeleteTodoCheckList(Map<String, String> header,
      {int? UserId, int? TodoCheckId}) async {
    var body = jsonEncode({
      "UserId": UserId,
      "TodoCheckId": TodoCheckId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.deleteTodoCheckList),
        headers: header, body: body);

    print("req DeleteTodoCheckList:" + body.toString());
    print("req DeleteTodoCheckList:" + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<GetGenericTodosResult> GetGenericTodos(Map<String, String> header,
      {int? userId,
      int? ModuleType,
      String? search,
      List<int>? LabelIds,
      int? ownerId}) async {
    var reqBody = jsonEncode({
      "UserId": userId,
      "ModuleType": ModuleType,
      "Search": search,
      "LabelIds": LabelIds,
      "OwnerId": ownerId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.getGenericTodos),
        headers: header, body: reqBody);

    log("req GetGenericTodos = " + reqBody);
    log("res GetGenericTodos = " + response.body);

    if (response.body.isEmpty) {
      return GetGenericTodosResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetGenericTodosResult.fromJson(responseData);
    }
  }

  @override
  Future<GetGenericTodosResult> GetGenericCustomerTodos(
      Map<String, String> header,
      {int? userId,
      int? CustomerId,
      int? ModuleType,
      String? search,
      List<int>? LabelIds}) async {
    var reqBody = jsonEncode({
      "UserId": userId,
      "CustomerId": CustomerId,
      "ModuleType": ModuleType,
      "Search": search,
      "LabelIds": LabelIds
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.getGenericCustomerTodos),
        headers: header,
        body: reqBody);

    log("req GetGenericCustomerTodos = " + reqBody);
    log("res GetGenericCustomerTodos = " + response.body);

    if (response.body.isEmpty) {
      return GetGenericTodosResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetGenericTodosResult.fromJson(responseData);
    }
  }
}
