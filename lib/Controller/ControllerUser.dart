import 'dart:async';
import 'package:get/get.dart';

import 'package:undede/Services/User/UserBase.dart';
import 'package:undede/Services/User/UserDB.dart';

import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:undede/model/User/GetAllActiveUserResult.dart';
import 'package:undede/model/User/GetCompanyTypeResult.dart';
import 'package:undede/model/User/GetConnectedCustomerResult.dart';
import 'package:undede/model/User/GetDetailAndSendNotificationResult.dart';
import 'package:undede/model/User/GetEmailTypeListResult.dart';
import 'package:undede/model/User/GetMyPersonsResult.dart';
import 'package:undede/model/User/GetUserEmailListResult.dart';
import 'package:undede/model/User/UpdatedCustomerResult.dart';

import '../model/User/GetSavedSignatureResult.dart';

class ControllerUser extends GetxController implements UserBase {
  UserDB _userDB = UserDB();
  Rx<GetUserEmailListResult?> getUserEmailData = null.obs;
  GetConnectedCustomerResult getConnectedResult = GetConnectedCustomerResult(hasError: false);
  UpdatedCustomerResult updatedCustomerResult = UpdatedCustomerResult(hasError: false);
  @override
  //! PArantez içindeki değerler eklendi. Normal de bostu.
  Future<AdminCustomerResult> GetAdminCustomer(Map<String, String> header,
      {int? userId, int? administrationId}) {
        return _userDB.GetAdminCustomer(header, userId: userId!, administrationId: administrationId!);
      }

  @override
  Future<GetUserEmailListResult> GetUserEmailList(Map<String, String> header,
      {int? UserId, int? UserEmailId}) async {
    var value = await _userDB.GetUserEmailList(header,
        UserId: UserId!, UserEmailId: UserEmailId!);
    update();
    getUserEmailData = value.obs;
    update();
    return value;
  }

  @override
  Future<GetEmailTypeListResult> GetEmailTypeList(Map<String, String> header,
      {int? UserId}) async {
    var value = await _userDB.GetEmailTypeList(header, UserId: UserId!);
    return value;
  }

  @override
  Future UpdateUserEmail(Map<String, String> header,
      {int? Id, int? UserId, int? EmailTypeId, String? UserName}) async {
    var value = await _userDB.UpdateUserEmail(header,
        Id: Id!, UserId: UserId!, EmailTypeId: EmailTypeId!, UserName: UserName!);
    return true;
  }

  @override
  Future UserEmailCreate(Map<String, String> header,
      {int? UserId, int? EmailTypeId, String? UserName, String? Password}) async {
    print('asdasadsasd' +
        '::' +
        UserId.toString() +
        '::' +
        EmailTypeId.toString() +
        '::' +
        UserName! +
        '::' +
        Password!);
    var value = await _userDB.UserEmailCreate(header,
        UserId: UserId!,
        EmailTypeId: EmailTypeId!,
        UserName: UserName,
        Password: Password);
    return true;
  }

  @override
  Future UserEmailDelete(Map<String, String> header,
      {int? Id, int? UserId}) async {
    var value = await _userDB.UserEmailDelete(
      header,
      Id: Id!,
      UserId: UserId!,
    );
    return true;
  }

  @override
  Future<GetAllActiveUserResult> GetAllActiveUser(Map<String, String> header,
      {String? search}) async {
    return await _userDB.GetAllActiveUser(header, search: search!);
  }

  @override
  Future AddUsersToAdministration(Map<String, String> header,
      {int? UserId, int? TargetUserId, int? TargetCustomerId}) async {
    return await _userDB.AddUsersToAdministration(header,
        UserId: UserId!,
        TargetUserId: TargetUserId!,
        TargetCustomerId: TargetCustomerId!);
  }

