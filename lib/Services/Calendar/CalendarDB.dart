import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:undede/Services/Calendar/CalendarBase.dart';
import 'package:undede/model/Calendar/AddCalendarAppointmentResult.dart';
import 'package:undede/model/Calendar/AddCalendarResult.dart';
import 'package:undede/model/Calendar/GetCalendarByUserIdResult.dart';
import 'package:undede/model/Calendar/GetCalendarDetailResult.dart';

import '../ServiceUrl.dart';
import 'package:get/get.dart';

class CalendarDB implements CalendarBase {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<GetCalendarByUserIdResult> GetCalendarByUserId(
      Map<String, String> header,
      {int? userId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getCalendarByUserId),
        headers: header,
        body: jsonEncode({
          "UserId": userId,
        }));

    print("req GetCalendarByUserId: " + response.body);

    if (response.body.isEmpty) {
      return GetCalendarByUserIdResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return GetCalendarByUserIdResult.fromJson(responseData);
    }
  }

  @override
  Future<GetCalendarDetailResult> GetCalendarDetail(Map<String, String> header,
      {int? UserId, int? CalendarId, int? Year, int? Month, bool? IsTodo}) async {
    var reqbody = jsonEncode({
      "UserId": UserId,
      "CalendarId": CalendarId,
      "Year": Year,
      "Month": Month,
      "IsTodo": IsTodo
    });
    var response = await http.post(Uri.parse(_serviceUrl.getCalendarDetail),
        headers: header, body: reqbody);
    log("req GetCalendarDetail" + reqbody.toString());
    log("res GetCalendarDetail" + response.body);
    if (response.body.isEmpty) {
      return GetCalendarDetailResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      GetCalendarDetailResult calendarDetailResult =
          GetCalendarDetailResult.fromJson(responseData);
      return calendarDetailResult;
    }
  }

  @override
  Future GetCalendarDetailTodo(Map<String, String> header,
      {int? UserId, int? CalendarId, int? Year, int? Month, bool? IsTodo}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getCalendarDetail),
        headers: header,
        body: jsonEncode({
          "UserId": UserId,
          "CalendarId": CalendarId,
          "Year": Year,
          "Month": Month,
          "IsTodo": IsTodo
        }));

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      GetCalendarDetailResult calendarDetailResult =
          GetCalendarDetailResult.fromJson(responseData);
      return calendarDetailResult.obs;
    }
  }

  @override
  Future<AddCalendarResult> AddOrUpdateCalendar(Map<String, String> header,
      {int? Id, int? UserId, String? CalanderName}) async {
    var response =
        await http.post(Uri.parse(_serviceUrl.postAddorUpdateCalendar),
            headers: header,
            body: jsonEncode({
              "Id": Id,
              "UserId": UserId,
              "CalanderName": CalanderName,
            }));

    //log("req GetAllCommons = " + response.request.url.toString());
    log("res PostAddCalendar = " + response.body);

    if (response.body.isEmpty) {
      return AddCalendarResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return AddCalendarResult.fromJson(responseData);
    }
  }

  @override
  Future<AddCalendarAppointmentResult> AddCalendarAppointment(
      Map<String, String> header,
      {int? Id,
      int? UserId,
      int? CalendarId,
      int? Type,
      String? StartDate,
      String? EndDate,
      bool? AllDay,
      String? Subject,
      String? Location,
      String? Description,
      int? Status,
      int? Label,
      int? ResourceID,
      String? ReminderInfo,
      String? RecurrenceInfo,
      String? Color,
      String? RemindDate,
      bool? IsPrivate}) async {
    var body = jsonEncode({
      "Id": Id,
      "UserId": UserId,
      "CalendarId": CalendarId,
      "Type": Type,
      "StartDate": StartDate,
      "EndDate": EndDate,
      "AllDay": AllDay,
      "Subject": Subject,
      "Location": Location,
      "Description": Description,
      "Status": Status,
      "Label": Label,
      "ResourceID": ResourceID,
      "ReminderInfo": ReminderInfo,
      "RecurrenceInfo": RecurrenceInfo,
      "Color": Color,
      "RemindDate": RemindDate,
      "IsPrivate": IsPrivate
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.postAddCalendarAppointment),
        headers: header,
        body: body);

    log("req AddCalendarAppointmentResult = " + body.toString());
    log("res AddCalendarAppointmentResult = " + response.body);

    if (response.body.isEmpty) {
      return AddCalendarAppointmentResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return AddCalendarAppointmentResult.fromJson(responseData);
    }
  }

  @override
  Future DeleteCalendar(Map<String, String> header, int Id) async {
    var response = await http.post(
        Uri.parse(_serviceUrl.deleteCalendar + Id.toString()),
        headers: header);

    //log("req GetAllCommons = " + response.request.url.toString());
    log("res deleteCalendar = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future DeleteCalendarAppointment(Map<String, String> header, int Id) async {
    var response = await http.post(
        Uri.parse(_serviceUrl.deleteDeleteCalendarAppointment + Id.toString()),
        headers: header);

    log("req deleteCalendar = " + response.request!.url.toString());
    log("res deleteCalendar = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future DeleteTodoAppointment(Map<String, String> header, int Id) async {
    var response = await http.post(
        Uri.parse(_serviceUrl.deleteTodoAppointment + Id.toString()),
        headers: header);

    log("req DeleteTodoAppointment = " + response.request!.url.toString());
    log("res DeleteTodoAppointment = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future<bool> AddUserToCalendar(Map<String, String> header,
      {int? UserId,
      int? CalendarId,
      List<int>? TargetUserIdList,
      int? RoleId}) async {
    var body = jsonEncode({
      "UserId": UserId,
      "CalendarId": CalendarId,
      "TargetUserIdList": TargetUserIdList,
      "RoleId": RoleId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.addUserToCalendar),
        headers: header, body: body);

    log("req AddUserToCalendar = " + body.toString());
    log("res AddUserToCalendar = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<bool> ConfirmInviteCalendarUser(Map<String, String> header,
      {int? Id, int? UserId, bool? IsAccept, int? NotificationId}) async {
    var body = jsonEncode({
      "Id": Id,
      "UserId": UserId,
      "IsAccept": IsAccept,
      "NotificationId": NotificationId,
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.confirmInviteCalendarUser),
        headers: header,
        body: body);

    log("req ConfirmInviteCalendarUser = " + body.toString());
    log("res ConfirmInviteCalendarUser = " + response.body);
    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }
}
