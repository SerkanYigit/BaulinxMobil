class CareateOrJoinMettingResult {
  Result? result;

  CareateOrJoinMettingResult({this.result, required bool hasError});

  CareateOrJoinMettingResult.fromJson(Map<String, dynamic> json) {
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
  String? meetingUrl;
  String? meetingId;
  Result({this.meetingUrl, this.meetingId});

  Result.fromJson(Map<String, dynamic> json) {
    meetingUrl = json['MeetingUrl'];
    meetingId = json['MeetingId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MeetingUrl'] = this.meetingUrl;
    data['MeetingId'] = this.meetingId;

    return data;
  }
}
