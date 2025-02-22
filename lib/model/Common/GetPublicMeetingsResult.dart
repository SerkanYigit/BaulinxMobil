import 'package:undede/model/Common/DataLayoutAPI.dart';

class GetPublicMeetingsResult extends DataLayoutAPI {
  Result? result;

  GetPublicMeetingsResult({this.result, required bool hasError});

  GetPublicMeetingsResult.fromJson(Map<String, dynamic> json) {
    result =
        json['Result'] != null ? new Result.fromJson(json['Result']) : null;

    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    header = json['Header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.toJson();
      return data;
  }
}

class Result {
  List<PublicBoardListItem>? publicBoardList;
  int? totalPage;
  int? totalCount;

  Result({this.publicBoardList, this.totalPage, this.totalCount});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['PublicBoardList'] != null) {
      publicBoardList = <PublicBoardListItem>[];
      json['PublicBoardList'].forEach((v) {
        publicBoardList!.add(new PublicBoardListItem.fromJson(v));
      });
    }
    totalPage = json['TotalPage'];
    totalCount = json['TotalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PublicBoardList'] =
        this.publicBoardList!.map((v) => v.toJson()).toList();
      data['TotalPage'] = this.totalPage;
    data['TotalCount'] = this.totalCount;
    return data;
  }
}

class PublicBoardListItem {
  int? id;
  String? title;
  String? description;
  String? photo;
  int? userId;
  String? publicCategoryName;
  bool? isFavorite;
  bool? isLike;
  bool? isOnline;
  int? likeCount;

  PublicBoardListItem(
      {this.id,
      this.title,
      this.description,
      this.photo,
      this.userId,
      this.publicCategoryName,
      this.isFavorite,
      this.isLike,
      this.likeCount,
      this.isOnline});

  PublicBoardListItem.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
    description = json['Description'];
    photo = json['Photo'];
    userId = json['UserId'];
    publicCategoryName = json['PublicCategoryName'];
    isFavorite = json['IsFavorite'];
    isLike = json['IsLike'];
    likeCount = json['LikeCount'];
    isOnline = json['IsOnline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Title'] = this.title;
    data['Description'] = this.description;
    data['Photo'] = this.photo;
    data['UserId'] = this.userId;
    data['PublicCategoryName'] = this.publicCategoryName;
    data['IsFavorite'] = this.isFavorite;
    data['IsLike'] = this.isLike;
    data['LikeCount'] = this.likeCount;
    data['IsOnline'] = this.isOnline;
    return data;
  }
}
