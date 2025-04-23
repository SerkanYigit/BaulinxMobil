class FileInputMessage {
  List<FileInputList>? fileInputList;

  FileInputMessage({this.fileInputList});

  FileInputMessage.fromJson(Map<String, dynamic> json) {
    if (json['FileInputList'] != null) {
      fileInputList = <FileInputList>[];
      json['FileInputList'].forEach((v) {
        fileInputList!.add(new FileInputList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileInputList'] =
        this.fileInputList!.map((v) => v.toJson()).toList();
      return data;
  }
}

class FileInputList {
  String? fileName;
  String? directory;
  String? fileContent;

  FileInputList({this.fileName, this.directory, this.fileContent});

  FileInputList.fromJson(Map<String, dynamic> json) {
    fileName = json['FileName'];
    directory = json['Directory'];
    fileContent = json['FileContent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileName'] = this.fileName;
    data['Directory'] = this.directory;
    data['FileContent'] = this.fileContent;
    return data;
  }
}
