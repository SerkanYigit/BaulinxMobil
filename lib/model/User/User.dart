import 'package:undede/model/User/UserData.dart';

class User {
  String? version;
  bool? hasError;
  String? resultCode;
  String? resultMessage;
  String? authenticationToken;
  UserData? result;
  Null header;

  User(
      {this.version,
        this.hasError,
        this.resultCode,
        this.resultMessage,
        this.authenticationToken,
        this.result,
        this.header});

  User.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    result = UserData.fromJson(json['Result']);
    header = json['Header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Version'] = this.version;
    data['HasError'] = this.hasError;
    data['ResultCode'] = this.resultCode;
    data['ResultMessage'] = this.resultMessage;
    data['AuthenticationToken'] = this.authenticationToken;
    data['Header'] = this.header;
    data['Result'] = result!.toJson();
    return data;
  }
}