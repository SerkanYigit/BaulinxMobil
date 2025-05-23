import 'package:undede/model/Todo/CommonTodo.dart';

import 'GetTodoCheckListResult.dart';

class GetGenericTodosResult {
  List<GenericTodo>? genericTodo;

  GetGenericTodosResult({this.genericTodo, required bool hasError});

  GetGenericTodosResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      genericTodo = <GenericTodo>[];
      json['Result'].forEach((v) {
        genericTodo!.add(new GenericTodo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.genericTodo!.map((v) => v.toJson()).toList();
    return data;
  }
}

class UpdateGenericTodosResult {
  GenericTodo? genericTodoUpdate;

  UpdateGenericTodosResult({this.genericTodoUpdate, required bool hasError});

  UpdateGenericTodosResult.fromJson(Map<String, dynamic> json) {
    genericTodoUpdate = json['Result'] != null
        ? new GenericTodo.fromJson(json['Result'])
        : null;
    ;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['Result'] = this.genericTodoUpdate!.toJson();

    return data;
  }
}

class GenericTodo {
  int? id;
  int? ownerId;
  String? ownerName;
  String? ownerPicture;
  int? ownerType;
  String? content;
  int? status;
  int? userId;
  String? createDate;
  int? todoAdminId;
  String? description;
  String? startDate;
  String? endDate;
  String? remindDate;
  int? fileCount;
  int? commentCount;
  String? noteUrl;
  List<LabelList>? labelList;
  int? orderNumber;
  List<UserList>? userList;
  String? color;
  String? backgroundImage;
  GetTodoCheckListResult? checkList;

  GenericTodo(
      {this.id,
      this.ownerId,
      this.ownerName,
      this.ownerPicture,
      this.ownerType,
      this.content,
      this.status,
      this.userId,
      this.createDate,
      this.todoAdminId,
      this.description,
      this.startDate,
      this.endDate,
      this.remindDate,
      this.fileCount,
      this.commentCount,
      this.noteUrl,
      this.labelList,
      this.orderNumber,
      this.userList,
      this.color,
      this.backgroundImage});

  GenericTodo.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    ownerId = json['OwnerId'];
    ownerName = json['OwnerName'];
    ownerPicture = json['OwnerPicture'];
    ownerType = json['OwnerType'];
    content = json['Content'];
    status = json['Status'];
    userId = json['UserId'];
    createDate = json['CreateDate'];
    todoAdminId = json['TodoAdminId'];
    description = json['Description'];
    startDate = json['StartDate'];
    endDate = json['EndDate'];
    remindDate = json['RemindDate'];
    fileCount = json['FileCount'];
    commentCount = json['CommentCount'];
    noteUrl = json['NoteUrl'];
    if (json['LabelList'] != null) {
      labelList = <LabelList>[];
      json['LabelList'].forEach((v) {
        labelList!.add(new LabelList.fromJson(v));
      });
    }
    if (json['UserList'] != null) {
      userList = <UserList>[];
      json['UserList'].forEach((v) {
        userList!.add(new UserList.fromJson(v));
      });
    }
    orderNumber = json['OrderNumber'];
    color = json['Color'] ?? "b3c1a8";
    backgroundImage = json['BackgroundImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['OwnerId'] = this.ownerId;
    data['OwnerName'] = this.ownerName;
    data['OwnerPicture'] = this.ownerPicture;
    data['OwnerType'] = this.ownerType;
    data['Content'] = this.content;
    data['Status'] = this.status;
    data['UserId'] = this.userId;
    data['CreateDate'] = this.createDate;
    data['TodoAdminId'] = this.todoAdminId;
    data['Description'] = this.description;
    data['StartDate'] = this.startDate;
    data['EndDate'] = this.endDate;
    data['RemindDate'] = this.remindDate;
    data['FileCount'] = this.fileCount;
    data['CommentCount'] = this.commentCount;
    data['NoteUrl'] = this.noteUrl;
    data['LabelList'] = this.labelList!.map((v) => v.toJson()).toList();
    data['OrderNumber'] = this.orderNumber;
    data['UserList'] = this.userList!.map((v) => v.toJson()).toList();
    data['Color'] = this.color;
    data['BackgroundImage'] = this.backgroundImage;
    return data;
  }
}
