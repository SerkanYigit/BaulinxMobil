import 'package:undede/model/Common/DataLayoutAPI.dart';

class GetLabelByUserIdResult extends DataLayoutAPI {
  List<UserLabel>? result;

  GetLabelByUserIdResult({this.result, required bool hasError});

  GetLabelByUserIdResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <UserLabel>[];
      json['Result'].forEach((v) {
        result!.add(new UserLabel.fromJson(v));
      });
    }
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    header = json['Header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      return data;
  }
}

class UserLabel {
  int? id;
  int? customerId;
  String? title;
  String? color;
  int? userId;
  String? createDate;

  UserLabel(
      {this.id,
      this.customerId,
      this.title,
      this.color,
      this.userId,
      this.createDate});

  UserLabel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    customerId = json['CustomerId'];
    title = json['Title'];
    color = json['Color'];
    userId = json['UserId'];
    createDate = json['CreateDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CustomerId'] = this.customerId;
    data['Title'] = this.title;
    data['Color'] = this.color;
    data['UserId'] = this.userId;
    data['CreateDate'] = this.createDate;
    return data;
  }
}
