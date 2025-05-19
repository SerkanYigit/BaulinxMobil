import 'dart:async';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Provider/LocaleProvider.dart';
import 'package:undede/Services/TodoService/TodoBase.dart';
import 'package:undede/Services/TodoService/TodoDB.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:undede/model/Common/GetPermissionListResult.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:undede/model/Todo/GetGenericTodosResult.dart';
import 'package:undede/model/Todo/GetTodoCheckListResult.dart';
import 'package:undede/model/Todo/GetTodoCommentsResult.dart';
import 'package:undede/model/Todo/GetTodoUserListResult.dart';
import 'package:undede/model/Todo/InsertGenericTodosResult.dart';
import 'package:undede/model/Todo/ResultCheckListUpdate.dart';

class ControllerTodo extends GetxController implements TodoBase {
  TodoDB _todoDB = TodoDB();
  Rx<GetTodoCommentsResult?> commnets = null.obs;
  ControllerDB _controllerDB = Get.put(ControllerDB());
  List<TodoPermission> MyPermissionsOnTodos = [];
  bool refreshNote = false;
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  @override
  Future<GetCommonTodosResult> GetCommonTodos(Map<String, String> header,
      {int? userId, int? commonId, String? search}) async {
    return await _todoDB.GetCommonTodos(header,
        userId: userId, commonId: commonId, search: search);
  }

  @override
  Future<GetCommonTodosResult> GetCommonTodosTreeView(
      Map<String, String> header,
      {int? userId,
      int? commonId,
      String? search}) async {
    return await _todoDB.GetCommonTodosTreeView(header,
        userId: userId, commonId: commonId, search: search);
  }

