class GetGroupChatUserListResult {
  List<Result>? result;

  GetGroupChatUserListResult({this.result, required bool hasError});

  GetGroupChatUserListResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <Result>[];
      json['Result'].forEach((v) {
        result?.add(new Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result?.map((v) => v.toJson()).toList();
      return data;
  }
}

class Result {
  int? id;
  String? name;
  String? surname;
  String? mailAddress;
  String? password;
  Null confirmPassword;
  String? phoneNumber;
  String? address;
  String? photo;
  bool? state;
  bool? systemAdmin;
  String? createDate;
  bool? registerState;
  Null registerFile;
  bool? administrationAdmin;
  bool? customerAdmin;
  Null passwordResetKey;
  Null passwordResetRequestDate;
  int? administrationId;
  int? customerId;
  Null nickName;
  int? moduleType;
  bool? termsAndConditionsState;
  bool? dataProtectionState;
  Null companyName;
  int? orderId;

  Result(
      {this.id,
      this.name,
      this.surname,
      this.mailAddress,
      this.password,
      this.confirmPassword,
      this.phoneNumber,
      this.address,
      this.photo,
      this.state,
      this.systemAdmin,
      this.createDate,
      this.registerState,
      this.registerFile,
      this.administrationAdmin,
      this.customerAdmin,
      this.passwordResetKey,
      this.passwordResetRequestDate,
      this.administrationId,
      this.customerId,
      this.nickName,
      this.moduleType,
      this.termsAndConditionsState,
      this.dataProtectionState,
      this.companyName,
      this.orderId});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    surname = json['Surname'];
    mailAddress = json['MailAddress'];
    password = json['Password'];
    confirmPassword = json['ConfirmPassword'];
    phoneNumber = json['PhoneNumber'];
    address = json['Address'];
    photo = json['Photo'];
    state = json['State'];
    systemAdmin = json['SystemAdmin'];
    createDate = json['CreateDate'];
    registerState = json['RegisterState'];
    registerFile = json['RegisterFile'];
    administrationAdmin = json['AdministrationAdmin'];
    customerAdmin = json['CustomerAdmin'];
    passwordResetKey = json['PasswordResetKey'];
    passwordResetRequestDate = json['PasswordResetRequestDate'];
    administrationId = json['AdministrationId'];
    customerId = json['CustomerId'];
    nickName = json['NickName'];
    moduleType = json['ModuleType'];
    termsAndConditionsState = json['TermsAndConditionsState'];
    dataProtectionState = json['DataProtectionState'];
    companyName = json['CompanyName'];
    orderId = json['OrderId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Surname'] = this.surname;
    data['MailAddress'] = this.mailAddress;
    data['Password'] = this.password;
    data['ConfirmPassword'] = this.confirmPassword;
    data['PhoneNumber'] = this.phoneNumber;
    data['Address'] = this.address;
    data['Photo'] = this.photo;
    data['State'] = this.state;
    data['SystemAdmin'] = this.systemAdmin;
    data['CreateDate'] = this.createDate;
    data['RegisterState'] = this.registerState;
    data['RegisterFile'] = this.registerFile;
    data['AdministrationAdmin'] = this.administrationAdmin;
    data['CustomerAdmin'] = this.customerAdmin;
    data['PasswordResetKey'] = this.passwordResetKey;
    data['PasswordResetRequestDate'] = this.passwordResetRequestDate;
    data['AdministrationId'] = this.administrationId;
    data['CustomerId'] = this.customerId;
    data['NickName'] = this.nickName;
    data['ModuleType'] = this.moduleType;
    data['TermsAndConditionsState'] = this.termsAndConditionsState;
    data['DataProtectionState'] = this.dataProtectionState;
    data['CompanyName'] = this.companyName;
    data['OrderId'] = this.orderId;
    return data;
  }
}