  @override
  Future AddUsersToCustomer(Map<String, String> header,
      {int? UserId, int? TargetUserId, int? TargetCustomerId}) async {
    return await _userDB.AddUsersToCustomer(header,
        UserId: UserId!,
        TargetUserId: TargetUserId!,
        TargetCustomerId: TargetCustomerId!);
  }

  @override
  Future DeleteUsersToAdministration(Map<String, String> header,
      {int? UserId, int? TargetUserId, int? TargetCustomerId}) async {
    return await _userDB.DeleteUsersToCustomer(header,
        UserId: UserId!,
        TargetUserId: TargetUserId!,
        TargetCustomerId: TargetCustomerId!);
  }

  @override
  Future DeleteUsersToCustomer(Map<String, String> header,
      {int? UserId, int? TargetUserId, int? TargetCustomerId}) async {
    return await _userDB.DeleteUsersToAdministration(header,
        UserId: UserId!,
        TargetUserId: TargetUserId!,
        TargetCustomerId: TargetCustomerId!);
  }

  @override
  Future<GetConnectedCustomerItem> AddConnectedCustomer(
      Map<String, String> header,
      {int? userId,
      int? customerId}) async {
    return await _userDB.AddConnectedCustomer(header,
        userId: userId!, customerId: customerId!);
  }

  @override
  Future<GetConnectedCustomerItem> DeleteConnectedCustomer(
      Map<String, String> header,
      {int? id}) async {
    return await _userDB.DeleteConnectedCustomer(header, id: id!);
  }

  @override
  Future<GetConnectedCustomerResult> GetConnectedCustomer(
      Map<String, String> header,
      {int? ownerUserId,
      int? userId}) async {
    update();
    getConnectedResult = await _userDB.GetConnectedCustomer(header,
        userId: userId!, ownerUserId: ownerUserId!);
    update();
    return getConnectedResult;
  }

  @override
  Future<GetMyPersonsResult> GetMyPersons(Map<String, String> header,
      {int? userId}) async {
    return await _userDB.GetMyPersons(header, userId: userId!);
  }

  @override
  Future<GetCompanyTypeResult> GetCompanyType(
      Map<String, String> header) async {
    var value = await _userDB.GetCompanyType(header);
    return value;
  }

  @override
  Future<UpdatedCustomerResult> UpdateCustomer(Map<String, String> header,
      {int? Id,
      String? Title,
      String? Description,
      String? Address,
      String? Phone,
      String? Photo,
      String? CustomerNumber,
      String? Iban,
      String? TaxNumber,
      String? CompanyNumber,
      String? Mail,
      String? CompanyDetail}) async {
    var value = await _userDB.UpdateCustomer(header,
        Id: Id!,
        Title: Title!,
        Description: Description!,
        Address: Address!,
        Phone: Phone!,
        Photo: Photo!,
        CustomerNumber: CustomerNumber!,
        Iban: Iban!,
        TaxNumber: TaxNumber!,
        CompanyNumber: CompanyNumber!,
        Mail: Mail!,
        CompanyDetail: CompanyDetail!,);
    return value;
  }

  @override
  Future<UpdatedCustomerResult> GetCustomer(Map<String, String> header,
      {int? Id}) async {
    var value = await _userDB.GetCustomer(header, Id: Id!);
    updatedCustomerResult = value;
    update();
    return value;
  }

  @override
  Future<GetDetailAndSendNotificationResult> GetDetailAndSendNotification(
      Map<String, String> header,
      {int? userId,
      String? language}) async {
    return await _userDB.GetDetailAndSendNotification(header,
        userId: userId!, language: language!);
  }

  @override
  Future<bool> SaveSignature(Map<String, String> header,
      {String? signature, int? userId}) async {
    return await _userDB.SaveSignature(header,
        signature: signature!, userId: userId!);
  }

  @override
  Future<EmailSignatureResponse> GetSavedSignature(Map<String, String> header,
      {int? userId}) async {
    return await _userDB.GetSavedSignature(header, userId: userId!);
  }
}
