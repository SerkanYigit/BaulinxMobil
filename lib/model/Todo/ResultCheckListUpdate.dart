class ResultCheckListUpdate {
  Result? result;

  ResultCheckListUpdate({this.result, required bool hasError});

  ResultCheckListUpdate.fromJson(Map<String, dynamic> json) {
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
  int? todoId;
  int? userId;
  String? title;
  bool? isDone;

  Result({this.id, this.todoId, this.userId, this.title, this.isDone});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    todoId = json['TodoId'];
    userId = json['UserId'];
    title = json['Title'];
    isDone = json['IsDone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['TodoId'] = this.todoId;
    data['UserId'] = this.userId;
    data['Title'] = this.title;
    data['IsDone'] = this.isDone;
    return data;
  }
}
