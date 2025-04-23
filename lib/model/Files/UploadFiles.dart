class UploadFiles {
  int? userId;
  int? customerId;
  int? moduleTypeId;
  Files? files;
  bool? isCombine;
  String? combineFileName;

  UploadFiles(
      {this.userId,
        this.customerId,
        this.moduleTypeId,
        this.files,
        this.isCombine,
        this.combineFileName});

  UploadFiles.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    customerId = json['CustomerId'];
    moduleTypeId = json['ModuleTypeId'];
    files = json['Files'] != null ? new Files.fromJson(json['Files']) : null;
    isCombine = json['IsCombine'];
    combineFileName = json['CombineFileName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserId'] = this.userId;
    data['CustomerId'] = this.customerId;
    data['ModuleTypeId'] = this.moduleTypeId;
    data['Files'] = this.files!.toJson();
      data['IsCombine'] = this.isCombine;
    data['CombineFileName'] = this.combineFileName;
    return data;
  }
}

class Files {
  List<FileInput>? fileInput;

  Files({this.fileInput});

  Files.fromJson(Map<String, dynamic> json) {
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
  String? directory;
  String? fileContent;

  FileInput({this.fileName, this.directory, this.fileContent});

  FileInput.fromJson(Map<String, dynamic> json) {
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