  @override
  Future<InsertGenericTodosResult> InsertCommonTodos(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? CommonBoardId,
      String? TodoName,
      String? Description,
      DateTime? StartDate,
      DateTime? EndDate,
      int? ModuleType,
      String? BackgroundImageBase64,
      String? BackgroundImage}) async {
    return await _todoDB.InsertCommonTodos(header,
        UserId: UserId!,
        CustomerId: CustomerId,
        CommonBoardId: CommonBoardId!,
        TodoName: TodoName!,
        Description: Description!,
        StartDate: StartDate!,
        EndDate: EndDate!,
        ModuleType: ModuleType!,
        BackgroundImageBase64: BackgroundImageBase64,
        BackgroundImage: BackgroundImage);
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
    return await _todoDB.InsertCommonTodosTreeView(header,
        UserId: UserId!,
        CustomerId: CustomerId,
        CommonBoardId: CommonBoardId!,
        TodoName: TodoName!,
        Description: Description!,
        StartDate: StartDate!,
        EndDate: EndDate!,
        ModuleType: ModuleType!,
        BackgroundImageBase64: BackgroundImageBase64,
        BackgroundImage: BackgroundImage,
        ownerId: ownerId,
        parentId: parentId);
  }

  @override
  Future<GetTodoUserListResult> GetTodoUserList(Map<String, String> header,
      {int? TodoId, int? UserId}) async {
    return await _todoDB.GetTodoUserList(header,
        TodoId: TodoId!, UserId: UserId!);
  }

  @override
  Future<UpdateGenericTodosResult> UpdateCommonTodos(Map<String, String> header,
      {int? UserId,
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
    return await _todoDB.UpdateCommonTodos(
      header,
      UserId: UserId,
      CommonBoardId: CommonBoardId,
      TodoName: TodoName,
      Description: Description,
      TodoId: TodoId,
      Status: Status,
      StartDate: StartDate,
      EndDate: EndDate,
      RemindDate: RemindDate,
      ModuleType: ModuleType,
      DeleteBackgroundImage: DeleteBackgroundImage,
      BackgroundImageBase64: BackgroundImageBase64,
      BackgroundImage: BackgroundImage,
    );
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
    DateTime? StartDate,
    DateTime? EndDate,
    String? RemindDate,
    int? ModuleType,
    bool? DeleteBackgroundImage,
    String? BackgroundImageBase64,
    String? BackgroundImage,
    int? ownerId,
    int? parentId,
  }) async {
    dynamic myDate(dynamic item) {
      if (item is DateTime) {
        return item.toIso8601String();
      }
      return item;
    }

    return await _todoDB.UpdateCommonTodosTreeView(
      header,
      UserId: UserId!,
      CommonBoardId: CommonBoardId!,
      TodoName: TodoName!,
      Description: Description!,
      TodoId: TodoId!,
      Status: Status,
      StartDate: myDate(StartDate)!,
      EndDate: myDate(EndDate)!!,
      RemindDate: RemindDate,
      ModuleType: ModuleType,
      DeleteBackgroundImage: DeleteBackgroundImage,
      BackgroundImageBase64: BackgroundImageBase64,
      BackgroundImage: BackgroundImage,
      ownerId: ownerId,
      parentId: parentId,
    );
  }

  @override
  Future<GetTodoCommentsResult> GetTodoComments(Map<String, String> header,
      {int? TodoId, int? UserId}) async {
    var value =
        await _todoDB.GetTodoComments(header, TodoId: TodoId!, UserId: UserId!);
    update();
    commnets = value.obs;
    update();

    return value;
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
    return await _todoDB.InsertTodoComment(header,
        UserId: UserId!,
        TodoId: TodoId!,
        RelatedCommentId: RelatedCommentId!,
        Comment: Comment!,
        AudioFile: AudioFile!,
        files: files!,
        isCombine: isCombine!,
        CombineFileName: CombineFileName!);
  }

  @override
  Future CopyTodo(Map<String, String> header,
      {int? UserId, int? TodoId, List<int>? TargetCommonIdList}) async {
    return await _todoDB.CopyTodo(
      header,
      UserId: UserId!,
      TodoId: TodoId!,
      TargetCommonIdList: TargetCommonIdList!,
    );
  }

  @override
  Future DeleteTodo(Map<String, String> header,
      {int? UserId, int? TodoId}) async {
    return await _todoDB.DeleteTodo(header, UserId: UserId!, TodoId: TodoId!);
  }

  @override
  Future MoveTodo(Map<String, String> header,
      {int? UserId, int? TodoId, int? TargetCommonId}) async {
    return await _todoDB.MoveTodo(header,
        UserId: UserId!, TodoId: TodoId!, TargetCommonId: TargetCommonId!);
  }

  @override
  Future ConfirmInviteUsersCommonTask(Map<String, String> header,
      {int? UserId,
      int? NotificationId,
      int? UserCommonOrderId,
      bool? IsAccept}) async {
    return await _todoDB.ConfirmInviteUsersCommonTask(header,
        UserId: _controllerDB.user.value!.result!.id,
        NotificationId: NotificationId!,
        UserCommonOrderId: UserCommonOrderId!,
        IsAccept: IsAccept!);
  }

  @override
  Future InviteUsersCommonTask(Map<String, String> header,
      {int? UserId,
      int? TodoId,
      int? RoleId,
      List<int>? TargetUserIdList}) async {
    return await _todoDB.InviteUsersCommonTask(
      header,
      UserId: UserId!,
      TodoId: TodoId!,
      RoleId: RoleId!,
      TargetUserIdList: TargetUserIdList!,
    );
  }

  @override
  Future<GetTodoResult> GetTodo(Map<String, String> header, int TodoId) async {
    return await _todoDB.GetTodo(header, TodoId);
  }

  bool hasDeleteTodoPerm(int commonId, int todoId) {
    // Find the common board by commonId
    var commonBoard = _controllerCommon
        .getAllCommons.value!.result!.commonBoardList!
        .firstWhereOrNull((element) => element.id == commonId);

    // Find the todo item by todoId
    var todo = commonBoard?.todos.firstWhere((element) => element.id == todoId,
        orElse: () => CommonTodo());

    // Check if the userId matches
    if (todo?.userId == _controllerDB.user.value!.result!.id) {
      return true;
    }

    // Check permissions on todos
    // List<Permission> permList = MyPermissionsOnTodos.firstWhere(
    //   (e) => e.commonId == commonId && e.todoId == todoId,
    //   orElse: () => null,
    // ).permissionList;

    List<Permission>? permList;

    var foundPermission = MyPermissionsOnTodos.firstWhereOrNull(
      (e) => e.commonId == commonId && e.todoId == todoId,
    );

    if (foundPermission != null) {
      permList = foundPermission.permissionList;
    } else {
      print("Eşleşen izin bulunamadı!");
      permList = [];
    }

    if (permList.isEmpty) {
      // If no permissions found on todos, check permissions on boards
      permList = _controllerCommon.MyPermissionsOnBoards.firstWhere(
          (e) => e.commonId == commonId,
          orElse: () => CommonPermission([], commonId)).permissionList;

      if (permList.isEmpty) {
        // If no permissions found on boards, check if the userId matches
        if (commonBoard?.userId == _controllerDB.user.value!.result!.id) {
          return true;
        } else {
          return false;
        }
      } else {
        // Check for specific permission in the list
        return permList.any(
          (perm) =>
              perm.moduleCategoryId == 14 &&
              perm.moduleSubCategoryId == 35 &&
              perm.permissionTypeId == 2,
        );
      }
    } else {
      // Check for specific permission in the list
      return permList.any(
        (perm) =>
            perm.moduleCategoryId == 31 &&
            perm.moduleSubCategoryId == 33 &&
            perm.permissionTypeId == 2,
      );
    }
  }

  Future<bool> hasCopyTodoPerm(int commonId, int todoId) async {
    // Find the common board by commonId
    var commonBoard = await _controllerCommon
        .getAllCommons.value!.result!.commonBoardList!
        .firstWhere((element) => element.id == commonId,
            orElse: () => CommonBoardListItem());
    print('objecttt' + commonBoard.toString());

    // Find the todo item by todoId
    var todo = commonBoard.todos.firstWhere(
      (element) => element.id == todoId,
      orElse: () => CommonTodo(),
    );
    // Check if the userId matches
    if (todo.userId == _controllerDB.user.value!.result!.id) {
      return true;
    }

    // Check permissions on todos
    List<Permission> permList = MyPermissionsOnTodos.firstWhere(
        (e) => e.commonId == commonId && e.todoId == todoId,
        orElse: () => TodoPermission([], commonId, todoId)).permissionList;

    if (permList.isEmpty) {
      // If no permissions found on todos, check permissions on boards
      permList = _controllerCommon.MyPermissionsOnBoards.firstWhere(
          (e) => e.commonId == commonId,
          orElse: () => CommonPermission([], commonId)).permissionList;

      if (permList.isEmpty) {
        // If no permissions found on boards, check if the userId matches
        var deneme = _controllerCommon
            .getAllCommons.value!.result!.commonBoardList!
            .where(
          (element) => element.id == commonId,
        );

        if (deneme.isNotEmpty) {
          if (deneme.first.userId == _controllerDB.user.value!.result!.id) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        // Check for specific permission in the list
        return permList.any(
          (perm) =>
              perm.moduleCategoryId == 14 &&
              perm.moduleSubCategoryId == 35 &&
              perm.permissionTypeId == 10,
        );
      }
    } else {
      // Check for specific permission in the list
      return permList.any(
        (perm) =>
            perm.moduleCategoryId == 31 &&
            perm.moduleSubCategoryId == 33 &&
            perm.permissionTypeId == 10,
      );
    }
  }

  Future<bool> hasEditTodoPerm(int commonId, int todoId) async {
    if (await _controllerCommon.getAllCommons.value!.result!.commonBoardList!
            .firstWhere((element) => element.id == commonId,
                orElse: () => CommonBoardListItem())
            .todos
            .firstWhere(
              (element) => element.id == todoId,
              orElse: () => CommonTodo(),
            )
            .userId ==
        _controllerDB.user.value!.result!.id) {
      return true;
    }

    List<Permission> permList = MyPermissionsOnTodos.firstWhere(
      (e) => e.commonId == commonId && e.todoId == todoId,
      orElse: () {
        return TodoPermission([], commonId, todoId);
      },
    ).permissionList;

    if (permList.length == 0) {
      List<Permission> permList =
          _controllerCommon.MyPermissionsOnBoards.firstWhere(
              (e) => e.commonId == commonId,
              orElse: () => CommonPermission([], commonId)).permissionList;
      if (permList.length == 0) if (_controllerCommon
                  .getAllCommons.value!.result!.commonBoardList!
                  .where((element) => element.id == commonId)
                  .length ==
              0
          ? false
          : _controllerCommon.getAllCommons.value!.result!.commonBoardList!
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
                    perm.moduleSubCategoryId == 35 &&
                    perm.permissionTypeId == 3)
                .length >=
            1;
    } else {
      return permList
              .where((perm) =>
                  perm.moduleCategoryId == 31 &&
                  perm.moduleSubCategoryId == 33 &&
                  perm.permissionTypeId == 3)
              .length >=
          1;
    }
  }

  bool hasMoveTodoPerm(int commonId, int todoId) {
    return true;
    // if (_controllerCommon.getAllCommons.value.result.commonBoardList
    //         .where((element) => element.id == commonId)
    //         .first
    //         .todos
    //         .firstWhere((element) => element.id == todoId)
    //         .userId ==
    //     _controllerDB.user.value.result.id) {
    //   return true;
    // }

    // List<Permission> permList = MyPermissionsOnTodos.firstWhere(
    //     (e) => e.commonId == commonId && e.todoId == todoId,
    //     orElse: () => null)?.permissionList;

    // if (permList?.length == 0 || permList?.length == null) {
    //   List<Permission> permList =
    //       _controllerCommon.MyPermissionsOnBoards.firstWhere(
    //           (e) => e.commonId == commonId,
    //           orElse: () => null)?.permissionList;
    //   if (permList?.length == 0 ||
    //       permList?.length == null) if (_controllerCommon
    //           .getAllCommons.value.result.commonBoardList
    //           .where((element) => element.id == commonId)
    //           .first
    //           .userId ==
    //       _controllerDB.user.value.result.id) {
    //     return true;
    //   } else {
    //     return false;
    //   }
    //   else
    //     return permList
    //             ?.where((perm) =>
    //                 perm.moduleCategoryId == 14 &&
    //                 perm.moduleSubCategoryId == 35 &&
    //                 perm.permissionTypeId == 9)
    //             .length >=
    //         1;
    // } else
    //   return permList
    //           .where((perm) =>
    //               perm.moduleCategoryId == 31 &&
    //               perm.moduleSubCategoryId == 33 &&
    //               perm.permissionTypeId == 9)
    //           .length >=
    //       1;
  }

  Future<bool> hasFileManagerTodoPerm(int commonId, int todoId) async {
    print('******************ddddddddddddddddd');
    print('******************ddd' +
        commonId.toString() +
        '*************' +
        todoId.toString());
    var commonBoard;
    commonBoard = await _controllerCommon
        .getAllCommons.value!.result!.commonBoardList!
        .firstWhere(
      (element) => element.id == commonId,
      orElse: () {
        return CommonBoardListItem();
      },
    );

    var todo = commonBoard.todos.firstWhere(
      (element) => element.id == todoId,
      orElse: () => CommonTodo(),
    );

    // Check if the userId matches
    if (todo.userId == _controllerDB.user.value!.result!.id) {
      return true;
    }

    // Check permissions on todos
    List<Permission> permList = MyPermissionsOnTodos.firstWhere(
      (e) => e.commonId == commonId && e.todoId == todoId,
      orElse: () {
        return TodoPermission([], commonId, todoId);
      },
    ).permissionList;
    return false;

    // if ((permList == null || permList.isEmpty)) {
    //   // Check permissions on boards if no permissions found on todos
    //   permList = _controllerCommon.MyPermissionsOnBoards.firstWhere(
    //     (e) => e.commonId == commonId,
    //     orElse: () => null,
    //   )?.permissionList;

    //   if ((permList == null || permList.isEmpty) && commonBoard != null) {
    //     // If no permissions on boards, check if the userId matches
    //     if (commonBoard.userId == _controllerDB.user.value.result.id) {
    //       return true;
    //     } else {
    //       return false;
    //     }
    //   } else {
    //     // Check for specific permission in the list
    //     return permList.any(
    //       (perm) =>
    //           perm.moduleCategoryId == 14 &&
    //           perm.moduleSubCategoryId == 35 &&
    //           perm.permissionTypeId == 7,
    //     );
    //   }
    // } else {
    //   // Check for specific permission in the list
    //   return permList.any(
    //     (perm) =>
    //         perm.moduleCategoryId == 31 &&
    //         perm.moduleSubCategoryId == 5 &&
    //         perm.permissionTypeId == 4,
    //   );
    // }
  }

  bool hasCreateCallTodoPerm(int commonId, int todoId) {
    CommonBoardListItem commonBoard = _controllerCommon
        .getAllCommons.value!.result!.commonBoardList!
        .firstWhere(
      (element) => element.id == commonId,
      orElse: () => CommonBoardListItem(),
    );
    print("hasCreateCallTodoPerm : " + commonBoard.toString());

    var todo;
    todo = commonBoard.todos.firstWhere(
      (element) => element.id == todoId,
      orElse: () => CommonTodo(),
    );

    if (todo.userId == _controllerDB.user.value!.result!.id) {
      return true;
    }

    List<Permission> permList = [];
    if (MyPermissionsOnTodos.isNotEmpty) {
      permList = MyPermissionsOnTodos.firstWhere(
        (e) => e.commonId == commonId && e.todoId == todoId,
      ).permissionList;
    }

    if (permList.isEmpty) {
      permList = _controllerCommon.MyPermissionsOnBoards.firstWhere(
        (e) => e.commonId == commonId,
        orElse: () {
          return CommonPermission(
            [],
            commonId,
          );
        },
      ).permissionList;

      if (permList.isEmpty) {
        if (commonBoard.userId == _controllerDB.user.value!.result!.id) {
          return true;
        } else {
          return false;
        }
      } else {
        return permList.any(
          (perm) =>
              perm.moduleCategoryId == 14 &&
              perm.moduleSubCategoryId == 35 &&
              perm.permissionTypeId == 13,
        );
      }
    } else {
      return permList.any(
        (perm) =>
            perm.moduleCategoryId == 31 &&
            perm.moduleSubCategoryId == 33 &&
            perm.permissionTypeId == 13,
      );
    }
  }

  @override
  Future DeleteTodoCheckList(Map<String, String> header,
      {int? UserId, int? TodoCheckId}) async {
    bool hasError = await _todoDB.DeleteTodoCheckList(header,
        UserId: UserId!, TodoCheckId: TodoCheckId!);
    if (hasError)
      showErrorToast(errorInsertCheckListDelete!);
    else
      showSuccessToast(successInsertCheckListDelete!);
    return hasError;
  }

  @override
  Future<GetTodoCheckListResult> GetTodoCheckList(Map<String, String> header,
      {int? TodoId, int? UserId}) async {
    return await _todoDB.GetTodoCheckList(header,
        TodoId: TodoId!, UserId: UserId!);
  }

  @override
  Future<ResultCheckListUpdate> InsertOrUpdateTodoCheckList(
      Map<String, String> header,
      {int? Id,
      int? TodoId,
      int? UserId,
      String? Title,
      bool? IsDone}) async {
    var value = await _todoDB.InsertOrUpdateTodoCheckList(
      header,
      Id: Id!,
      TodoId: TodoId!,
      UserId: UserId!,
      Title: Title!,
      IsDone: IsDone!,
    );
    if (value.result == 0)
      showErrorToast(errorInsertCheckList!);
    else
      showSuccessToast(successInsertCheckList!);
    return value;
  }

  @override
  Future<GetGenericTodosResult> GetGenericTodos(
    Map<String, String> header, {
    int? userId,
    int? ModuleType,
    String? search,
    List<int>? LabelIds,
    int? ownerId,
  }) async {
    return await _todoDB.GetGenericTodos(header,
        userId: userId!,
        ModuleType: ModuleType,
        search: search,
        LabelIds: LabelIds,
        ownerId: ownerId);
  }

  @override
  Future<GetGenericTodosResult> GetGenericCustomerTodos(
      Map<String, String> header,
      {int? userId,
      int? CustomerId,
      int? ModuleType,
      String? search,
      List<int>? LabelIds}) async {
    return await _todoDB.GetGenericCustomerTodos(
      header,
      userId: userId!,
      CustomerId: CustomerId!,
      ModuleType: ModuleType!,
      search: search!,
      LabelIds: LabelIds!,
    );
  }

  ControllerLocal _controllerLocal = Get.put(ControllerLocal());
  String langCode() =>
      _controllerLocal.locale!.value.languageCode ??
      Get.deviceLocale!.languageCode;
  String? get errorInsertCheckList {
    switch (langCode()) {
      case "en":
        return "Cannot set or Update CheckList . Please try again later";
      case "tr":
        return "Check List eklenemedi veya güncellenemedi. Lütfen daha sonra tekrar deneyiniz";
      case "de":
        return "";
    }
    return null;
  }

  String? get successInsertCheckList {
    switch (langCode()) {
      case "en":
        return "CheckList set successfully";
      case "tr":
        return "Check List başarıyla eklendi veya güncellendi";
      case "de":
        return "";
    }
    return null;
  }

  String? get errorInsertCheckListDelete {
    switch (langCode()) {
      case "en":
        return "Cannot delete CheckListDelete . Please try again later";
      case "tr":
        return "Check List silinemedi. Lütfen daha sonra tekrar deneyiniz";
      case "de":
        return "";
    }
    return null;
  }

  String? get successInsertCheckListDelete {
    switch (langCode()) {
      case "en":
        return "CheckList deleted successfully";
      case "tr":
        return "Check List başarıyla Silindi";
      case "de":
        return "";
    }
    return null;
  }
}
