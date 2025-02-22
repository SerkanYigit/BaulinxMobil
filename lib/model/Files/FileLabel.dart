class FileLabel {
  List<Result>? result;

  FileLabel({this.result, required bool hasError});

  FileLabel.fromJson(Map<String, dynamic> json) {
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
  int? fileLabelId;
  String? labelTitle;
  String? labelColor;

  Result({this.fileLabelId, this.labelTitle, this.labelColor});

  Result.fromJson(Map<String, dynamic> json) {
    fileLabelId = json['FileLabelId'];
    labelTitle = json['LabelTitle'];
    labelColor = json['LabelColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileLabelId'] = this.fileLabelId;
    data['LabelTitle'] = this.labelTitle;
    data['LabelColor'] = this.labelColor;
    return data;
  }
}
