import 'package:undede/model/Common/DataLayoutAPI.dart';

class ListOfCommonGroup extends DataLayoutAPI {
  List<CommonGroup>? listOfCommonGroup;

  ListOfCommonGroup({this.listOfCommonGroup, required bool hasError});

  ListOfCommonGroup.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null && json['Result'] is List) {
      listOfCommonGroup = <CommonGroup>[];
      json['Result'].forEach((v) {
        listOfCommonGroup!.add(new CommonGroup.fromJson(v));
      });
    } else if (json['Result'] != null && json['Result'] is Map) {
      listOfCommonGroup = <CommonGroup>[];
      listOfCommonGroup!.add(new CommonGroup.fromJson(json['Result']));
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
    data['Result'] = this.listOfCommonGroup!.map((v) => v.toJson()).toList();
      return data;
  }
}

class CommonGroup {
  int? id;
  String? createDate;
  int? userId;
  String? groupName;
  int? commonCount;
  String? street;
  String? postalCode;
  String? city;
  String? state;
  String? groupStartDate;
  String? groupEndDate;
  dynamic selectedCustomerId;
  int? selectedUser;
  dynamic projectNumber;
  dynamic personalId;
  dynamic personalName;
  dynamic customerTitle;

  CommonGroup(
      {this.id,
      this.createDate,
      this.userId,
      this.groupName,
      this.commonCount,
      this.street,
      this.postalCode,
      this.city,
      this.state,
      this.groupStartDate,
      this.groupEndDate,
      this.selectedCustomerId,
      this.selectedUser,
      this.projectNumber,
      this.personalId,
      this.personalName,
      this.customerTitle});

  CommonGroup.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    createDate = json['CreateDate'];
    userId = json['UserId'];
    groupName = json['GroupName'];
    commonCount = json['CommonCount'];
    street = json['Street'];
    postalCode = json['PostalCode'];
    city = json['City'];
    state = json['State'];
    groupStartDate = json['StartDate'];
    groupEndDate = json['EndDate'];
    selectedCustomerId = json['CustomerId'];
    selectedUser = json['SelectedUser'];
    projectNumber = json['ProjectNumber'];
    personalId = json['PersonnelId'];
    personalName = json['PersonnelName'];
    customerTitle = json['CustomerTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CreateDate'] = this.createDate;
    data['UserId'] = this.userId;
    data['GroupName'] = this.groupName;
    data['CommonCount'] = this.commonCount;
    data['Street'] = this.street;
    data['PostalCode'] = this.postalCode;
    data['City'] = this.city;
    data['State'] = this.state;
    data['StartDate'] = this.groupStartDate;
    data['EndDate'] = this.groupEndDate;
    data['CustomerId'] = this.selectedCustomerId;
    data['PersonnelId'] = this.selectedUser;
    data['CommonCount'] = this.commonCount;
    data['ProjectNumber'] = this.projectNumber;
    data['PersonalId'] = this.personalId;
    data['PersonalName'] = this.personalName;
    data['CustomerTitle'] = this.customerTitle;
    return data;
  }
}
