class SocialResult {
  List<Social>? social;

  SocialResult({this.social, required bool hasError});

  SocialResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      social = <Social>[];
      json['Result'].forEach((v) {
        social?.add(new Social.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.social!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Social {
  int? id;
  int? userId;
  String? ownerPicture;
  String? ownerName;
  int? type;
  int? commentCount;
  int? likeCount;
  String? createDate;
  String? feed;
  int? categoryId;
  String? categoryName;
  List<SocialReplies>? socialReplies;

  Social(
      {this.id,
      this.userId,
      this.ownerPicture,
      this.ownerName,
      this.type,
      this.commentCount,
      this.likeCount,
      this.createDate,
      this.feed,
      this.categoryId,
      this.categoryName,
      this.socialReplies});

  Social.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    userId = json['UserId'];
    ownerPicture = json['OwnerPicture'];
    ownerName = json['OwnerName'];
    type = json['Type'];
    commentCount = json['CommentCount'];
    likeCount = json['LikeCount'];
    createDate = json['CreateDate'];
    feed = json['Feed'];
    categoryId = json['CategoryId'];
    categoryName = json['CategoryName'];
    if (json['SocialReplies'] != null) {
      socialReplies = <SocialReplies>[];
      json['SocialReplies'].forEach((v) {
        socialReplies!.add(new SocialReplies.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['UserId'] = this.userId;
    data['OwnerPicture'] = this.ownerPicture;
    data['OwnerName'] = this.ownerName;
    data['Type'] = this.type;
    data['CommentCount'] = this.commentCount;
    data['LikeCount'] = this.likeCount;
    data['CreateDate'] = this.createDate;
    data['Feed'] = this.feed;
    data['CategoryId'] = this.categoryId;
    data['CategoryName'] = this.categoryName;
    data['SocialReplies'] =
        this.socialReplies!.map((v) => v.toJson()).toList();
      return data;
  }
}

class SocialReplies {
  int? id;
  int? socialId;
  String? ownerPicture;
  String? ownerName;
  int? userId;
  String? createDate;
  String? feed;

  SocialReplies(
      {this.id,
      this.socialId,
      this.ownerPicture,
      this.ownerName,
      this.userId,
      this.createDate,
      this.feed});

  SocialReplies.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    socialId = json['SocialId'];
    ownerPicture = json['OwnerPicture'];
    ownerName = json['OwnerName'];
    userId = json['UserId'];
    createDate = json['CreateDate'];
    feed = json['Feed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SocialId'] = this.socialId;
    data['OwnerPicture'] = this.ownerPicture;
    data['OwnerName'] = this.ownerName;
    data['UserId'] = this.userId;
    data['CreateDate'] = this.createDate;
    data['Feed'] = this.feed;
    return data;
  }
}
