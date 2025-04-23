import 'package:undede/model/Common/DataLayoutAPI.dart';
import 'package:undede/model/Common/GetCommonUserListResult.dart';
import 'package:undede/model/Todo/CommonTodo.dart';

class GetAllCommonsResult extends DataLayoutAPI {
  Result? result;

  GetAllCommonsResult({this.result, required bool hasError});

  GetAllCommonsResult.fromJson(Map<String, dynamic> json) {
    result =
        json['Result'] != null ? new Result.fromJson(json['Result']) : null;

    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    header = json['Header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.toJson();
      return data;
  }
}

class Result {
  List<CommonBoardListItem>? commonBoardList = [];
  int? totalPage;
  int? totalCount;

  Result({this.commonBoardList, this.totalPage, this.totalCount});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['CommonBoardList'] != null) {
      commonBoardList = <CommonBoardListItem>[];
      json['CommonBoardList'].forEach((v) {
        commonBoardList!.add(new CommonBoardListItem.fromJson(v));
      });
    }
    totalPage = json['TotalPage'];
    totalCount = json['TotalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CommonBoardList'] =
        this.commonBoardList!.map((v) => v.toJson()).toList();
      data['TotalPage'] = this.totalPage;
    data['TotalCount'] = this.totalCount;
    return data;
  }
}

class CommonBoardListItem {
  int? id;
  int? customerId;
  bool? state;
  String? title;
  String? description;
  String? photo;
  int? userId;
  String? createDate;
  int? commonGroupId;
  int? orderNumber;
  int? todoCount;
  bool? isSearchResultTodo;
  Null ownerId;
  int? userCount;
  int? fileCount;
  bool? isPublic;
  bool? disableNotification;
  int? definedRoleId;
  String? ownerUserPhoto;

  /* RESULT DIŞI */
  List<CommonTodo> todos = [];
  List<CommonUser> users = [];

  CommonBoardListItem(
      {this.id,
      this.customerId,
      this.state,
      this.title,
      this.description,
      this.photo,
      this.userId,
      this.createDate,
      this.commonGroupId,
      this.orderNumber,
      this.todoCount,
      this.isSearchResultTodo,
      this.ownerId,
      this.userCount,
      this.fileCount,
      this.disableNotification,
      this.isPublic,
      this.definedRoleId,
      this.ownerUserPhoto});

  CommonBoardListItem.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    customerId = json['CustomerId'];
    state = json['State'];
    title = json['Title'];
    description = json['Description'];
    photo = json['Photo'];
    userId = json['UserId'];
    createDate = json['CreateDate'];
    commonGroupId = json['CommonGroupId'];
    orderNumber = json['OrderNumber'];
    todoCount = json['TodoCount'];
    isSearchResultTodo = json['isSearchResultTodo'];
    ownerId = json['OwnerId'];
    userCount = json['UserCount'];
    fileCount = json['FileCount'];
    isPublic = json['IsPublic'];
    disableNotification = json['DisableNotification'];
    definedRoleId = json['DefinedRoleId'];
    ownerUserPhoto = json['OwnerUserPhoto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CustomerId'] = this.customerId;
    data['State'] = this.state;
    data['Title'] = this.title;
    data['Description'] = this.description;
    data['Photo'] = this.photo;
    data['UserId'] = this.userId;
    data['CreateDate'] = this.createDate;
    data['CommonGroupId'] = this.commonGroupId;
    data['OrderNumber'] = this.orderNumber;
    data['TodoCount'] = this.todoCount;
    data['isSearchResultTodo'] = this.isSearchResultTodo;
    data['OwnerId'] = this.ownerId;
    data['UserCount'] = this.userCount;
    data['FileCount'] = this.fileCount;
    data['IsPublic'] = this.isPublic;
    data['DisableNotification'] = this.disableNotification;
    data['DefinedRoleId'] = this.definedRoleId;
    data['OwnerUserPhoto'] = this.ownerUserPhoto;
    return data;
  }
}
