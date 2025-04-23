import 'package:undede/model/Common/DataLayoutAPI.dart';

class GetTaxAccountListResult extends DataLayoutAPI {
  List<TaxAccount>? result;

  GetTaxAccountListResult(
      {this.result, required bool hasError});

  GetTaxAccountListResult.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    if (json['Result'] != null) {
      result = <TaxAccount>[];
      json['Result'].forEach((v) {
        result!.add(new TaxAccount.fromJson(v));
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

class TaxAccount {
  int? id;
  String? accountName;
  int? accountNumber;

  TaxAccount({this.id, this.accountName, this.accountNumber});

  TaxAccount.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    accountName = json['AccountName'];
    accountNumber = json['AccountNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['AccountName'] = this.accountName;
    data['AccountNumber'] = this.accountNumber;
    return data;
  }
}