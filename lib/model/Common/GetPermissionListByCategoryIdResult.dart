class GetPermissionListByCategoryIdResult {
  List<Result>? result;

  GetPermissionListByCategoryIdResult({this.result, required bool hasError});

  GetPermissionListByCategoryIdResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <Result>[];
      json['Result'].forEach((v) {
        result!.add(new Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Result {
  int? id;
  int? moduleCategoryId;
  String? moduleCategory;
  int? moduleSubCategoryId;
  String? moduleSubCategory;
  String? moduleSubCategoryTranslate;
  int? permissionTypeId;
  String? permissionType;
  String? permissionTypeTranslate;

  Result(
      {this.id,
      this.moduleCategoryId,
      this.moduleCategory,
      this.moduleSubCategoryId,
      this.moduleSubCategory,
      this.moduleSubCategoryTranslate,
      this.permissionTypeId,
      this.permissionType,
      this.permissionTypeTranslate});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    moduleCategoryId = json['ModuleCategoryId'];
    moduleCategory = json['ModuleCategory'];
    moduleSubCategoryId = json['ModuleSubCategoryId'];
    moduleSubCategory = json['ModuleSubCategory'];
    moduleSubCategoryTranslate = json['ModuleSubCategoryTranslate'];
    permissionTypeId = json['PermissionTypeId'];
    permissionType = json['PermissionType'];
    permissionTypeTranslate = json['PermissionTypeTranslate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['ModuleCategoryId'] = this.moduleCategoryId;
    data['ModuleCategory'] = this.moduleCategory;
    data['ModuleSubCategoryId'] = this.moduleSubCategoryId;
    data['ModuleSubCategory'] = this.moduleSubCategory;
    data['ModuleSubCategoryTranslate'] = this.moduleSubCategoryTranslate;
    data['PermissionTypeId'] = this.permissionTypeId;
    data['PermissionType'] = this.permissionType;
    data['PermissionTypeTranslate'] = this.permissionTypeTranslate;
    return data;
  }
}
