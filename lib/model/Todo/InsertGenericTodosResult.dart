class InsertGenericTodosResult {
  String? version;
  bool? hasError;
  String? resultCode;
  String? resultMessage;
  Null authenticationToken;
  Result? result;
  Null header;

  InsertGenericTodosResult(
      {this.version,
      this.hasError,
      this.resultCode,
      this.resultMessage,
      this.authenticationToken,
      this.result,
      this.header});

  InsertGenericTodosResult.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    result =
        json['Result'] != null ? new Result.fromJson(json['Result']) : null;
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

class Result {
  int? id;
  int? ownerId;
  int? ownerType;
  String? content;
  int? status;
  int? userId;
  String? createDate;
  int? todoAdminId;
  String? description;
  String? startDate;
  String? endDate;
  Null remindDate;
  int? fileCount;
  int? commentCount;
  Null noteUrl;
  Null labelList;
  int? orderNumber;
  Null userList;
  Null color;
  String? backgroundImage;

  Result(
      {this.id,
      this.ownerId,
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

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    ownerId = json['OwnerId'];
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
    labelList = json['LabelList'];
    orderNumber = json['OrderNumber'];
    userList = json['UserList'];
    color = json['Color'];
    backgroundImage = json['BackgroundImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['OwnerId'] = this.ownerId;
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
    data['LabelList'] = this.labelList;
    data['OrderNumber'] = this.orderNumber;
    data['UserList'] = this.userList;
    data['Color'] = this.color;
    data['BackgroundImage'] = this.backgroundImage;
    return data;
  }
}
