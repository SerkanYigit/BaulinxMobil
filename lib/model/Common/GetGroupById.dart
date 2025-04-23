import 'package:undede/model/Common/DataLayoutAPI.dart';

class GetGroupById extends DataLayoutAPI {
  List<CommonGroup>? listOfCommonGroup;

  GetGroupById({this.listOfCommonGroup});

  GetGroupById.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
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
      data['Version'] = this.version;
    data['HasError'] = this.hasError;
    data['ResultCode'] = this.resultCode;
    data['ResultMessage'] = this.resultMessage;
    data['AuthenticationToken'] = this.authenticationToken;
    data['Header'] = this.header;
    return data;
  }
}

class CommonGroup {
  int? id;
  String? createDate;
  int? userId;
  String? groupName;
  int? commonCount;
  String? streetText;
  String? postalCode;
  String? cityText;
  String? stateText;
  String? groupStartDate;
  String? groupEndDate;
  int? selectedCustomerId;
  int? selectedUser;

  CommonGroup({
    this.id,
    this.createDate,
    this.userId,
    this.groupName,
    this.commonCount,
    this.streetText,
    this.postalCode,
    this.cityText,
    this.stateText,
    this.groupStartDate,
    this.groupEndDate,
    this.selectedCustomerId,
    this.selectedUser,
  });

  CommonGroup.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    createDate = json['CreateDate'];
    userId = json['UserId'];
    groupName = json['GroupName'];
    commonCount = json['CommonCount'];
    streetText = json['Street'];
    postalCode = json['PostalCode'];
    cityText = json['City'];
    stateText = json['State'];
    groupStartDate = json['StartDate'];
    groupEndDate = json['EndDate'];
    selectedCustomerId = json['CustomerId'];
    selectedUser = json['PersonnelId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CreateDate'] = this.createDate;
    data['UserId'] = this.userId;
    data['GroupName'] = this.groupName;
    data['CommonCount'] = this.commonCount;
    data['Street'] = this.streetText;
    data['PostalCode'] = this.postalCode;
    data['City'] = this.cityText;
    data['State'] = this.stateText;
    data['StartDate'] = this.groupStartDate;
    data['EndDate'] = this.groupEndDate;
    data['CustomerId'] = this.selectedCustomerId;
    data['PersonnelId'] = this.selectedUser;
    return data;
  }
}
