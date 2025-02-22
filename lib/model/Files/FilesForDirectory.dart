import 'package:intl/intl.dart';

class FilesForDirectory {
  String? version;
  bool? hasError;
  String? resultCode;
  String? resultMessage;
  String? authenticationToken;
  FilesForDirectoryData? result;
  Null header;

  FilesForDirectory(
      {this.version,
      this.hasError,
      this.resultCode,
      this.resultMessage,
      this.authenticationToken,
      this.result,
      this.header});

  FilesForDirectory.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    result = json['Result'] != null
        ? new FilesForDirectoryData.fromJson(json['Result'])
        : null;
    header = json['Header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Version'] = this.version;
    data['HasError'] = this.hasError;
    data['ResultCode'] = this.resultCode;
    data['ResultMessage'] = this.resultMessage;
    data['AuthenticationToken'] = this.authenticationToken;
    data['Result'] = this.result!.toJson();
      data['Header'] = this.header;
    return data;
  }
}

class FilesResponse {
  String? version;
  bool? hasError;
  String? resultCode;
  String? resultMessage;
  String? authenticationToken;
  Result? result;
  dynamic header;

  FilesResponse({
    this.version,
    this.hasError,
    this.resultCode,
    this.resultMessage,
    this.authenticationToken,
    this.result,
    this.header,
  });

