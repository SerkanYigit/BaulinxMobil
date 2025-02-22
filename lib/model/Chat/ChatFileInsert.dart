class ChatFileInsert {
  List<FileList>? fileList;

  ChatFileInsert({this.fileList});

  ChatFileInsert.fromJson(Map<String, dynamic> json) {
    if (json['FileList'] != null) {
      fileList = <FileList>[];
      json['FileList'].forEach((v) {
        fileList!.add(new FileList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileList'] = this.fileList!.map((v) => v.toJson()).toList();
      return data;
  }
}

class FileList {
  String? fileNameWithExtension;
  String? base64FileContent;

  FileList({this.fileNameWithExtension, this.base64FileContent});

  FileList.fromJson(Map<String, dynamic> json) {
    fileNameWithExtension = json['FileNameWithExtension'];
    base64FileContent = json['Base64FileContent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileNameWithExtension'] = this.fileNameWithExtension;
    data['Base64FileContent'] = this.base64FileContent;
    return data;
  }
}
