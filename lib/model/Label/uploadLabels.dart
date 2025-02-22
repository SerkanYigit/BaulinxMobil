class uploadLabels {
  List<FilesIds>? filesIds;
  List<LabelIds>? labelIds;
  int? userId;

  uploadLabels({this.filesIds, this.labelIds, this.userId});

  uploadLabels.fromJson(Map<String, dynamic> json) {
    if (json['FilesIds'] != null) {
      filesIds = <FilesIds>[];
      json['FilesIds'].forEach((v) {
        filesIds!.add(new FilesIds.fromJson(v));
      });
    }
    if (json['LabelIds'] != null) {
      labelIds = <LabelIds>[];
      json['LabelIds'].forEach((v) {
        labelIds!.add(new LabelIds.fromJson(v));
      });
    }
    userId = json['UserId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FilesIds'] = this.filesIds!.map((v) => v.toJson()).toList();
      data['LabelIds'] = this.labelIds!.map((v) => v.toJson()).toList();
      data['UserId'] = this.userId;
    return data;
  }
}

class FilesIds {
  int? filesId;

  FilesIds({this.filesId});

  FilesIds.fromJson(Map<String, dynamic> json) {
    filesId = json['FilesId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FilesId'] = this.filesId;
    return data;
  }
}

class LabelIds {
  int? labelId;

  LabelIds({this.labelId});

  LabelIds.fromJson(Map<String, dynamic> json) {
    labelId = json['LabelId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LabelId'] = this.labelId;
    return data;
  }
}
