class GetTodoLabelListResult {
  List<Label>? result;

  GetTodoLabelListResult({this.result, required bool hasError});

  GetTodoLabelListResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <Label>[];
      json['Result'].forEach((v) {
        result!.add(new Label.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Label {
  int? todoLabelId;
  int? labelId;
  String? labelTitle;
  String? labelColor;

  Label({this.todoLabelId, this.labelId, this.labelTitle, this.labelColor});

  Label.fromJson(Map<String, dynamic> json) {
    todoLabelId = json['TodoLabelId'];
    labelId = json['LabelId'];
    labelTitle = json['LabelTitle'];
    labelColor = json['LabelColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TodoLabelId'] = this.todoLabelId;
    data['LabelId'] = this.labelId;
    data['LabelTitle'] = this.labelTitle;
    data['LabelColor'] = this.labelColor;
    return data;
  }
}
