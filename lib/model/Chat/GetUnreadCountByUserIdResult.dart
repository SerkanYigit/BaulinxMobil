class GetUnreadCountByUserIdResult {
  Result? result;

  GetUnreadCountByUserIdResult({this.result, required bool hasError});

  GetUnreadCountByUserIdResult.fromJson(Map<String, dynamic> json) {
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
  int? unreadMessageCount;

  Result({this.unreadMessageCount});

  Result.fromJson(Map<String, dynamic> json) {
    unreadMessageCount = json['UnreadMessageCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UnreadMessageCount'] = this.unreadMessageCount;
    return data;
  }
}
