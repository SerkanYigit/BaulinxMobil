class PublicCategoryResult {
  List<Result>? result;

  PublicCategoryResult({this.result, required bool hasError});

  PublicCategoryResult.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? createDate;
  String? eN;
  String? tR;
  String? dE;
  String? aZ;

  Result(
      {this.id,
      this.name,
      this.createDate,
      this.eN,
      this.tR,
      this.dE,
      this.aZ});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    createDate = json['CreateDate'];
    eN = json['EN'];
    tR = json['TR'];
    dE = json['DE'];
    aZ = json['AZ'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['CreateDate'] = this.createDate;
    data['EN'] = this.eN;
    data['TR'] = this.tR;
    data['DE'] = this.dE;
    data['AZ'] = this.aZ;
    return data;
  }
}
