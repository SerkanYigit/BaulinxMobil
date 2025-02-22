class GetCalendarDetailResult {
  Result? result;

  GetCalendarDetailResult({this.result, required bool hasError});

  GetCalendarDetailResult.fromJson(Map<String, dynamic> json) {
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
  int? calendarId;
  bool? isMyCalendar;
  List<UserCalendarUsers>? userCalendarUsers;
  bool? isShowTodos;
  List<CalendarEventList>? calendarEventList;

  Result(
      {this.calendarId,
      this.isMyCalendar,
      this.userCalendarUsers,
      this.isShowTodos,
      this.calendarEventList});

  Result.fromJson(Map<String, dynamic> json) {
    calendarId = json['CalendarId'];
    isMyCalendar = json['IsMyCalendar'];
    if (json['UserCalendarUsers'] != null) {
      userCalendarUsers = <UserCalendarUsers>[];
      json['UserCalendarUsers'].forEach((v) {
        userCalendarUsers!.add(new UserCalendarUsers.fromJson(v));
      });
    }
    isShowTodos = json['IsShowTodos'];
    if (json['CalendarEventList'] != null) {
      calendarEventList = <CalendarEventList>[];
      json['CalendarEventList'].forEach((v) {
        calendarEventList!.add(new CalendarEventList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CalendarId'] = this.calendarId;
    data['IsMyCalendar'] = this.isMyCalendar;
    data['UserCalendarUsers'] =
        this.userCalendarUsers!.map((v) => v.toJson()).toList();
      data['IsShowTodos'] = this.isShowTodos;
    data['CalendarEventList'] =
        this.calendarEventList!.map((v) => v.toJson()).toList();
      return data;
  }
}

class UserCalendarUsers {
  int? approved;
  int? isOwner;
  int? id;
  String? name;
  String? surname;
  String? photo;

  UserCalendarUsers(
      {this.approved,
      this.isOwner,
      this.id,
      this.name,
      this.surname,
      this.photo});

  UserCalendarUsers.fromJson(Map<String, dynamic> json) {
    approved = json['Approved'];
    isOwner = json['IsOwner'];
    id = json['Id'];
    name = json['Name'];
    surname = json['Surname'];
    photo = json['Photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Approved'] = this.approved;
    data['IsOwner'] = this.isOwner;
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Surname'] = this.surname;
    data['Photo'] = this.photo;
    return data;
  }
}

class CalendarEventList {
  String? title;
  String? start;
  String? end;
  bool? allDay;
  int? id;
  int? calendarId;
  String? description;
  String? location;
  String? color;
  // List<Null> className;
  String? type;
  // Null remindDate;
  int? commonId;
  int? userId;
  bool? special;
  bool? isPrivate;
  CalendarEventList(
      {this.title,
      this.start,
      this.end,
      this.allDay,
      this.id,
      this.calendarId,
      this.description,
      this.location,
      this.color,
      //    this.className,
      this.type,
      //  this.remindDate,
      this.commonId,
      this.userId,
      this.special,
      this.isPrivate});

  CalendarEventList.fromJson(Map<String, dynamic> json) {
    title = json['Title'];
    start = json['Start'];
    end = json['End'];
    allDay = json['AllDay'];
    id = json['Id'];
    calendarId = json['CalendarId'];
    description = json['Description'];
    location = json['Location'];
    color = json['Color'];
    /*
    if (json['className'] != null) {
      className = <Null>[];
      json['className'].forEach((v) {
        className!.add(new Null.fromJson(v));
      });
    }*/
    type = json['Type'];
    //  remindDate = json['remindDate'];
    commonId = json['CommonId'];
    userId = json['UserId'];
    special = json['Special'];
    isPrivate = json['IsPrivate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Title'] = this.title;
    data['Start'] = this.start;
    data['End'] = this.end;
    data['AllDay'] = this.allDay;
    data['Id'] = this.id;
    data['CalendarId'] = this.calendarId;
    data['Description'] = this.description;
    data['Location'] = this.location;
    data['Color'] = this.color;
    /*
    if (this.className != null) {
      data['className'] = this.className.map((v) => v.toJson()).toList();
    }*/
    data['Type'] = this.type;
    //   data['remindDate'] = this.remindDate;
    data['CommonId'] = this.commonId;
    data['UserId'] = this.userId;
    data['Special'] = this.special;
    data['IsPrivate'] = this.isPrivate;

    return data;
  }
}
