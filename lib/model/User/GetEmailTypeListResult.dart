class GetEmailTypeListResult {
  List<Result>? result;

  GetEmailTypeListResult({this.result, required bool hasError});

  GetEmailTypeListResult.fromJson(Map<String, dynamic> json) {
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
  String? provider;
  String? server;
  int? port;
  bool? isSsl;

  Result({this.id, this.provider, this.server, this.port, this.isSsl});

  Result.fromJson(Map<String, dynamic> json) {
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
