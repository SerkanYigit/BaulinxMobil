import 'package:intl/intl.dart';
import 'package:undede/model/Common/DataLayoutAPI.dart';

class GetNotificationListResult extends DataLayoutAPI {
  Result? result;

  GetNotificationListResult({this.result, required bool hasError});

  GetNotificationListResult.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    result = json['Result'] != null ? new Result.fromJson(json['Result']) : null;
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
  int? count;
  List<NotificationResponseList>? notificationResponseList;

  Result({this.count, this.notificationResponseList});

  Result.fromJson(Map<String, dynamic> json) {
    count = json['Count'];
    if (json['NotificationResponseList'] != null) {
      notificationResponseList = <NotificationResponseList>[];
      json['NotificationResponseList'].forEach((v) {
        notificationResponseList!.add(new NotificationResponseList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Count'] = this.count;
    data['NotificationResponseList'] =
        this.notificationResponseList!.map((v) => v.toJson()).toList();
      return data;
  }
}

class NotificationResponseList {
  int? id;
  String? text;
  String? url;
  String? createDate;
  DateTime? createDateTime;
  int? notificationTemplateType;
  int? commonId;
  int? todoId;
  List<String>? fileId;
  int? commentId;
  bool? isRead;

  NotificationResponseList(
      {this.id,
        this.text,
        this.url,
        this.createDate,
        this.notificationTemplateType,
        this.commonId,
        this.todoId,
        this.fileId,
        this.commentId,
        this.isRead});

  NotificationResponseList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    text = json['Text'];
    url = json['Url'];
    createDate = json['CreateDate'];
    createDateTime = new DateFormat("yyyy-MM-ddThh:mm").parse(createDate!);
    notificationTemplateType = json['NotificationTemplateType'];
    commonId = json['CommonId'];
    todoId = json['TodoId'];
    print(json['FileId']);
    if (json['FileId'] != null) {
      fileId = <String>[];
      json['FileId'].forEach((v) {
        fileId!.add(v);
      });
    }
    commentId = json['CommentId'];
    isRead = json['isRead'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Text'] = this.text;
    data['Url'] = this.url;
    data['CreateDate'] = this.createDate;
    data['NotificationTemplateType'] = this.notificationTemplateType;
    data['CommonId'] = this.commonId;
    data['TodoId'] = this.todoId;
    data['FileId'] = this.fileId;
    data['CommentId'] = this.commentId;
    data['IsRead'] = this.isRead;
    return data;
  }
}