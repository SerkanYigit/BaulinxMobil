import 'package:undede/model/Common/DataLayoutAPI.dart';

class AdminCustomerResult extends DataLayoutAPI {
  List<Customer>? result;

  AdminCustomerResult({this.result, required bool hasError});

  AdminCustomerResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <Customer>[];
      json['Result'].forEach((v) {
        result!.add(new Customer.fromJson(v));
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

class Customer {
  int? id;
  int? administrationId;
  String? title;
  String? languageTitle;
  String? address;
  String? description;
  String? phone;
  String? photo;
  int? status;
  int? customerAdminId;
  String? customerAdminName;
  String? customerAdminSurname;
  String? createDate;
  int? type;
  int? childCount;

  Customer(
      {this.id,
      this.administrationId,
      this.title,
      this.languageTitle,
      this.address,
      this.description,
      this.phone,
      this.photo,
      this.status,
      this.customerAdminId,
      this.customerAdminName,
      this.customerAdminSurname,
      this.createDate,
      this.type,
      this.childCount});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    administrationId = json['AdministrationId'];
    title = json['Title'];
    languageTitle = json['LanguageTitle'];
    address = json['Address'];
    description = json['Description'];
    phone = json['Phone'];
    photo = json['Photo'];
    status = json['Status'];
    customerAdminId = json['CustomerAdminId'];
    customerAdminName = json['CustomerAdminName'];
    customerAdminSurname = json['CustomerAdminSurname'];
    createDate = json['CreateDate'];
    type = json['Type'];
    childCount = json['ChildCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['AdministrationId'] = this.administrationId;
    data['Title'] = this.title;
    data['LanguageTitle'] = this.languageTitle;
    data['Address'] = this.address;
    data['Description'] = this.description;
    data['Phone'] = this.phone;
    data['Photo'] = this.photo;
    data['Status'] = this.status;
    data['CustomerAdminId'] = this.customerAdminId;
    data['CustomerAdminName'] = this.customerAdminName;
    data['CustomerAdminSurname'] = this.customerAdminSurname;
    data['CreateDate'] = this.createDate;
    data['Type'] = this.type;
    data['ChildCount'] = this.childCount;
    return data;
  }
}
