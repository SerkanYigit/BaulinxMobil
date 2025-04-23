class GetOpenAIChatMessagesResult {
  List<OpenAIChatDetails>? result;

  GetOpenAIChatMessagesResult({this.result, required bool hasError});

  GetOpenAIChatMessagesResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <OpenAIChatDetails>[];
      json['Result'].forEach((v) {
        result!.add(new OpenAIChatDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      return data;
  }
}

class OpenAIChatDetails {
  int? id;
  int? senderId;
  int? reciverId;
  String? message;
  String? createdDate;
  FilesDoc? files;

  OpenAIChatDetails(
      {this.id,
      this.senderId,
      this.reciverId,
      this.message,
      this.createdDate,
      this.files});

  OpenAIChatDetails.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    senderId = json['SenderId'];
    reciverId = json['ReciverId'];
    message = json['Message'];
    createdDate = json['CreatedDate'];
    files = json['FileInputContent'] != null
        ? new FilesDoc.fromJson(json['FileInputContent'])
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

class FilesDoc {
  int? fileId;
  String? fileName;
  String? directory;
  String? fileContent;
  String? fileThumbnail;

  FilesDoc({this.fileName, this.directory, this.fileContent});

  FilesDoc.fromJson(Map<String, dynamic> json) {
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
