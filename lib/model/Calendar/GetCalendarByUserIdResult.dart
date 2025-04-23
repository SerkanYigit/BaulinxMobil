class GetCalendarByUserIdResult {
  List<Result>? result;

  GetCalendarByUserIdResult({this.result, required bool hasError});

  GetCalendarByUserIdResult.fromJson(Map<String, dynamic> json) {
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
  String? title;

  Result({this.id, this.title});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Title'] = this.title;
    return data;
  }
}
