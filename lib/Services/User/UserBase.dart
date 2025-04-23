import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:undede/model/User/GetAllActiveUserResult.dart';
import 'package:undede/model/User/GetCompanyTypeResult.dart';
import 'package:undede/model/User/GetConnectedCustomerResult.dart';
import 'package:undede/model/User/GetDetailAndSendNotificationResult.dart';
import 'package:undede/model/User/GetEmailTypeListResult.dart';
import 'package:undede/model/User/GetMyPersonsResult.dart';
import 'package:undede/model/User/GetUserEmailListResult.dart';
import 'package:undede/model/User/UpdatedCustomerResult.dart';

import '../../model/User/GetSavedSignatureResult.dart';

abstract class UserBase {
  Future<AdminCustomerResult> GetAdminCustomer(
    Map<String, String> header, {
    int userId,
    int administrationId,
  });
  Future<GetUserEmailListResult> GetUserEmailList(
    Map<String, String> header, {
    int UserId,
    int UserEmailId,
  });
  Future<GetEmailTypeListResult> GetEmailTypeList(
    Map<String, String> header, {
    int UserId,
  });
  Future UserEmailCreate(Map<String, String> header,
      {int UserId, int EmailTypeId, String UserName});

  Future UpdateUserEmail(Map<String, String> header,
      {int Id, int UserId, int EmailTypeId, String UserName});
  Future UserEmailDelete(Map<String, String> header, {int Id, int UserId});
  Future<GetAllActiveUserResult> GetAllActiveUser(Map<String, String> header,
      {String search});
  Future AddUsersToCustomer(Map<String, String> header,
      {int UserId, int TargetUserId, int TargetCustomerId});
  Future AddUsersToAdministration(Map<String, String> header,
      {int UserId, int TargetUserId, int TargetCustomerId});
  Future DeleteUsersToCustomer(Map<String, String> header,
      {int UserId, int TargetUserId, int TargetCustomerId});
  Future DeleteUsersToAdministration(Map<String, String> header,
      {int UserId, int TargetUserId, int TargetCustomerId});
  Future<GetConnectedCustomerResult> GetConnectedCustomer(
      Map<String, String> header,
      {int ownerUserId,
      int userId});
  Future<GetConnectedCustomerItem> AddConnectedCustomer(
      Map<String, String> header,
      {int userId,
      int customerId});
  Future<GetConnectedCustomerItem> DeleteConnectedCustomer(
    Map<String, String> header, {
    int id,
  });
  Future<GetMyPersonsResult> GetMyPersons(
    Map<String, String> header, {
    int userId,
  });
  Future<UpdatedCustomerResult> UpdateCustomer(Map<String, String> header,
      {int Id,
      String Title,
      String Description,
      String Address,
      String Phone,
      String Photo,
      String CustomerNumber,
      String Iban,
      String TaxNumber,
      String CompanyNumber,
      String Mail});
  Future<GetCompanyTypeResult> GetCompanyType(
    Map<String, String> header,
  );
  Future<UpdatedCustomerResult> GetCustomer(Map<String, String> header,
      {int Id});
  Future<GetDetailAndSendNotificationResult> GetDetailAndSendNotification(
      Map<String, String> header,
      {int userId,
      String language});
  Future<bool> SaveSignature(Map<String, String> header,
      {int userId, String signature});

  Future<EmailSignatureResponse> GetSavedSignature(Map<String, String> header,
      {int userId});
}
