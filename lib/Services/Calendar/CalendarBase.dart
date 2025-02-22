import 'package:undede/model/Calendar/AddCalendarAppointmentResult.dart';
import 'package:undede/model/Calendar/AddCalendarResult.dart';
import 'package:undede/model/Calendar/GetCalendarByUserIdResult.dart';
import 'package:undede/model/Calendar/GetCalendarDetailResult.dart';

abstract class CalendarBase {
  Future<GetCalendarByUserIdResult> GetCalendarByUserId(
      Map<String, String> header,
      {int userId});

  Future<GetCalendarDetailResult> GetCalendarDetail(Map<String, String> header,
      {int UserId, int CalendarId, int Year, int Month, bool IsTodo});
  Future GetCalendarDetailTodo(Map<String, String> header,
      {int UserId, int CalendarId, int Year, int Month, bool IsTodo});
  Future<AddCalendarResult> AddOrUpdateCalendar(Map<String, String> header,
      {int Id, int UserId, String CalanderName});

  Future<AddCalendarAppointmentResult> AddCalendarAppointment(
      Map<String, String> header,
      {int Id,
      int UserId,
      int CalendarId,
      int Type,
      String StartDate,
      String EndDate,
      bool AllDay,
      String Subject,
      String Location,
      String Description,
      int Status,
      int Label,
      int ResourceID,
      String ReminderInfo,
      String RecurrenceInfo,
      String Color,
      String RemindDate});
  Future DeleteCalendar(Map<String, String> header, int Id);
  Future DeleteCalendarAppointment(Map<String, String> header, int Id);
  Future DeleteTodoAppointment(Map<String, String> header, int Id);
  Future<bool> AddUserToCalendar(Map<String, String> header,
      {int UserId, int CalendarId, List<int> TargetUserIdList, int RoleId});
  Future<bool> ConfirmInviteCalendarUser(Map<String, String> header,
      {int Id, int UserId, bool IsAccept, int NotificationId});
}
