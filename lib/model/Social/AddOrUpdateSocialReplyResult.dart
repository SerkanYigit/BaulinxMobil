class AddOrUpdateSocialReplyResult {
  Result? result;

  AddOrUpdateSocialReplyResult({this.result, required bool hasError});

  AddOrUpdateSocialReplyResult.fromJson(Map<String, dynamic> json) {
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
  int? socialId;
  int? userId;
  String? createDate;
  String? feed;

  Result({this.id, this.socialId, this.userId, this.createDate, this.feed});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    socialId = json['SocialId'];
    userId = json['UserId'];
    createDate = json['CreateDate'];
    feed = json['Feed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SocialId'] = this.socialId;
    data['UserId'] = this.userId;
    data['CreateDate'] = this.createDate;
    data['Feed'] = this.feed;
    return data;
  }
}
