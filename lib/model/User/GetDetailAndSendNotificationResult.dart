class GetDetailAndSendNotificationResult {
  Result? result;

  GetDetailAndSendNotificationResult({this.result, required bool hasError});

  GetDetailAndSendNotificationResult.fromJson(Map<String, dynamic> json) {
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
  bool? status;
  int? notificationCount;
  bool? notificationSent;

  Result({this.status, this.notificationCount, this.notificationSent});

  Result.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    notificationCount = json['NotificationCount'];
    notificationSent = json['NotificationSent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Status'] = this.status;
    data['NotificationCount'] = this.notificationCount;
    data['NotificationSent'] = this.notificationSent;
    return data;
  }
}
