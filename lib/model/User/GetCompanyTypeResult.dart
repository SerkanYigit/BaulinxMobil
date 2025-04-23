class GetCompanyTypeResult {
  List<Result>? result;

  GetCompanyTypeResult({this.result, required bool hasError});

  GetCompanyTypeResult.fromJson(Map<String, dynamic> json) {
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
  String? companyName;

  Result({this.id, this.companyName});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    companyName = json['CompanyName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CompanyName'] = this.companyName;
    return data;
  }
}
