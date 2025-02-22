class GetMyPersonsResult {
  List<Result>? result;

  GetMyPersonsResult({this.result, required bool hasError});

  GetMyPersonsResult.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? administrationId;
  int? userId;
  bool? isDefault;
  String? userName;

  Result(
      {this.id,
      this.administrationId,
      this.userId,
      this.isDefault,
      this.userName});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    administrationId = json['AdministrationId'];
    userId = json['UserId'];
    isDefault = json['IsDefault'];
    userName = json['UserName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['AdministrationId'] = this.administrationId;
    data['UserId'] = this.userId;
    data['IsDefault'] = this.isDefault;
    data['UserName'] = this.userName;
    return data;
  }
}
