class GetInviteUserListResult {
  List<Result>? result;

  GetInviteUserListResult({this.result, required bool hasError});

  GetInviteUserListResult.fromJson(Map<String, dynamic> json) {
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
  int? userId;
  String? name;
  String? photo;
  String? status;

  Result({this.id, this.userId, this.name, this.photo, this.status});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    userId = json['UserId'];
    name = json['Name'];
    photo = json['Photo'];
    status = json['Status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['UserId'] = this.userId;
    data['Name'] = this.name;
    data['Photo'] = this.photo;
    data['Status'] = this.status;
    return data;
  }
}
