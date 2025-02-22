import 'package:undede/model/Common/DataLayoutAPI.dart';

class GetUserListResult extends DataLayoutAPI {
  List<Result>? result;

  GetUserListResult({this.result, required bool hasError});

  GetUserListResult.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
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
  String? name;
  String? surname;
  String? photo;
  String? mail;
  int? customerId;
  bool? isMyPerson;
  String? status;
  bool? isAdministrationAdmin;
  int? chatUnreadCount;
  String? lastMessageDate;
  String? lastMessage;
  String? fullName;
  int? isGroup;
  int? isPublic;
  bool? blocked;

  Result(
      {this.id,
      this.name,
      this.surname,
      this.photo,
      this.customerId,
      this.isMyPerson,
      this.status,
      this.isAdministrationAdmin,
      this.chatUnreadCount,
      this.lastMessageDate,
      this.lastMessage,
      this.fullName,
      this.isGroup,
      this.isPublic,
      this.blocked,
      this.mail});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    surname = json['Surname'];
    photo = json['Photo'];
    customerId = json['CustomerId'];
    isMyPerson = json['IsMyPerson'];
    status = json['Status'];
    isAdministrationAdmin = json['IsAdministrationAdmin'];
    chatUnreadCount = json['ChatUnreadCount'];
    lastMessageDate = json['LastMessageDate'];
    lastMessage = json['LastMessage'];
    fullName = json['FullName'];
    isGroup = json['IsGroup'];
    isPublic = json['IsPublic'];
    blocked = json['Blocked'];
    mail = json['Mail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Surname'] = this.surname;
    data['Photo'] = this.photo;
    data['CustomerId'] = this.customerId;
    data['IsMyPerson'] = this.isMyPerson;
    data['Status'] = this.status;
    data['IsAdministrationAdmin'] = this.isAdministrationAdmin;
    data['ChatUnreadCount'] = this.chatUnreadCount;
    data['LastMessageDate'] = this.lastMessageDate;
    data['LastMessage'] = this.lastMessage;
    data['FullName'] = this.fullName;
    data['IsGroup'] = this.isGroup;
    data['IsPublic'] = this.isPublic;
    data['Blocked'] = this.blocked;
    data['Mail'] = this.mail;
    return data;
  }
}
