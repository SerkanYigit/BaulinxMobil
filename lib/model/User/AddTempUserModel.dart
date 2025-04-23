class AddTempUserModel {
  Result? result;

  AddTempUserModel({this.result});

  AddTempUserModel.fromJson(Map<String, dynamic> json) {
    result =
        json['Result'] != null ? new Result.fromJson(json['Result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.toJson();
      return data;
  }
}

class Result {
  int? id;
  String? name;
  String? surname;
  String? mailAddress;
  String? createDate;

  Result({this.id, this.name, this.surname, this.mailAddress, this.createDate});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    surname = json['Surname'];
    mailAddress = json['MailAddress'];
    createDate = json['CreateDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Surname'] = this.surname;
    data['MailAddress'] = this.mailAddress;
    data['CreateDate'] = this.createDate;
    return data;
  }
}
