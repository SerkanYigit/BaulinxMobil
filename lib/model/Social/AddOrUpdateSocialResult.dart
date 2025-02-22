class AddOrUpdateSocialResult {
  Result? result;

  AddOrUpdateSocialResult({this.result, required bool hasError});

  AddOrUpdateSocialResult.fromJson(Map<String, dynamic> json) {
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
  int? categoryId;
  int? type;
  int? commentCount;
  int? likeCount;
  String? createDate;
  String? feed;

  Result(
      {this.id,
      this.userId,
      this.categoryId,
      this.type,
      this.commentCount,
      this.likeCount,
      this.createDate,
      this.feed});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    userId = json['UserId'];
    categoryId = json['CategoryId'];
    type = json['Type'];
    commentCount = json['CommentCount'];
    likeCount = json['LikeCount'];
    createDate = json['CreateDate'];
    feed = json['Feed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['UserId'] = this.userId;
    data['CategoryId'] = this.categoryId;
    data['Type'] = this.type;
    data['CommentCount'] = this.commentCount;
    data['LikeCount'] = this.likeCount;
    data['CreateDate'] = this.createDate;
    data['Feed'] = this.feed;
    return data;
  }
}
