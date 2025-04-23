import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:undede/model/Todo/GetGenericTodosResult.dart';
import 'package:undede/model/Todo/GetTodoCheckListResult.dart';
import 'package:undede/model/Todo/GetTodoCommentsResult.dart';
import 'package:undede/model/Todo/GetTodoUserListResult.dart';
import 'package:undede/model/Todo/InsertGenericTodosResult.dart';
import 'package:undede/model/Todo/ResultCheckListUpdate.dart';

abstract class TodoBase {
  Future<GetCommonTodosResult> GetCommonTodos(Map<String, String> header,
      {int userId, int commonId, String search});
  Future<GetGenericTodosResult> GetGenericTodos(Map<String, String> header,
      {int userId, int ModuleType, String search, List<int> LabelIds});
  Future<GetGenericTodosResult> GetGenericCustomerTodos(
      Map<String, String> header,
      {int userId,
      int CustomerId,
      int ModuleType,
      String search,
      List<int> LabelIds});
  Future<InsertGenericTodosResult> InsertCommonTodos(Map<String, String> header,
      {int UserId,
      int CustomerId,
      int CommonBoardId,
      String TodoName,
      String Description,
      DateTime StartDate,
      DateTime EndDate,
      int ModuleType,
      String BackgroundImageBase64,
      String BackgroundImage});
  Future<GetTodoUserListResult> GetTodoUserList(Map<String, String> header,
      {int TodoId, int UserId});
  Future UpdateCommonTodos(Map<String, String> header,
      {int UserId,
      int CommonBoardId,
      String TodoName,
      String Description,
      int TodoId,
      int Status,
      String StartDate,
      String EndDate,
      String RemindDate,
      int ModuleType,
      bool DeleteBackgroundImage,
      String BackgroundImageBase64,
      String BackgroundImage});

  Future<GetTodoCommentsResult> GetTodoComments(Map<String, String> header,
      {int TodoId, int UserId});
  Future InsertTodoComment(Map<String, String> header,
      {int UserId,
      int TodoId,
      int RelatedCommentId,
      String Comment,
      String AudioFile,
      Files files,
      bool isCombine,
      String CombineFileName});
  Future DeleteTodo(
    Map<String, String> header, {
    int UserId,
    int TodoId,
  });
  Future CopyTodo(Map<String, String> header,
      {int UserId, int TodoId, List<int> TargetCommonIdList});

  Future MoveTodo(Map<String, String> header,
      {int UserId, int TodoId, int TargetCommonId});
  Future InviteUsersCommonTask(Map<String, String> header,
      {int UserId, int TodoId, int RoleId, List<int> TargetUserIdList});
  Future ConfirmInviteUsersCommonTask(Map<String, String> header,
      {int UserId, int NotificationId, int UserCommonOrderId, bool IsAccept});
  Future<GetTodoResult> GetTodo(Map<String, String> header, int TodoId);
  Future<GetTodoCheckListResult> GetTodoCheckList(Map<String, String> header,
      {int TodoId, int UserId});
  Future<ResultCheckListUpdate> InsertOrUpdateTodoCheckList(
      Map<String, String> header,
      {int Id,
      int TodoId,
      int UserId,
      String Title,
      bool IsDone});
  Future DeleteTodoCheckList(Map<String, String> header,
      {int UserId, int TodoCheckId});
}
