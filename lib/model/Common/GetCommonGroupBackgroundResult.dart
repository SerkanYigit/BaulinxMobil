class GetCommonGroupBackgroundResult {
  List<Result>? result;

  GetCommonGroupBackgroundResult({this.result, required bool hasError});

  GetCommonGroupBackgroundResult.fromJson(Map<String, dynamic> json) {
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
  int? groupId;
  String? photo;

  Result({this.groupId, this.photo});

  Result.fromJson(Map<String, dynamic> json) {
    groupId = json['GroupId'];
    photo = json['Photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['GroupId'] = this.groupId;
    data['Photo'] = this.photo;
    return data;
  }
}
