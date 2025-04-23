import 'package:undede/model/Common/DataLayoutAPI.dart';

class GetPermissionListResult extends DataLayoutAPI {
  List<Permission>? permissionList;

  GetPermissionListResult({this.permissionList, required bool hasError});

  GetPermissionListResult.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    if (json['Result'] != null) {
      permissionList = <Permission>[];
      json['Result'].forEach((v) {
        permissionList!.add(new Permission.fromJson(v));
      });
    }
    header = json['Header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Version'] = this.version;
    data['HasError'] = this.hasError;
    data['ResultCode'] = this.resultCode;
    data['ResultMessage'] = this.resultMessage;
    data['AuthenticationToken'] = this.authenticationToken;
    data['Result'] = this.permissionList!.map((v) => v.toJson()).toList();
      data['Header'] = this.header;
    return data;
  }
}

class CommonPermission {
  List<Permission> permissionList= [];
  int commonId;

  CommonPermission(this.permissionList, this.commonId);
}

class TodoPermission {
  List<Permission> permissionList = [];
  int todoId;
  int commonId;

  TodoPermission(this.permissionList, this.todoId, this.commonId);
}

class Permission {
  int? id;
  int? moduleCategoryId;
  String? moduleCategory;
  int? moduleSubCategoryId;
  String? moduleSubCategory;
  int? permissionTypeId;
  String? permissionType;

  Permission(
      {this.id,
      this.moduleCategoryId,
      this.moduleCategory,
      this.moduleSubCategoryId,
      this.moduleSubCategory,
      this.permissionTypeId,
      this.permissionType});

  Permission.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    moduleCategoryId = json['ModuleCategoryId'];
    moduleCategory = json['ModuleCategory'];
    moduleSubCategoryId = json['ModuleSubCategoryId'];
    moduleSubCategory = json['ModuleSubCategory'];
    permissionTypeId = json['PermissionTypeId'];
    permissionType = json['PermissionType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['ModuleCategoryId'] = this.moduleCategoryId;
    data['ModuleCategory'] = this.moduleCategory;
    data['ModuleSubCategoryId'] = this.moduleSubCategoryId;
    data['ModuleSubCategory'] = this.moduleSubCategory;
    data['PermissionTypeId'] = this.permissionTypeId;
    data['PermissionType'] = this.permissionType;
    return data;
  }
}
