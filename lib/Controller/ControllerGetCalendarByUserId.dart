import 'dart:async';
import 'package:get/get.dart';
import 'package:undede/Services/Calendar/CalendarBase.dart';
import 'package:undede/Services/Calendar/CalendarDB.dart';
import 'package:undede/model/Calendar/AddCalendarAppointmentResult.dart';
import 'package:undede/model/Calendar/AddCalendarResult.dart';
import 'package:undede/model/Calendar/GetCalendarByUserIdResult.dart';
import 'package:undede/model/Calendar/GetCalendarDetailResult.dart';

class ControllerCalendar extends GetxController implements CalendarBase {
  CalendarDB _calendarDB = CalendarDB();
  Rx<GetCalendarDetailResult?> userCalendar = null.obs;
  Rx<GetCalendarDetailResult?> userCalendarTodo = null.obs;
  bool refreshCalendar = false;
  bool refreshCalendarDetail = false;

  @override
  Future<GetCalendarByUserIdResult> GetCalendarByUserId(
      Map<String, String> header,
      {int? userId}) async {
    var value = await _calendarDB.GetCalendarByUserId(
      header,
      userId: userId!,
    );
    return value;
  }

  @override
  Future<GetCalendarDetailResult> GetCalendarDetail(Map<String, String> header,
      {int? UserId, int? CalendarId, int? Year, int? Month, bool? IsTodo,}) async {
    var value = await _calendarDB.GetCalendarDetail(header,
        UserId: UserId!,
        CalendarId: CalendarId!,
        Year: Year!,
        Month: Month!,
        IsTodo: IsTodo!,);
    update();
    userCalendar = value.obs;
    update();
    return value;
  }

  @override
  Future GetCalendarDetailTodo(Map<String, String> header,
      {int? UserId, int? CalendarId, int? Year, int? Month, bool? IsTodo,}) async {
    var value = await _calendarDB.GetCalendarDetail(header,
        UserId: UserId!,
        CalendarId: CalendarId!,
        Year: Year!,
        Month: Month!,
        IsTodo: IsTodo!,);
    userCalendarTodo = value.obs;
    return value;
  }

  @override
  Future<AddCalendarResult> AddOrUpdateCalendar(Map<String, String> header,
      {int? Id, int? UserId, String? CalanderName,}) async {
    return await _calendarDB.AddOrUpdateCalendar(header,
        Id: Id!, UserId: UserId!, CalanderName: CalanderName!);
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
      bool? IsPrivate,}) async {
    return await _calendarDB.AddCalendarAppointment(header,
        Id: Id!,
        UserId: UserId!,
        CalendarId: CalendarId!,
        Type: Type!,
        StartDate: StartDate!,
        EndDate: EndDate!,
        AllDay: AllDay!,
        Subject: Subject!,
        Location: Location!,
        Description: Description!,
        Status: Status!,
        Label: Label!,
        ResourceID: ResourceID!,
        ReminderInfo: ReminderInfo!,
        RecurrenceInfo: RecurrenceInfo!,
        Color: Color!,
        RemindDate: RemindDate!,
        IsPrivate: IsPrivate!,);
  }

  @override
  Future DeleteCalendar(Map<String, String> header, int Id) async {
    return await _calendarDB.DeleteCalendar(header, Id);
  }

  @override
  Future DeleteCalendarAppointment(Map<String, String> header, int Id) async {
    return await _calendarDB.DeleteCalendarAppointment(header, Id);
  }

  @override
  Future DeleteTodoAppointment(Map<String, String> header, int Id) async {
    return await _calendarDB.DeleteTodoAppointment(header, Id);
  }

  @override
  Future<bool> AddUserToCalendar(Map<String, String> header,
      {int? UserId,
      int? CalendarId,
      List<int>? TargetUserIdList,
      int? RoleId,}) async {
    return await _calendarDB.AddUserToCalendar(header,
        UserId: UserId!,
        CalendarId: CalendarId!,
        TargetUserIdList: TargetUserIdList!,
        RoleId: RoleId!,);
  }

  @override
  Future<bool> ConfirmInviteCalendarUser(Map<String, String> header,
      {int? Id, int? UserId, bool? IsAccept, int? NotificationId,}) async {
    return await _calendarDB.ConfirmInviteCalendarUser(header,
        Id: Id!,
        UserId: UserId!,
        IsAccept: IsAccept!,
        NotificationId: NotificationId!,);
  }
}
