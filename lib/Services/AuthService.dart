import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:undede/Services/ServiceUrl.dart';
import 'package:undede/model/Adress/Adress.dart';
import 'package:undede/model/CityServiceCountry/CityServiceCountry.dart';
import 'package:undede/model/Comment/Comment.dart';
import 'package:undede/model/ForceUpdate/ForceUpdateData.dart';
import 'package:undede/model/ForceUpdate/force_update.dart';
import 'package:undede/model/Notifications/Notifications.dart';
import 'package:path/path.dart';
import 'package:undede/model/User/AddTempUserModel.dart';
import 'package:undede/model/User/User.dart';

class AuthService {
  final Map<String, String> headers = {
    "content-type": "application/json",
    "accept": "application/json",
  };
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final ServiceUrl _serviceUrl = ServiceUrl();

  AuthService();

  Future signIn({String? mail, String? password, String? langCode}) async {
    String _token;
    try {
      _token = await FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      print('errorr :: ' + e.toString());
      _token = "";
    }

    var postValue = {
      "Email": mail,
      "Password": password,
      "FCMToken": _token,
      "Language": langCode,
      "DeviceType": 2,
    };

    var response = await http.post(Uri.parse(_serviceUrl.login),
        headers: headers, body: jsonEncode(postValue));

    log("Usseerrr= " + response.body);
    var responseData;
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
      User user = User.fromJson(responseData);
      /*log("tokenn = " + _token);
      await http.post(Uri.parse(_serviceUrl.setUserToken),
          body: jsonEncode({'token': _token, 'deviceType': 1}),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            //"Authorization": "Bearer " + user.data.token
          });*/

      return user.obs;
    } catch (e, stacktrace) {
      print("sign in hata = " + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
      return responseData['ResultMessage'];
    }
  }

  Future<dynamic> signUp(
      {String? mail,
      String? password,
      String? firstName,
      String? lastName,
      int? regType,
      String? title,
      String? LangCode}) async {
    var postValue = {
      "Name": firstName,
      "Surname": lastName,
      "Mailaddress": mail,
      "Password": password,
      "DeviceId": '',
      "FCMToken": '',
      "CreateDate": new DateTime.now().toString()
    };

    log("reqq signUp = " + jsonEncode(postValue));
    log("reqq url = " + _serviceUrl.register);

    var response = await http.post(Uri.parse(_serviceUrl.register),
        headers: headers, body: jsonEncode(postValue));
    log("resp signUp = " + response.body);
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    try {
      if (responseData['HasError'] == false) {
        return true;
      } else {
        return responseData['ResultMessage'];
      }
    } catch (e) {
      return responseData['ResultMessage'];
    }
  }

  Future<AddTempUserModel> AddTempUser(
      {String? Name, String? Surname, String? MailAddress}) async {
    var postValue = jsonEncode({
      "Name": Name,
      "Surname": Surname,
      "MailAddress": MailAddress,
    });

    var response = await http.post(
      Uri.parse(_serviceUrl.addTempUser),
      body: postValue,
      headers: headers,
    );
    log("req AddTempUser : " + postValue);
    log("res AddTempUser : " + response.body);
    var responseData = jsonDecode(response.body) as Map<String, dynamic>;
    return AddTempUserModel.fromJson(responseData);
  }

  Future<bool> VerificationCheck(
      {String? VerificationCode, int? TempUserId}) async {
    var postValue = jsonEncode({
      "VerificationCode": VerificationCode,
      "TempUserId": TempUserId,
    });

    var response = await http.post(
      Uri.parse(_serviceUrl.verificationCheck),
      body: postValue,
      headers: headers,
    );

    var responseData = jsonDecode(response.body) as Map<String, dynamic>;
    log("req VerificationCheck : " + postValue);
    log("res VerificationCheck : " + response.body);
    return responseData["Result"];
  }

