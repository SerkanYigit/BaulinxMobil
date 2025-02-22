import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Pages/Login/rememberMeControl.dart';
import 'package:undede/Services/AuthService.dart';
import 'package:undede/Services/Notification/NotificationDB.dart';
import 'package:undede/model/Adress/Adress.dart';
import 'package:undede/model/CityServiceCountry/CityServiceCountry.dart';
import 'package:undede/model/Comment/Comment.dart';
import 'package:undede/model/Notifications/GetNotificationListResult.dart';
import 'package:undede/model/Notifications/Notifications.dart';
import 'package:undede/model/User/AddTempUserModel.dart';

import 'package:undede/model/User/User.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

enum Login {
  SignIn,
  SignUp,
  Forgot,
  Payment,
  SignUpConfirm,
  PinCode,
  VerificationCheck
}

class ControllerDB extends GetxController {
  AuthService _authService = AuthService();
  NotificationDB _notificationDB = new NotificationDB();

  Rx<User?> user = null.obs;
  List<NotificationResponseList> notifications = [];
  int notificationReadCount = 0;
  int notificationUnreadCount = 0;
  RxString token = "".obs;
  RxBool isLoading = false.obs;
  RxBool basketUpdate = false.obs;
  String? TempName;
  String? TempSurName;
  String? TempPassword;
  String? TempEmail;
  int? TempUserId;
  Rx<IO.Socket>? socket;
  // RxBool isSignIn = true.obs;
  Rx<Login>? login = Login.SignIn.obs;

  ControllerDB() {}

  void SocketConnection() {
    socket = IO
        .io("https://websocket.bsabau.com/",
            OptionBuilder().setTransports(['websocket']).build())
        .obs;
    socket!.value.connect();

    socket!.value.onConnect((_) {
      print('connect | ${socket!.value.id}');
    });

    socket!.value.onConnectError((data) {
      print("hata = $data");
    });
    update();
  }

  updateLoginState(Login state) {
    login = state.obs;

    // isSignIn = state.obs;
    update();
  }

  Map<String, String> headers() {
    return <String, String>{
      "content-type": "application/json",
      "accept": "application/json",
      "Authorization": "Bearer " + token.value
    };
  }

  Future<String?> signUp(
      {String? mail,
      String? password,
      String? firstName,
      String? lastName,
      int? regType,
      bool? rememberMe,
      String? title,
      String? LangCode}) async {
/*      isLoading = true.obs;
      update();*/
    var value = await _authService.signUp(
      mail: mail!,
      password: password!,
      firstName: firstName!,
      lastName: lastName!,
      regType: regType!,
      title: title!,
    );
    try {
      print(value.toString());
      bool result = value;
      print("result = $result");
      if (result) {
        await signIn(
            mail: mail,
            password: password,
            rememberMe: rememberMe!,
            langCode: LangCode!);
      }
    } catch (e) {
      print("catchh = $value");

      return value;
    }
    return null;
  }

  Future signIn(
      {String? mail,
      String? password,
      bool? rememberMe,
      String? langCode,
      bool isUpdate = false}) async {
    print(
        "mail $mail , password $password, rememberME $rememberMe, langCode $langCode");

    var value = await _authService.signIn(
        mail: mail!, password: password!, langCode: langCode!);
    SocketConnection();
    try {
      user = value;
      update();
      print("usserrim = " + user.value.toString());
      token = user.value!.authenticationToken!.obs;
      print(token);
      initializeNotificationList(langCode);
      update();

      if (rememberMe!) {
        RememberMeControl.instance.setRemember("login", [mail, password]);
      }
    } catch (e) {
      print("cathe girdiii =$e");
      RememberMeControl.instance.setRemember("login", []);
      login = Login.SignIn.obs;

      return value;
    }
  }

  Future<AddTempUserModel> AddTempUser({
    String? Name,
    String? Surname,
    String? MailAddress,
  }) {
    return _authService.AddTempUser(
        Name: Name!, Surname: Surname!, MailAddress: MailAddress!);
  }

  Future<bool> VerificationCheck({String? VerificationCode, int? TempUserId}) {
    return _authService.VerificationCheck(
      VerificationCode: VerificationCode!,
      TempUserId: TempUserId!,
    );
  }

  initializeNotificationList(String lang) async {
    await getUnreadNotifications(lang, 0);
    await getReadNotifications(lang, 0);
  }

  getUnreadNotifications(String lang, int page) async {
    if (page == 0) notifications.removeWhere((e) => e.isRead == false);
    await _notificationDB.GetNotificationList(this.headers(),
            UserId: this.user.value!.result!.id,
            CustomerId: 0,
            Language: lang,
            PageIndex: page,
            isRead: false)
        .then((value) {
      if (!value.hasError!) {
        notificationUnreadCount = value.result!.count!;
        value.result!.notificationResponseList!.forEach((n) {
          n.isRead = false;
          this.notifications.add(n);
        });
      }
    });
    update();
  }

