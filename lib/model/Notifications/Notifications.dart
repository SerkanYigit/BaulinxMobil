class NotificationList {
  int? statusCode;
  Null exceptionInfo;
  Null pageSortSearch;
  bool? hasError;
  List<NotificationData>? data;

  NotificationList(
      {this.statusCode,
        this.exceptionInfo,
        this.pageSortSearch,
        this.hasError,
        this.data});

  NotificationList.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    exceptionInfo = json['exceptionInfo'];
    pageSortSearch = json['pageSortSearch'];
    hasError = json['hasError'];
    if (json['data'] != null) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data!.add(new NotificationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['exceptionInfo'] = this.exceptionInfo;
    data['pageSortSearch'] = this.pageSortSearch;
    data['hasError'] = this.hasError;
    data['data'] = this.data!.map((v) => v.toJson()).toList();
      return data;
  }
}

class NotificationData {
  int? id;
  int? userId;
  int? relativeId;
  String? title;
  String? body;
  String? imagePath;
  int? type;
  String? createDate;

  NotificationData(
      {this.id,
        this.userId,
        this.relativeId,
        this.title,
        this.body,
        this.imagePath,
        this.type,
        this.createDate});

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    relativeId = json['relativeId'];
    title = json['title'];
    body = json['body'];
    imagePath = json['imagePath'];
    type = json['type'];
    createDate = json['createDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['relativeId'] = this.relativeId;
    data['title'] = this.title;
    data['body'] = this.body;
    data['imagePath'] = this.imagePath;
    data['type'] = this.type;
    data['createDate'] = this.createDate;
    return data;
  }
}