  factory FilesResponse.fromJson(Map<String, dynamic> json) {
    return FilesResponse(
      version: json['Version'],
      hasError: json['HasError'],
      resultCode: json['ResultCode'],
      resultMessage: json['ResultMessage'],
      authenticationToken: json['AuthenticationToken'],
      result: json['Result'] != null ? Result.fromJson(json['Result']) : null,
      header: json['Header'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Version'] = version;
    data['HasError'] = hasError;
    data['ResultCode'] = resultCode;
    data['ResultMessage'] = resultMessage;
    data['AuthenticationToken'] = authenticationToken;
    data['Result'] = result!.toJson();
      data['Header'] = header;
    return data;
  }
}

class Result {
  List<DirectoryItem>? fileOCRs;
  int? totalCount;
  int? totalPage;

  Result({
    this.fileOCRs,
    this.totalCount,
    this.totalPage,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    var list = json['FileOCRs'] as List;
    List<DirectoryItem> fileOCRList =
        list.map((i) => DirectoryItem.fromJson(i)).toList();

    return Result(
      fileOCRs: fileOCRList,
      totalCount: json['TotalCount'],
      totalPage: json['TotalPage'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FileOCRs'] = fileOCRs!.map((v) => v.toJson()).toList();
      data['TotalCount'] = totalCount;
    data['TotalPage'] = totalPage;
    return data;
  }
}

class FileOCR {
  int? id;
  int? customerId;
  String? path;
  String? thumbnailUrl;
  String? fileName;
  String? extension;
  String? createDate;
  int? moduleType;
  List<LabelFolder>? labelList;
  int? ownerId;

  FileOCR({
    this.id,
    this.customerId,
    this.path,
    this.thumbnailUrl,
    this.fileName,
    this.extension,
    this.createDate,
    this.moduleType,
    this.labelList,
    this.ownerId,
  });

  factory FileOCR.fromJson(Map<String, dynamic> json) {
    var list = json['LabelList'] as List;
    List<LabelFolder> labelList =
        list.map((i) => LabelFolder.fromJson(i)).toList();

    return FileOCR(
      id: json['Id'],
      customerId: json['CustomerId'],
      path: json['Path'],
      thumbnailUrl: json['ThumbnailUrl'],
      fileName: json['FileName'],
      extension: json['Extension'],
      createDate: json['CreateDate'],
      moduleType: json['ModuleType'],
      labelList: labelList,
      ownerId: json['OwnerId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['CustomerId'] = customerId;
    data['Path'] = path;
    data['ThumbnailUrl'] = thumbnailUrl;
    data['FileName'] = fileName;
    data['Extension'] = extension;
    data['CreateDate'] = createDate;
    data['ModuleType'] = moduleType;
    data['LabelList'] = labelList!.map((v) => v.toJson()).toList();
      data['OwnerId'] = ownerId;
    return data;
  }
}

class LabelFolder {
  int? id;
  int? customerId;
  String? title;
  String? color;
  int? userId;
  String? createDate;
  int? labelCategoryId;

  LabelFolder({
    this.id,
    this.customerId,
    this.title,
    this.color,
    this.userId,
    this.createDate,
    this.labelCategoryId,
  });

  factory LabelFolder.fromJson(Map<String, dynamic> json) {
    return LabelFolder(
      id: json['Id'],
      customerId: json['CustomerId'],
      title: json['Title'],
      color: json['Color'],
      userId: json['UserId'],
      createDate: json['CreateDate'],
      labelCategoryId: json['LabelCategoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['CustomerId'] = customerId;
    data['Title'] = title;
    data['Color'] = color;
    data['UserId'] = userId;
    data['CreateDate'] = createDate;
    data['LabelCategoryId'] = labelCategoryId;
    return data;
  }
}

class FilesForDirectoryData {
  List<DirectoryItem>? result;
  int? totalCount;
  int? totalPage;
  List<Null>? permissionList;

  FilesForDirectoryData(
      {this.result, this.totalCount, this.totalPage, this.permissionList});

  FilesForDirectoryData.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <DirectoryItem>[];
      json['Result'].forEach((v) {
        result!.add(new DirectoryItem.fromJson(v));
      });
    }
    totalCount = json['TotalCount'];
    totalPage = json['TotalPage'];
    if (json['PermissionList'] != null) {
      permissionList = <Null>[];
      json['PermissionList'].forEach((v) {
        //permissionList.add(new Null.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      data['TotalCount'] = this.totalCount;
    data['TotalPage'] = this.totalPage;
    //data['PermissionList'] =this.permissionList.map((v) => v.toJson()).toList();
      return data;
  }
}

class DirectoryItem {
  String? folderName;
  int? totalFileCount;
  int? id;
  String? path;
  String? thumbnailUrl;
  String? fileName;
  String? createDate;
  DateTime? createDateTime;
  int? customerId;
  String? extension;
  int? moduleType;
  List<Label>? labelList;

  DirectoryItem(
      {this.folderName,
      this.totalFileCount,
      this.id,
      this.path,
      this.thumbnailUrl,
      this.fileName,
      this.createDate,
      this.customerId,
      this.extension,
      this.moduleType,
      this.labelList, required bool hasError});

  DirectoryItem.fromJson(Map<String, dynamic> json) {
    folderName = json['FolderName'];
    totalFileCount = json['TotalFileCount'];
    id = json['Id'];
    path = json['Path'];
    thumbnailUrl = json['ThumbnailUrl'];
    fileName = json['FileName'];
    createDate = json['CreateDate'];
    //"2021-09-10T23:15:21.217
    createDateTime = new DateFormat("yyyy-MM-ddThh:mm").parse(createDate!);
    customerId = json['CustomerId'];
    extension = json['Extension'];
    moduleType = json['ModuleType'];
    if (json['LabelList'] != null) {
      labelList = <Label>[];
      json['LabelList'].forEach((v) {
        labelList!.add(new Label.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FolderName'] = this.folderName;
    data['TotalFileCount'] = this.totalFileCount;
    data['Id'] = this.id;
    data['Path'] = this.path;
    data['ThumbnailUrl'] = this.thumbnailUrl;
    data['FileName'] = this.fileName;
    data['CreateDate'] = this.createDate;
    data['CustomerId'] = this.customerId;
    data['Extension'] = this.extension;
    data['ModuleType'] = this.moduleType;
    data['LabelList'] = this.labelList!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Label {
  int? id;
  String? title;
  String? color;

  Label({this.id, this.title, this.color});

  Label.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
    color = json['Color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Title'] = this.title;
    data['Color'] = this.color;
    return data;
  }
}
