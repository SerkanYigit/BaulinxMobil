class AddCalendarAppointmentResult {
  Result? result;

  AddCalendarAppointmentResult({this.result, required bool hasError});

  AddCalendarAppointmentResult.fromJson(Map<String, dynamic> json) {
    result =
        json['Result'] != null ? new Result.fromJson(json['Result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.toJson();
      return data;
  }
}

class Result {
  int? id;
  int? userId;
  int? calendarId;
  String? type;
  String? startDate;
  String? endDate;
  bool? allDay;
  bool? isPrivate;
  String? subject;
  String? location;
  String? description;
  int? status;
  int? label;
  int? resourceID;
  String? reminderInfo;
  String? recurrenceInfo;
  String? color;
  String? remindDate;

  Result(
      {this.id,
      this.userId,
      this.calendarId,
      this.type,
      this.startDate,
      this.endDate,
      this.allDay,
      this.subject,
      this.location,
      this.description,
      this.status,
      this.label,
      this.resourceID,
      this.reminderInfo,
      this.recurrenceInfo,
      this.color,
      this.remindDate,
      this.isPrivate});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    userId = json['UserId'];
    calendarId = json['CalendarId'];
    type = json['Type'];
    startDate = json['StartDate'];
    endDate = json['EndDate'];
    allDay = json['AllDay'];
    subject = json['Subject'];
    location = json['Location'];
    description = json['Description'];
    status = json['Status'];
    label = json['Label'];
    resourceID = json['ResourceID'];
    reminderInfo = json['ReminderInfo'];
    recurrenceInfo = json['RecurrenceInfo'];
    color = json['Color'];
    remindDate = json['RemindDate'];
    isPrivate = json['IsPrivate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['UserId'] = this.userId;
    data['CalendarId'] = this.calendarId;
    data['Type'] = this.type;
    data['StartDate'] = this.startDate;
    data['EndDate'] = this.endDate;
    data['AllDay'] = this.allDay;
    data['Subject'] = this.subject;
    data['Location'] = this.location;
    data['Description'] = this.description;
    data['Status'] = this.status;
    data['Label'] = this.label;
    data['ResourceID'] = this.resourceID;
    data['ReminderInfo'] = this.reminderInfo;
    data['RecurrenceInfo'] = this.recurrenceInfo;
    data['Color'] = this.color;
    data['RemindDate'] = this.remindDate;
    data['IsPrivate'] = this.isPrivate;
    return data;
  }
}