  Future UserProfileUpdate(Map<String, String> header,
      {int? userId,
      String? Name,
      String? Surname,
      String? MailAddress,
      String? PhoneNumber,
      String? Address,
      String? Photo}) async {
    var postValue = jsonEncode({
      "UserId": userId,
      "Name": Name,
      "Surname": Surname,
      "MailAddress": MailAddress,
      "PhoneNumber": PhoneNumber,
      "Address": Address,
      "Photo": Photo
    });
    var response = await http.post(Uri.parse(_serviceUrl.userProfilUpdate),
        headers: header, body: postValue);

    log("UserProfilUpdate = " + postValue);

    log("UserProfilUpdate = " + response.body);
    var responseData;
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
      User user = User.fromJson(responseData);
      /*log("tokenn = " + _token);
      await http.post(Uri.parse(_serviceUrl.setUserToken),
          body: jsonEncode({'token': _token, 'deviceType': 1}),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            //"Authorization": "Bearer " + user.data.token
          });*/

      return user.obs;
    } catch (e, stacktrace) {
      print("sign in hata = " + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
      return responseData['ResultMessage'];
    }
  }

  Future LogOut(
    Map<String, String> header,
  ) async {
    var response =
        await http.post(Uri.parse(_serviceUrl.LogOut), headers: header);
    log("Logout = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  Future ChangeUserPassword(Map<String, String> header,
      {int? Id,
      String? MailAddress,
      String? Password,
      String? NewPassword,
      String? NewPasswordConfirmation}) async {
    var response = await http.post(Uri.parse(_serviceUrl.changeUserPassword),
        headers: header,
        body: jsonEncode({
          "Id": Id,
          "MailAddress": MailAddress,
          "Password": Password,
          "NewPassword": NewPassword,
          "NewPasswordConfirmation": NewPasswordConfirmation,
        }));

    log("ChangeUserPassword = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  changeProfilePhoto({File? file, Map<String, String>? header}) async {
    List<int> imageBytes = file!.readAsBytesSync();
    String fileName = basename(file!.path).toString();
    String content = base64Encode(imageBytes);

    var response = await http.post(Uri.parse(_serviceUrl.changeProfilePhoto),
        headers: header,
        body: jsonEncode(
            {"Directory": "", "FileContent": content, "FileName": fileName}));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    return responseData['data']['fileName'];
  }

  Future<void> logOut1(String userToken) async {
    String _token = await _firebaseMessaging.getToken() ?? "";

    await http.get(Uri.parse(_serviceUrl.deleteUserToken + "?Token=$_token"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Bearer " + userToken
        });
  }

  Future<Csc> getCountryList(Map<String, String> header) async {
    var response =
        await http.get(Uri.parse(_serviceUrl.getCountryList), headers: header);
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    return Csc.fromJson(responseData);
  }

  Future<Csc> getCityList(Map<String, String> header, int countryID) async {
    var response = await http.get(
        Uri.parse(_serviceUrl.getCityList + "?CountryId=$countryID"),
        headers: header);

    log("getCityList $countryID = " + response.body);
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    return Csc.fromJson(responseData);
  }

  getDistrictList(Map<String, String> header, List<int> id) async {
    print("getDistrictList = " + jsonEncode({"cityId": id}));
    var response = await http.post(Uri.parse(_serviceUrl.getDistrictList),
        body: jsonEncode({"cityId": id}), headers: header);
    log("ress= " + response.body);
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    return DistrictList.fromJson(responseData);
  }

  getStreetList(Map<String, String> header, List<int> id) async {
    print("getDistrictList = " + jsonEncode({"districtId": id}));
    var response = await http.post(Uri.parse(_serviceUrl.getStreetList),
        body: jsonEncode({"districtId": id}), headers: header);
    log("ress=  getStreetList" + response.body);
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    return StreetList.fromJson(responseData);
  }

  Future<Adress> getUserAdressList(Map<String, String> header, int id) async {
    print("_serviceUrl.getUserAdressList " +
        _serviceUrl.getUserAdressList +
        "?userId=$id");

    var response = await http.get(
        Uri.parse(_serviceUrl.getUserAdressList + "?userId=$id"),
        headers: header);
    log("responsee getUserAdressList = " + response.body);

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    return Adress.fromJson(responseData);
  }

  Future<AdressData> insertOrUpdateUserAdress(
      Map<String, String> header, AdressData adress) async {
    log("reqq adres ekleme = " +
        jsonEncode({
          "id": adress.id,
          "country": adress.country?.toJson(),
          "city": adress.city?.toJson(),
          "district": adress.district?.toJson(),
          "street": adress.street?.toJson(),
          "title": adress.title,
          "firstname": adress.firstname,
          "lastname": adress.lastname,
          "description": adress.description,
          "phoneNumber": adress.phoneNumber,
          "latitude": adress.latitude,
          "longitude": adress.longitude,
          "isDeleted": adress.isDeleted
        }));

    var response =
        await http.post(Uri.parse(_serviceUrl.insertOrUpdateUserAdress),
            headers: header,
            body: jsonEncode({
              "id": adress.id,
              "country": adress.country?.toJson(),
              "city": adress.city?.toJson(),
              "district": adress.district?.toJson(),
              "street": adress.street?.toJson(),
              "title": adress.title,
              "firstname": adress.firstname,
              "lastname": adress.lastname,
              "description": adress.description,
              "phoneNumber": adress.phoneNumber,
              "latitude": adress.latitude,
              "longitude": adress.longitude,
              "isDeleted": adress.isDeleted
            }) //jsonEncode(adress.toJson())
            );

    log("responsee insertOrUpdateUserAdress = " + response.body);
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    return AdressData.fromJson(responseData['data']);
  }

  Future<CommentData> insertComment(Map<String, String> header,
      {int? userId = 0,
      int? officeId = 0,
      String? message,
      int? star}) async {
    var response = await http.post(Uri.parse(_serviceUrl.insertComment),
        headers: header,
        body: jsonEncode({
          "userId": userId,
          "officeId": officeId,
          "message": message,
          "star": star
        }));

    log("responsee insertComment = " + response.body);

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    return CommentData.fromJson(responseData['data']);
  }

  Future<Comment> getComments(Map<String, String> header,
      {int userId = 0, int officeId = 0}) async {
    print("comment = " +
        _serviceUrl.getComments +
        "?UserId=$userId&OfficeId=$officeId");
    var response = await http.get(
        Uri.parse(
            _serviceUrl.getComments + "?UserId=$userId&OfficeId=$officeId"),
        headers: header);
    log("responsee getComments = " + response.body);

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    return Comment.fromJson(responseData);
  }

  Future<NotificationList> getNotificationList(
      Map<String, String> header) async {
    var response = await http.get(Uri.parse(_serviceUrl.getNotificationList),
        headers: header);
    log("responsee getNotificationList = " + response.body);

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    return NotificationList.fromJson(responseData);
  }

  Future<bool> forgotPassword(String mail, String language) async {
    var reqBody = jsonEncode({
      "Email": mail,
      "Language": language,
    });
    var response = await http.post(
      Uri.parse(_serviceUrl.forgotPassword),
      headers: headers,
      body: reqBody,
    );
//    log("req forgotPassword =" + reqBody.toString());
    //   log("res forgotPassword = " + response.body);
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    return responseData['HasError'];
  }

  Future<bool> forgotPasswordDone(
      String mail, String pin, String password) async {
    var reqBody = jsonEncode({
      "Mail": mail,
      "Pin": pin,
      "Password": password,
    });
    var response = await http.post(
      Uri.parse(_serviceUrl.forgotPasswordDone),
      headers: headers,
      body: reqBody,
    );
    //   log("req forgotPasswordDone =" + reqBody.toString());
    //  log("res forgotPasswordDone = " + response.body);
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    return responseData['HasError'];
  }

  Future<bool> forgotPasswordConfirm(
      String mail, String token, String password) async {
    var response = await http.post(Uri.parse(_serviceUrl.forgotPasswordConfirm),
        body: jsonEncode({"email": mail, "token": token, "password": password}),
        headers: headers);

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    return responseData['data'];
  }

  Future<ForceUpdateData> forceUpdateCheck(int appType, int osType) async {
    print("reqq forceUpdateCheck = " +
        _serviceUrl.forceUpdateCheck +
        "?AppType=$appType&OsType=$osType");
    var response = await http.get(
        Uri.parse(
            _serviceUrl.forceUpdateCheck + "?AppType=$appType&OsType=$osType"),
        headers: headers);

    log("responsee forceUpdateCheck = " + response.body);

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    return ForceUpdate.fromJson(responseData).data!;
  }
}
