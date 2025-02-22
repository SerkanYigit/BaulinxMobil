class GetUserEmailListResult {
  List<Result>? result;

  GetUserEmailListResult({this.result, required bool hasError});

  GetUserEmailListResult.fromJson(Map<String, dynamic> json) {
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
  int? emailTypeId;
  String? userName;
  TBEmailType? tBEmailType;

  Result(
      {this.id,
      this.userId,
      this.emailTypeId,
      this.userName,
      this.tBEmailType});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    userId = json['UserId'];
    emailTypeId = json['EmailTypeId'];
    userName = json['UserName'];
    tBEmailType = json['TB_EmailType'] != null
        ? new TBEmailType.fromJson(json['TB_EmailType'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['UserId'] = this.userId;
    data['EmailTypeId'] = this.emailTypeId;
    data['UserName'] = this.userName;
    data['TB_EmailType'] = this.tBEmailType!.toJson();
      return data;
  }
}

class TBEmailType {
  int? id;
  String? provider;
  String? server;
  int? port;
  bool? isSsl;

  TBEmailType({this.id, this.provider, this.server, this.port, this.isSsl});

  TBEmailType.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    provider = json['Provider'];
    server = json['Server'];
    port = json['Port'];
    isSsl = json['IsSsl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Provider'] = this.provider;
    data['Server'] = this.server;
    data['Port'] = this.port;
    data['IsSsl'] = this.isSsl;
    return data;
  }
}
