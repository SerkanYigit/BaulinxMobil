class InvoiceFileInsertFiles {
  List<FileInput>? fileInput;

  InvoiceFileInsertFiles({this.fileInput});

  InvoiceFileInsertFiles.fromJson(Map<String, dynamic> json) {
    if (json['FileInput'] != null) {
      fileInput = <FileInput>[];
      json['FileInput'].forEach((v) {
        fileInput!.add(new FileInput.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileInput'] = this.fileInput!.map((v) => v.toJson()).toList();
      return data;
  }
}

class FileInput {
  String? fileName;
  String? fileContent;

  FileInput({this.fileName, this.fileContent});

  FileInput.fromJson(Map<String, dynamic> json) {
    fileName = json['FileName'];
    fileContent = json['FileContent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileName'] = this.fileName;
    data['FileContent'] = this.fileContent;
    return data;
  }
}