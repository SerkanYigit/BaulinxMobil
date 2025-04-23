class GetTodoCheckListResult {
  List<CheckListItem>? checkListItem;

  GetTodoCheckListResult({this.checkListItem, required bool hasError});

  GetTodoCheckListResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      checkListItem = <CheckListItem>[];
      json['Result'].forEach((v) {
        checkListItem!.add(new CheckListItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.checkListItem!.map((v) => v.toJson()).toList();
      return data;
  }
}

class CheckListItem {
  int? id;
  int? todoId;
  int? userId;
  String? title;
  bool? isDone;

  CheckListItem({this.id, this.todoId, this.userId, this.title, this.isDone});

  CheckListItem.fromJson(Map<String, dynamic> json) {
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
