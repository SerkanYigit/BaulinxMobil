import 'package:undede/model/Common/DataLayoutAPI.dart';

class GetInvoiceModel extends DataLayoutAPI {
  List<InvoiceDetail>? result;

  GetInvoiceModel({this.result});

  GetInvoiceModel.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <InvoiceDetail>[];
      json['Result'].forEach((v) {
        result!.add(new InvoiceDetail.fromJson(v));
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
      data['Version'] = this.version;
    data['HasError'] = this.hasError;
    data['ResultCode'] = this.resultCode;
    data['ResultMessage'] = this.resultMessage;
    data['AuthenticationToken'] = this.authenticationToken;
    data['Header'] = this.header;
    return data;
  }
}

class InvoiceDetail {
  int? id;
  int? userId;
  String? name;
  String? iban;  // Corrected to String to match typical IBAN format
  String? taxNumber;  // Corrected to String
  String? customerNo;
  String? registrationNumber;  // Corrected to String
  String? phoneNumber;  // Corrected to String
  String? address;  // Corrected field name
  String? mail;

  InvoiceDetail(
      {this.id,
      this.userId,
      this.address,
      this.customerNo,
      this.iban,
      this.mail,
      this.name,
      this.phoneNumber,
      this.registrationNumber,
      this.taxNumber});

  InvoiceDetail.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    userId = json['UserId'];
    address = json['Address'];  // Corrected field name
    customerNo = json['CustomerNo'];
    name = json['Name'];
    iban = json['Iban'];  // Corrected field name
    taxNumber = json['TaxNumber'];  // Corrected field name
    registrationNumber = json['RegisterationNumber'];  // Corrected field name
    phoneNumber = json['PhoneNumber'];  // Corrected field name
    mail = json['Mail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['UserId'] = this.userId;
    data['Address'] = this.address;  // Corrected field name
    data['CustomerNo'] = this.customerNo;
    data['Name'] = this.name;
    data['Iban'] = this.iban;  // Corrected field name
    data['TaxNumber'] = this.taxNumber;  // Corrected field name
    data['RegisterationNumber'] = this.registrationNumber;  // Corrected field name
    data['PhoneNumber'] = this.phoneNumber;  // Corrected field name
    data['Mail'] = this.mail;
    return data;
  }
}
