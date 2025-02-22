import 'package:undede/model/User/UserData.dart';
import 'package:intl/intl.dart';

class Comment {
  int? statusCode;
  Null exceptionInfo;
  Null pageSortSearch;
  bool? hasError;
  List<CommentData>? data;

  Comment(
      {this.statusCode,
        this.exceptionInfo,
        this.pageSortSearch,
        this.hasError,
        this.data});

  Comment.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    exceptionInfo = json['exceptionInfo'];
    pageSortSearch = json['pageSortSearch'];
    hasError = json['hasError'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new CommentData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['exceptionInfo'] = this.exceptionInfo;
    data['pageSortSearch'] = this.pageSortSearch;
    data['hasError'] = this.hasError;
    data['data'] = this.data!.map((v) => v.toJson()).toList();
      return data;
  }
}



class CommentData {
  int? id;
  int? userId;
  int? officeId;
  int? star;
  String? message;
  String? createDate;
  DateTime? createDateDateTime;
  UserData? senderUser;

  CommentData(
      {this.id,
        this.userId,
        this.officeId,
        this.star,
        this.message,
        this.createDate,
        this.senderUser});

  CommentData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    officeId = json['officeId'];
    star = json['star'];
    message = json['message'];
    createDate = json['createDate'];
    DateFormat format = DateFormat("yyyy-MM-ddThh:mm:ss");
    createDateDateTime = format.parse(json['createDate']);
    senderUser = json['senderUser'] != null
        ? new UserData.fromJson(json['senderUser'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['officeId'] = this.officeId;
    data['star'] = this.star;
    data['message'] = this.message;
    data['createDate'] = this.createDate;
    data['senderUser'] = this.senderUser!.toJson();
      return data;
  }
}