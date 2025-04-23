import 'package:undede/model/Common/DataLayoutAPI.dart';

class GetInvoiceTargetAccountListResult extends DataLayoutAPI {
  List<InvoiceTargetAccount>? result;

  GetInvoiceTargetAccountListResult({this.result, required bool hasError});

  GetInvoiceTargetAccountListResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <InvoiceTargetAccount>[];
      json['Result'].forEach((v) {
        result!.add(new InvoiceTargetAccount.fromJson(v));
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

class InvoiceTargetAccount {
  int? id;
  String? name;
  int? account;

  InvoiceTargetAccount({this.id, this.name, this.account});

  InvoiceTargetAccount.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    account = json['Account'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Account'] = this.account;
    return data;
  }
}