  getReadNotifications(String lang, int page) async {
    if (page == 0) notifications.removeWhere((e) => e.isRead == true);
    await _notificationDB.GetNotificationList(this.headers(),
            UserId: this.user.value!.result!.id,
            CustomerId: 0,
            Language: lang,
            PageIndex: page,
            isRead: true)
        .then((value) {
      if (!value.hasError!) {
        notificationReadCount = value.result!.count!;
        value.result!.notificationResponseList!.forEach((n) {
          n.isRead = true;
          this.notifications.add(n);
        });
      }
    });
    update();
  }

  logOut1() {
    try {
      _authService.logOut1(token.value);
      isLoading = true.obs;
      update();
      RememberMeControl.instance.setRemember("login", []);
      token = "".obs;
      user = null.obs;
      update();
    } catch (e) {
    } finally {
      isLoading = false.obs;
      update();
    }
  }

  Future LogOut(Map<String, String> headers) async {
    //vir2el için çalışıyor
    user.value!.result!.id = 0;
    update();
    return true;
  }

  Future ChangeUserPassword(Map<String, String> headers,
      {int? Id,
      String? MailAddress,
      String? Password,
      String? NewPassword,
      String? NewPasswordConfirmation}) async {
    return await _authService.ChangeUserPassword(headers,
        Id: Id!,
        MailAddress: MailAddress!,
        Password: Password!,
        NewPassword: NewPassword!,
        NewPasswordConfirmation: NewPasswordConfirmation!);
  }

  changeProfilePhoto({File? file, Map<String, String>? header}) async {
    String url =
        await _authService.changeProfilePhoto(file: file!, header: header!);
    //user.value.data.profilePhoto = _urlUsers + url;
    update();
    return url;
  }

  Future<Csc> getCountryList(Map<String, String> header) async {
    return await _authService.getCountryList(header);
  }

  Future<Csc> getCityList(Map<String, String> header, int countryID) async {
    return await _authService.getCityList(header, countryID);
  }

  Future getDistrictList(Map<String, String> header, List<int> id) async {
    return await _authService.getDistrictList(header, id);
  }

  Future getStreetList(Map<String, String> header, List<int> id) async {
    return await _authService.getStreetList(header, id);
  }

  Future<Adress> getUserAdressList(Map<String, String> header, int id) async {
    return await _authService.getUserAdressList(header, id);
  }

  Future<AdressData> insertOrUpdateUserAdress(
      Map<String, String> header, AdressData adress) async {
    return await _authService.insertOrUpdateUserAdress(header, adress);
  }

  Future<Comment> getComments(Map<String, String> header,
      {int userId = 0, int officeId = 0}) async {
    return await _authService.getComments(header,
        userId: userId, officeId: officeId);
  }

  Future<CommentData> insertComment(Map<String, String> header,
      {int userId = 0,
      int officeId = 0,
      required String message,
      required int star}) async {
    return await _authService.insertComment(header,
        message: message, star: star, officeId: officeId, userId: userId);
  }

  Future<NotificationList> getNotificationList(
    Map<String, String> header,
  ) async {
    return await _authService.getNotificationList(header);
  }

  Future<bool> forgotPassword(String mail, String language) async {
    return await _authService.forgotPassword(mail, language);
  }

  Future<bool> forgotPasswordDone(
      String mail, String pin, String password) async {
    return await _authService.forgotPasswordDone(mail, pin, password);
  }

  Future<bool> forgotPasswordConfirm(
      String mail, String token, String password) async {
    return await _authService.forgotPasswordConfirm(mail, token, password);
  }

  Future forceUpdateCheck(int appType, int osType) async {
    return await _authService.forceUpdateCheck(appType, osType);
  }

  updateUserProfile(
    Map<String, String> header, {
    int? userId,
    String? Name,
    String? Surname,
    String? MailAddress,
    String? PhoneNumber,
    String? Address,
    String? Photo,
  }) async {
    var value = await _authService.UserProfileUpdate(
      header,
      userId: userId!,
      Name: Name!,
      Surname: Surname!,
      MailAddress: MailAddress!,
      PhoneNumber: PhoneNumber!,
      Address: Address!,
      Photo: Photo!,
    );
    user = value;
    print('updateddd = ' + jsonDecode(value));
    try {
      user = value;
      print("updateddd = " + user.value!.result!.phone!);
      token = user.value!.authenticationToken!.obs;
      update();
    } catch (e) {
      print("cathe girdiii =$e");
      return value;
    }
  }
}
