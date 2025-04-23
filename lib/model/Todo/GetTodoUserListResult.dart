class GetTodoUserListResult {
  List<TodoUser>? result;

  GetTodoUserListResult({this.result, required bool hasError});

  GetTodoUserListResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <TodoUser>[];
      json['Result'].forEach((v) {
        result!.add(new TodoUser.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      return data;
  }
}

class TodoUser {
  int? id;
  String? name;
  String? surname;
  List<UserRules>? userRules;
  String? photo;

  TodoUser({this.id, this.name, this.surname, this.userRules, this.photo});

  TodoUser.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    surname = json['Surname'];
    if (json['UserRules'] != null) {
      userRules = <UserRules>[];
      json['UserRules'].forEach((v) {
        userRules!.add(new UserRules.fromJson(v));
      });
    }
    photo = json['Photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Surname'] = this.surname;
    data['UserRules'] = this.userRules!.map((v) => v.toJson()).toList();
      data['Photo'] = this.photo;
    return data;
  }
}

class UserRules {
  int? id;
  String? title;

  UserRules({this.id, this.title});

  UserRules.fromJson(Map<String, dynamic> json) {
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
