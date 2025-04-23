class GetOnlineMeetingsResult {
  List<Result>? result;

  GetOnlineMeetingsResult({this.result, required bool hasError});

  GetOnlineMeetingsResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <Result>[];
      json['Result'].forEach((v) {
        result!.add(new Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Result {
  String? meetingId;
  String? title;
  String? photo;
  String? url;
  int? ownerId;
  int? ownerType;

  Result(
      {this.meetingId,
      this.title,
      this.photo,
      this.url,
      this.ownerId,
      this.ownerType});

  Result.fromJson(Map<String, dynamic> json) {
    meetingId = json['MeetingId'];
    title = json['Title'];
    photo = json['Photo'];
    url = json['Url'];
    ownerId = json['OwnerId'];
    ownerType = json['OwnerType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MeetingId'] = this.meetingId;
    data['Title'] = this.title;
    data['Photo'] = this.photo;
    data['Url'] = this.url;
    data['OwnerId'] = this.ownerId;
    data['OwnerType'] = this.ownerType;
    return data;
  }
}
