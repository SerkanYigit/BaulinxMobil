import 'package:undede/model/Common/DataLayoutAPI.dart';

class GetCommonUserListResult extends DataLayoutAPI {
  List<CommonUser>? result;

  GetCommonUserListResult({this.result, required bool hasError});

  GetCommonUserListResult.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    header = json['Header'];
    if (json['Result'] != null) {
      result = <CommonUser>[];
      json['Result'].forEach((v) {
        result!.add(new CommonUser.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      return data;
  }
}

class CommonUser {
  int? id;
  String? name;
  String? surname;
  List<UserRules>? userRules;
  String? photo;

  CommonUser({this.id, this.name, this.surname, this.userRules, this.photo});

  CommonUser.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    surname = json['Surname'];
    if (json['UserRules'] != null) {
      userRules = <UserRules>[];
      json['UserRules'].forEach((v) {
        userRules!.add(new UserRules.fromJson(v));
      });
    }
    photo = json['Photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Surname'] = this.surname;
    data['UserRules'] = this.userRules!.map((v) => v.toJson()).toList();
      data['Photo'] = this.photo;
    return data;
  }
}

class UserRules {
  int? id;
  String? title;

  UserRules({this.id, this.title});

  UserRules.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Title'] = this.title;
    return data;
  }
}
