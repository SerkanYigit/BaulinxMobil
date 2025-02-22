class UserData {
  int? id;
  int? customerId;
  String? mailAddress;
  String? phone;
  String? name;
  String? surname;
  String? photo;
  String? address;
  String? userType;
  int? userTypeId;
  int? administrationId;
  String? language;
  UserCustomers? userCustomers;
  Null lessonList;
  Null permissions;
  bool? isSuccess;
  int? totalCount;
  int? orderId;
  UserData(
      {this.id,
      this.customerId,
      this.mailAddress,
      this.phone,
      this.name,
      this.surname,
      this.photo,
      this.address,
      this.userType,
      this.userTypeId,
      this.administrationId,
      this.language,
      this.userCustomers,
      this.lessonList,
      this.permissions,
      this.isSuccess,
      this.totalCount,
      this.orderId});

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    customerId = json['CustomerId'];
    mailAddress = json['MailAddress'];
    phone = json['PhoneNumber'];
    name = json['Name'];
    surname = json['Surname'];
    photo = json['Photo'];
    address = json['Address'];
    userType = json['UserType'];
    userTypeId = json['UserTypeId'];
    administrationId = json['AdministrationId'];
    language = json['Language'];
    userCustomers = json['UserCustomers'] != null
        ? new UserCustomers.fromJson(json['UserCustomers'])
        : null;
    lessonList = json['LessonList'];
    permissions = json['Permissions'];
    isSuccess = json['IsSuccess'];
    totalCount = json['TotalCount'];
    orderId = json['OrderId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CustomerId'] = this.customerId;
    data['MailAddress'] = this.mailAddress;
    data['Phone'] = this.phone;
    data['Name'] = this.name;
    data['Surname'] = this.surname;
    data['Photo'] = this.photo;
    data['Address'] = this.address;
    data['UserType'] = this.userType;
    data['UserTypeId'] = this.userTypeId;
    data['AdministrationId'] = this.administrationId;
    data['Language'] = this.language;
    data['UserCustomers'] = this.userCustomers!.toJson();
      data['LessonList'] = this.lessonList;
    data['Permissions'] = this.permissions;
    data['IsSuccess'] = this.isSuccess;
    data['TotalCount'] = this.totalCount;
    data['OrderId'] = this.orderId;
    return data;
  }
}

class UserCustomers {
  List<UserCustomerList>? userCustomerList;
  int? totalCount;

  UserCustomers({this.userCustomerList, this.totalCount});

  UserCustomers.fromJson(Map<String, dynamic> json) {
    if (json['UserCustomerList'] != null) {
      userCustomerList = <UserCustomerList>[];
      json['UserCustomerList'].forEach((v) {
        userCustomerList!.add(new UserCustomerList.fromJson(v));
      });
    }
    totalCount = json['TotalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserCustomerList'] =
        this.userCustomerList!.map((v) => v.toJson()).toList();
      data['TotalCount'] = this.totalCount;
    return data;
  }
}

class UserCustomerList {
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

  UserCustomerList(
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

  UserCustomerList.fromJson(Map<String, dynamic> json) {
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
