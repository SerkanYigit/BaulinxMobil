class InsertOpenAIChatResult {
  Result? result;

  InsertOpenAIChatResult({this.result});

  InsertOpenAIChatResult.fromJson(Map<String, dynamic> json) {
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
  int? senderId;
  int? reciverId;
  String? message;
  String? createdDate;
  Files? files;

  Result(
      {this.id,
      this.senderId,
      this.reciverId,
      this.message,
      this.createdDate,
      this.files});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    senderId = json['SenderId'];
    reciverId = json['ReciverId'];
    message = json['Message'];
    createdDate = json['CreatedDate'];
    files = json['FileInputContent'] != null
        ? new Files.fromJson(json['FileInputContent'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SenderId'] = this.senderId;
    data['ReciverId'] = this.reciverId;
    data['Message'] = this.message;
    data['CreatedDate'] = this.createdDate;
    data['FileInputContent'] = this.files!.toJson();
      return data;
  }
}

class Files {
  int? fileId;
  String? fileName;
  String? directory;
  String? fileContent;
  String? fileThumbnail;

  Files({this.fileName, this.directory, this.fileContent});

  Files.fromJson(Map<String, dynamic> json) {
    fileId = json['FileId'];
    fileName = json['FileName'];
    directory = json['Directory'];
    fileContent = json['FileContent'];
    fileThumbnail = json['FileThumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileId'] = this.fileId;
    data['FileName'] = this.fileName;
    data['Directory'] = this.directory;
    data['FileContent'] = this.fileContent;
    data['FileThumbnail'] = this.fileThumbnail;
    return data;
  }
}
