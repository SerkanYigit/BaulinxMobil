import 'package:undede/model/Common/DataLayoutAPI.dart';

class GetAccountTypeListResult extends DataLayoutAPI {
  List<AccountType>? result;

  GetAccountTypeListResult(
      {this.result, required bool hasError});

  GetAccountTypeListResult.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    if (json['Result'] != null) {
      result = <AccountType>[];
      json['Result'].forEach((v) {
        result!.add(new AccountType.fromJson(v));
      });
    }
    header = json['Header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Version'] = this.version;
    data['HasError'] = this.hasError;
    data['ResultCode'] = this.resultCode;
    data['ResultMessage'] = this.resultMessage;
    data['AuthenticationToken'] = this.authenticationToken;
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      data['Header'] = this.header;
    return data;
  }
}

class AccountType {
  int? id;
  String? description;
  int? accountNumber;

  AccountType({this.id, this.description, this.accountNumber});

  AccountType.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    description = json['Description'];
    accountNumber = json['AccountNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Description'] = this.description;
    data['AccountNumber'] = this.accountNumber;
    return data;
  }
}