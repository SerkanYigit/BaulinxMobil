/// id : 1
/// appType : 1
/// version : "1.0.0"
/// forceUpdate : 1
/// osType : 1
/// message : "INIT Uygulamanın Güncellemesi Zorunlu"
/// updateDate : "2021-08-31T00:00:00"
/// isCancel : 0
/// reasonId : 1
/// reason : "Genel Yazılım Güncellemesi"
/// reasonMessage : ""
/// cancelReasonId : 0
/// cancelReason : ""
/// cancelReasonMessage : ""
/// userId : 0

class ForceUpdateData {
  int? id;
  int? appType;
  String? version;
  int? forceUpdate;
  int? osType;
  String? message;
  String? updateDate;
  int? isCancel;
  int? reasonId;
  String? reason;
  String? reasonMessage;
  int? cancelReasonId;
  String? cancelReason;
  String? cancelReasonMessage;
  int? userId;
  String? versionCode;

  ForceUpdateData({
      this.id, 
      this.appType, 
      this.version, 
      this.forceUpdate, 
      this.osType, 
      this.message, 
      this.updateDate, 
      this.isCancel, 
      this.reasonId, 
      this.reason, 
      this.reasonMessage, 
      this.cancelReasonId, 
      this.cancelReason, 
      this.cancelReasonMessage, 
      this.userId,
      this.versionCode});

  ForceUpdateData.fromJson(dynamic json) {
    id = json["id"];
    appType = json["appType"];
    version = json["version"];
    forceUpdate = json["forceUpdate"];
    osType = json["osType"];
    message = json["message"];
    updateDate = json["updateDate"];
    isCancel = json["isCancel"];
    reasonId = json["reasonId"];
    reason = json["reason"];
    reasonMessage = json["reasonMessage"];
    cancelReasonId = json["cancelReasonId"];
    cancelReason = json["cancelReason"];
    cancelReasonMessage = json["cancelReasonMessage"];
    userId = json["userId"];
    versionCode = json["versionCode"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["appType"] = appType;
    map["version"] = version;
    map["forceUpdate"] = forceUpdate;
    map["osType"] = osType;
    map["message"] = message;
    map["updateDate"] = updateDate;
    map["isCancel"] = isCancel;
    map["reasonId"] = reasonId;
    map["reason"] = reason;
    map["reasonMessage"] = reasonMessage;
    map["cancelReasonId"] = cancelReasonId;
    map["cancelReason"] = cancelReason;
    map["cancelReasonMessage"] = cancelReasonMessage;
    map["userId"] = userId;
    map["versionCode"] = versionCode;
    return map;
  }

}