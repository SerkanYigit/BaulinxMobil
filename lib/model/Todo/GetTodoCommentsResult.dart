class GetTodoCommentsResult {
  List<Comments>? result;

  GetTodoCommentsResult({this.result, required bool hasError});

  GetTodoCommentsResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <Comments>[];
      json['Result'].forEach((v) {
        result?.add(new Comments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result?.map((v) => v.toJson()).toList();
      return data;
  }
}

class Comments {
  int? id;
  int? todoId;
  int? userId;
  String? comment;
  int? relatedCommentId;
  String? audioUrl;
  List<RelatedCommentList>? relatedCommentList;
  String? createDate;
  String? userName;
  String? userPhoto;
  List<FileList>? fileList;

  Comments(
      {this.id,
      this.todoId,
      this.userId,
      this.comment,
      this.relatedCommentId,
      this.audioUrl,
      this.relatedCommentList,
      this.createDate,
      this.userName,
      this.userPhoto,
      this.fileList});

  Comments.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    todoId = json['TodoId'];
    userId = json['UserId'];
    comment = json['Comment'];
    relatedCommentId = json['RelatedCommentId'];
    audioUrl = json['AudioUrl'];
    if (json['RelatedCommentList'] != null) {
      relatedCommentList = <RelatedCommentList>[];
      json['RelatedCommentList'].forEach((v) {
        relatedCommentList!.add(new RelatedCommentList.fromJson(v));
      });
    }
    createDate = json['CreateDate'];
    userName = json['UserName'];
    userPhoto = json['UserPhoto'];
    if (json['FileList'] != null) {
      fileList = <FileList>[];
      json['FileList'].forEach((v) {
        fileList!.add(new FileList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['TodoId'] = this.todoId;
    data['UserId'] = this.userId;
    data['Comment'] = this.comment;
    data['RelatedCommentId'] = this.relatedCommentId;
    data['AudioUrl'] = this.audioUrl;
    data['RelatedCommentList'] =
        this.relatedCommentList!.map((v) => v.toJson()).toList();
      data['CreateDate'] = this.createDate;
    data['UserName'] = this.userName;
    data['UserPhoto'] = this.userPhoto;
    data['FileList'] = this.fileList!.map((v) => v.toJson()).toList();
      return data;
  }
}

class RelatedCommentList {
  int? id;
  int? todoId;
  int? userId;
  String? comment;
  String? audioUrl;
  String? createDate;
  String? userName;
  String? userPhoto;
  List<FileList>? fileList;

  RelatedCommentList(
      {this.id,
      this.todoId,
      this.userId,
      this.comment,
      this.audioUrl,
      this.createDate,
      this.userName,
      this.userPhoto,
      this.fileList});

  RelatedCommentList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    todoId = json['TodoId'];
    userId = json['UserId'];
    comment = json['Comment'];
    audioUrl = json['AudioUrl'];
    createDate = json['CreateDate'];
    userName = json['UserName'];
    userPhoto = json['UserPhoto'];
    if (json['FileList'] != null) {
      fileList = <FileList>[];
      json['FileList'].forEach((v) {
        fileList!.add(new FileList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['TodoId'] = this.todoId;
    data['UserId'] = this.userId;
    data['Comment'] = this.comment;
    data['AudioUrl'] = this.audioUrl;
    data['CreateDate'] = this.createDate;
    data['UserName'] = this.userName;
    data['UserPhoto'] = this.userPhoto;
    data['FileList'] = this.fileList!.map((v) => v.toJson()).toList();
      return data;
  }
}

class FileList {
  int? id;
  int? ownerId;
  Null ocrStatus;
  String? fileName;
  String? path;
  String? extension;
  Null ocrResult;
  Null ocrDate;
  int? moduleType;
  int? userId;
  String? createDate;
  int? customerId;
  Null ocrStatusText;
  String? thumbnailPath;

  FileList(
      {this.id,
      this.ownerId,
      this.ocrStatus,
      this.fileName,
      this.path,
      this.extension,
      this.ocrResult,
      this.ocrDate,
      this.moduleType,
      this.userId,
      this.createDate,
      this.customerId,
      this.ocrStatusText,
      this.thumbnailPath});

  FileList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    ownerId = json['OwnerId'];
    ocrStatus = json['OcrStatus'];
    fileName = json['FileName'];
    path = json['Path'];
    extension = json['Extension'];
    ocrResult = json['OcrResult'];
    ocrDate = json['OcrDate'];
    moduleType = json['ModuleType'];
    userId = json['UserId'];
    createDate = json['CreateDate'];
    customerId = json['CustomerId'];
    ocrStatusText = json['OcrStatusText'];
    thumbnailPath = json['ThumbnailPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['OwnerId'] = this.ownerId;
    data['OcrStatus'] = this.ocrStatus;
    data['FileName'] = this.fileName;
    data['Path'] = this.path;
    data['Extension'] = this.extension;
    data['OcrResult'] = this.ocrResult;
    data['OcrDate'] = this.ocrDate;
    data['ModuleType'] = this.moduleType;
    data['UserId'] = this.userId;
    data['CreateDate'] = this.createDate;
    data['CustomerId'] = this.customerId;
    data['OcrStatusText'] = this.ocrStatusText;
    data['ThumbnailPath'] = this.thumbnailPath;
    return data;
  }
}
