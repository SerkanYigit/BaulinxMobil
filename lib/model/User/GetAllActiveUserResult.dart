class GetAllActiveUserResult {
  List<Result>? result;

  GetAllActiveUserResult({this.result, required bool hasError});

  GetAllActiveUserResult.fromJson(Map<String, dynamic> json) {
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
  String? mailAddress;
  String? phone;
  String? name;
  String? surname;
  String? photo;
  String? userFullName;

  Result(
      {this.id,
      this.mailAddress,
      this.phone,
      this.name,
      this.surname,
      this.photo,
      this.userFullName});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    mailAddress = json['MailAddress'];
    phone = json['Phone'];
    name = json['Name'];
    surname = json['Surname'];
    photo = json['Photo'];
    userFullName = json['UserFullName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['MailAddress'] = this.mailAddress;
    data['Phone'] = this.phone;
    data['Name'] = this.name;
    data['Surname'] = this.surname;
    data['Photo'] = this.photo;
    data['UserFullName'] = this.userFullName;
    return data;
  }
}
