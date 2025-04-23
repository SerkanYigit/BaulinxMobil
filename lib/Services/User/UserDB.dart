import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
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
import '../ServiceUrl.dart';

import 'UserBase.dart';

class UserDB implements UserBase {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<AdminCustomerResult> GetAdminCustomer(Map<String, String> header,
      {int? userId, int? administrationId}) async {
    var body =
        jsonEncode({"UserId": userId, "AdministrationId": administrationId});
    var response = await http.post(Uri.parse(_serviceUrl.getAdminCustomer),
        headers: header, body: body);
    log("GetAdminCustomerBody" + body.toString());
    log("GetAdminCustomer = " + response.body);

    if (response.body.isEmpty) {
      return AdminCustomerResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return AdminCustomerResult.fromJson(responseData);
    }
  }

  @override
  Future<GetUserEmailListResult> GetUserEmailList(Map<String, String> header,
      {int? UserId, int? UserEmailId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getUserEmailList),
        headers: header,
        body: jsonEncode({"UserId": UserId, "UserEmailId": UserEmailId}));

    //log("GetUserEmailListResult = " + response.body);

    if (response.body.isEmpty) {
      return GetUserEmailListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetUserEmailListResult.fromJson(responseData);
    }
  }

  @override
  Future<GetEmailTypeListResult> GetEmailTypeList(Map<String, String> header,
      {int? UserId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getEmailTypeList),
        headers: header, body: jsonEncode({"UserId": UserId}));

    log("GetEmailTypeListResult = " + response.body);

    if (response.body.isEmpty) {
      return GetEmailTypeListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetEmailTypeListResult.fromJson(responseData);
    }
  }

  @override
  Future UserEmailCreate(Map<String, String> header,
      {int? UserId, int? EmailTypeId, String? UserName, String? Password}) async {
    var response = await http.post(Uri.parse(_serviceUrl.userEmailCreate),
        headers: header,
        body: jsonEncode({
          "UserId": UserId,
          "EmailTypeId": EmailTypeId,
          "UserName": UserName,
          "Password": Password
        }));

    log("UserEmailCreate = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  @override
  Future UpdateUserEmail(Map<String, String> header,
      {int? Id, int? UserId, int? EmailTypeId, String? UserName}) async {
    var response = await http.post(Uri.parse(_serviceUrl.updateUserEmail),
        headers: header,
        body: jsonEncode({
          "Id": Id,
          "UserId": UserId,
          "EmailTypeId": EmailTypeId,
          "UserName": UserName
        }));

    log("UpdateUserEmail = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  @override
  Future UserEmailDelete(Map<String, String> header,
      {int? Id, int? UserId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.userEmailDelete),
        headers: header, body: jsonEncode({"Id": Id, "UserId": UserId}));

    log("UserEmailDelete = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  @override
  Future<GetAllActiveUserResult> GetAllActiveUser(Map<String, String> header,
      {String? search}) async {
    var response = await http.get(
        Uri.parse(_serviceUrl.getAllActiveUser + "?search=$search"),
        headers: header);
    log("GetAllActiveUser : " + response.request!.url.toString());
    log("GetAllActiveUser : " + response.body);
    if (response.body.isEmpty) {
      return GetAllActiveUserResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetAllActiveUserResult.fromJson(responseData);
    }
  }

  @override
  Future AddUsersToAdministration(Map<String, String> header,
      {int? UserId, int? TargetUserId, int? TargetCustomerId}) async {
    var reqbody = jsonEncode({
      "UserId": UserId,
      "TargetUserId": TargetUserId,
      "TargetCustomerId": TargetCustomerId,
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.addUsersToAdministration),
        headers: header,
        body: reqbody);

    log("AddUsersToAdministration = " + reqbody);
    log("AddUsersToAdministration = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["Result"];
    }
  }

  @override
  Future AddUsersToCustomer(Map<String, String> header,
      {int? UserId, int? TargetUserId, int? TargetCustomerId}) async {
    var reqbody = jsonEncode({
      "UserId": UserId,
      "TargetUserId": TargetUserId,
      "TargetCustomerId": TargetCustomerId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.addUsersToCustomer),
        headers: header, body: reqbody);

    log("AddUsersToCustomer = " + reqbody);
    log("AddUsersToCustomer = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["Result"];
    }
  }

  @override
  Future DeleteUsersToAdministration(Map<String, String> header,
      {int? UserId, int? TargetUserId, int? TargetCustomerId}) async {
    var reqbody = jsonEncode({
      "UserId": UserId,
      "TargetUserId": TargetUserId,
      "TargetCustomerId": TargetCustomerId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.deleteUsersToCustomer),
        headers: header, body: reqbody);

    log("DeleteUsersToAdministration = " + reqbody);
    log("DeleteUsersToAdministration = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["Result"];
    }
  }

  @override
  Future DeleteUsersToCustomer(Map<String, String> header,
      {int? UserId, int? TargetUserId, int? TargetCustomerId}) async {
    var reqbody = jsonEncode({
      "UserId": UserId,
      "TargetUserId": TargetUserId,
      "TargetCustomerId": TargetCustomerId,
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.deleteUsersToAdministration),
        headers: header,
        body: reqbody);

    log("DeleteUsersToCustomer = " + reqbody);
    log("DeleteUsersToCustomer = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["Result"];
    }
  }

  @override
  Future<GetConnectedCustomerItem> AddConnectedCustomer(
      Map<String, String> header,
      {int? userId,
      int? customerId}) async {
    var response = await http.get(
      Uri.parse(_serviceUrl.addConnectedCustomer +
          "?userId=$userId&customerId=$customerId"),
      headers: header,
    );

    log("AddConnectedCustomer = " + response.request!.url.toString());
    log("AddConnectedCustomer = " + response.body);

    if (response.body.isEmpty) {
      return GetConnectedCustomerItem(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetConnectedCustomerItem.fromJson(responseData);
    }
  }

  @override
  Future<GetConnectedCustomerItem> DeleteConnectedCustomer(
      Map<String, String> header,
      {int? id}) async {
    var response = await http.get(
      Uri.parse(_serviceUrl.deleteConnectedCustomer + "?id=$id"),
      headers: header,
    );

    log("DeleteConnectedCustomer = " + response.request!.url.toString());
    log("DeleteConnectedCustomer = " + response.body);

    if (response.body.isEmpty) {
      return GetConnectedCustomerItem(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetConnectedCustomerItem.fromJson(responseData);
    }
  }

  @override
  Future<GetConnectedCustomerResult> GetConnectedCustomer(
      Map<String, String> header,
      {int? ownerUserId,
      int? userId}) async {
    var response = await http.get(
      Uri.parse(_serviceUrl.getConnectedCustomer +
          "?ownerUserId=$ownerUserId&userId=$userId"),
      headers: header,
    );

    log("GetConnectedCustomer = " + response.request!.url.toString());
    log("GetConnectedCustomer = " + response.body);

    if (response.body.isEmpty) {
      return GetConnectedCustomerResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetConnectedCustomerResult.fromJson(responseData);
    }
  }

  @override
  Future<GetMyPersonsResult> GetMyPersons(Map<String, String> header,
      {int? userId}) async {
    var response = await http.get(
      Uri.parse(_serviceUrl.getMyPersons + "?userId=$userId"),
      headers: header,
    );
    log("GetMyPersons = " + response.request!.url.toString());
    log("GetMyPersons = " + response.body);

    if (response.body.isEmpty) {
      return GetMyPersonsResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetMyPersonsResult.fromJson(responseData);
    }
  }

  @override
  Future<GetCompanyTypeResult> GetCompanyType(
      Map<String, String> header) async {
    var response = await http.get(
      Uri.parse(_serviceUrl.getCompanyType),
      headers: header,
    );
    log("GetCompanyType = " + response.request!.url.toString());
    log("GetCompanyType = " + response.body);

    if (response.body.isEmpty) {
      return GetCompanyTypeResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetCompanyTypeResult.fromJson(responseData);
    }
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
    var reqbody = jsonEncode({
      "Id": Id,
      "Title": Title,
      "Description": Description,
      "Address": Address,
      "Phone": Phone,
      "Photo": Photo,
      "CustomerNumber": CustomerNumber,
      "Iban": Iban,
      "TaxNumber": TaxNumber,
      "CompanyNumber": CompanyNumber,
      "Mail": Mail,
      "CompanyDetail": CompanyDetail
    });
    var response = await http.post(Uri.parse(_serviceUrl.updateCustomer),
        headers: header, body: reqbody);
    log("UpdateCustomer = " + reqbody);
    log("UpdateCustomer = " + response.body);

    if (response.body.isEmpty) {
      return UpdatedCustomerResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return UpdatedCustomerResult.fromJson(responseData);
    }
  }

  @override
  Future<UpdatedCustomerResult> GetCustomer(Map<String, String> header,
      {int? Id}) async {
    var response = await http.get(
      Uri.parse(_serviceUrl.getCustomer + "?userId=$Id"),
      headers: header,
    );
    log("GetCustomer = " + response.request!.url.toString());
    log("GetCustomer = " + response.body);

    if (response.body.isEmpty) {
      return UpdatedCustomerResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return UpdatedCustomerResult.fromJson(responseData);
    }
  }

  @override
  Future<GetDetailAndSendNotificationResult> GetDetailAndSendNotification(
      Map<String, String> header,
      {int? userId,
      String? language}) async {
    var response = await http.get(
      Uri.parse(_serviceUrl.getDetailAndSendNotification +
          "?userId=$userId&language=$language"),
      headers: header,
    );
    log("GetDetailAndSendNotificationResult = " +
        response.request!.url.toString());
    log("GetDetailAndSendNotificationResult = " + response.body);

    if (response.body.isEmpty) {
      return GetDetailAndSendNotificationResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetDetailAndSendNotificationResult.fromJson(responseData);
    }
  }

  @override
  Future<bool> SaveSignature(Map<String, String> header,
      {String? signature, int? userId}) async {
    String updatedSignature = '\n\n\n\n\n$signature';

    var response = await http.post(Uri.parse(_serviceUrl.saveSignature),
        headers: header,
        body: jsonEncode(
            {"SignatureContent": updatedSignature, "userId": userId}));

    log("SaveSignature = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<EmailSignatureResponse> GetSavedSignature(Map<String, String> header,
      {int? userId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getSignatureContent),
        headers: header, body: jsonEncode({"userId": userId}));
    log("SaveEmailSignature = " + response.body);

    if (response.body.isEmpty) {
      return EmailSignatureResponse(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return EmailSignatureResponse.fromJson(responseData);
    }
  }
}
