import 'package:intl/intl.dart';
import 'package:undede/model/Common/DataLayoutAPI.dart';

class SearchResult extends DataLayoutAPI {
  Result? result;

  SearchResult({this.result, required bool hasError});

  SearchResult.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    result =
        json['Result'] != null ? new Result.fromJson(json['Result']) : null;
    header = json['Header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Version'] = this.version;
    data['HasError'] = this.hasError;
    data['ResultCode'] = this.resultCode;
    data['ResultMessage'] = this.resultMessage;
    data['AuthenticationToken'] = this.authenticationToken;
    data['Result'] = this.result!.toJson();
      data['Header'] = this.header;
    return data;
  }
}

class Result {
  List<SearchResultItem>? result = [];
  int? totalCount;
  int? totalPage;

  Result({this.result, this.totalCount, this.totalPage});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['FileOCRs'] != null) {
      result = <SearchResultItem>[];
      json['FileOCRs'].forEach((v) {
        result!.add(new SearchResultItem.fromJson(v));
      });
    }
    totalCount = json['TotalCount'];
    totalPage = json['TotalPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileOCRs'] = this.result!.map((v) => v.toJson()).toList();
      data['TotalCount'] = this.totalCount;
    data['TotalPage'] = this.totalPage;
    return data;
  }
}

class SearchResultItem {
  int? id;
  String? path;
  String? thumbnailUrl;
  String? fileName;
  String? createDate;
  DateTime? createDateTime;
  int? customerId;
  String? extension;
  int? moduleType;
  int? ownerId;
  List<LabelList>? labelList;

  SearchResultItem(
      {this.id,
      this.path,
      this.thumbnailUrl,
      this.fileName,
      this.createDate,
      this.customerId,
      this.extension,
      this.moduleType,
      this.labelList,
      this.ownerId});

  SearchResultItem.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    path = json['Path'];
    thumbnailUrl = json['ThumbnailUrl'];
    fileName = json['FileName'];
    createDate = json['CreateDate'];
    DateFormat format = DateFormat("yyyy-MM-ddThh:mm:ss");
    createDateTime = format.parse(createDate!);
    customerId = json['CustomerId'];
    extension = json['Extension'];
    moduleType = json['ModuleType'];
    ownerId = json['OwnerId'];
    if (json['LabelList'] != null) {
      labelList = <LabelList>[];
      json['LabelList'].forEach((v) {
        labelList!.add(new LabelList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Path'] = this.path;
    data['ThumbnailUrl'] = this.thumbnailUrl;
    data['FileName'] = this.fileName;
    data['CreateDate'] = this.createDate;
    data['CustomerId'] = this.customerId;
    data['Extension'] = this.extension;
    data['ModuleType'] = this.moduleType;
    data['OwnerId'] = this.ownerId;
    data['LabelList'] = this.labelList!.map((v) => v.toJson()).toList();
  
    return data;
  }
}

class LabelList {
  int? id;
  String? title;
  String? color;

  LabelList({this.id, this.title, this.color});

  LabelList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
    color = json['Color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Title'] = this.title;
    data['Color'] = this.color;
    return data;
  }
}
