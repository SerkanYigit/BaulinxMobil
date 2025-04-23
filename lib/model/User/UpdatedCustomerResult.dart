class UpdatedCustomerResult {
  CompanyResult? companyResult;

  UpdatedCustomerResult({this.companyResult, required bool hasError});

  UpdatedCustomerResult.fromJson(Map<String, dynamic> json) {
    companyResult = json['Result'] != null
        ? new CompanyResult.fromJson(json['Result'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.companyResult!.toJson();
      return data;
  }
}

class CompanyResult {
  int? id;
  String? title;
  String? description;
  String? address;
  String? phone;
  String? photo;
  int? customerAdminId;
  int? createrUserId;
  String? createDate;
  int? customerHide;
  String? customerNumber;
  String? iban;
  String? taxNumber;
  String? companyNumber;
  String? mail;
  String? companyDetail;

  CompanyResult(
      {this.id,
      this.title,
      this.description,
      this.address,
      this.phone,
      this.photo,
      this.customerAdminId,
      this.createrUserId,
      this.createDate,
      this.customerHide,
      this.customerNumber,
      this.iban,
      this.taxNumber,
      this.companyNumber,
      this.mail,
      this.companyDetail});

  CompanyResult.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
    description = json['Description'];
    address = json['Address'];
    phone = json['Phone'];
    photo = json['Photo'];
    customerAdminId = json['CustomerAdminId'];
    createrUserId = json['CreaterUserId'];
    createDate = json['CreateDate'];
    customerHide = json['CustomerHide'];
    customerNumber = json['CustomerNumber'];
    iban = json['Iban'];
    taxNumber = json['TaxNumber'];
    companyNumber = json['CompanyNumber'];
    mail = json['Mail'];
    companyDetail = json['CompanyDetail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Title'] = this.title;
    data['Description'] = this.description;
    data['Address'] = this.address;
    data['Phone'] = this.phone;
    data['Photo'] = this.photo;
    data['CustomerAdminId'] = this.customerAdminId;
    data['CreaterUserId'] = this.createrUserId;
    data['CreateDate'] = this.createDate;
    data['CustomerHide'] = this.customerHide;
    data['CustomerNumber'] = this.customerNumber;
    data['Iban'] = this.iban;
    data['TaxNumber'] = this.taxNumber;
    data['CompanyNumber'] = this.companyNumber;
    data['Mail'] = this.mail;
    data['CompanyDetail'] = this.companyDetail;
    return data;
  }
}
