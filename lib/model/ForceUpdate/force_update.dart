import 'ForceUpdateData.dart';

/// statusCode : 200
/// exceptionInfo : null
/// pageSortSearch : null
/// hasError : false
/// data : {"id":1,"appType":1,"version":"1.0.0","forceUpdate":1,"osType":1,"message":"INIT Uygulamanın Güncellemesi Zorunlu","updateDate":"2021-08-31T00:00:00","isCancel":0,"reasonId":1,"reason":"Genel Yazılım Güncellemesi","reasonMessage":"","cancelReasonId":0,"cancelReason":"","cancelReasonMessage":"","userId":0}

class ForceUpdate {
  int? statusCode;
  dynamic exceptionInfo;
  dynamic pageSortSearch;
  bool? hasError;
  ForceUpdateData? data;

  ForceUpdate({
      this.statusCode, 
      this.exceptionInfo, 
      this.pageSortSearch, 
      this.hasError, 
      this.data});

  ForceUpdate.fromJson(dynamic json) {
    statusCode = json["statusCode"];
    exceptionInfo = json["exceptionInfo"];
    pageSortSearch = json["pageSortSearch"];
    hasError = json["hasError"];
    data = json["data"] != null ? ForceUpdateData.fromJson(json["data"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["statusCode"] = statusCode;
    map["exceptionInfo"] = exceptionInfo;
    map["pageSortSearch"] = pageSortSearch;
    map["hasError"] = hasError;
    map["data"] = data!.toJson();
      return map;
  }

}