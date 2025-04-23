class GetMessageByUserIdResult {
  Result? result;

  GetMessageByUserIdResult({this.result, required bool hasError});

  GetMessageByUserIdResult.fromJson(Map<String, dynamic> json) {
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
  List<MessageList>? messageList;
  int? totalPage;
  int? selectedPage;
  int? size;

  Result({this.messageList, this.totalPage, this.selectedPage, this.size});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['MessageList'] != null) {
      messageList = <MessageList>[];
      json['MessageList'].forEach((v) {
        messageList!.add(new MessageList.fromJson(v));
      });
    }
    totalPage = json['TotalPage'];
    selectedPage = json['SelectedPage'];
    size = json['Size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MessageList'] = this.messageList!.map((v) => v.toJson()).toList();
      data['TotalPage'] = this.totalPage;
    data['SelectedPage'] = this.selectedPage;
    data['Size'] = this.size;
    return data;
  }
}

class MessageList {
  int? id;
  int? mainMessageId;
  int? fromUser;
  String? fromUserNameAndSurname;
  String? fromUserPhotoPath;
  String? fromUserMail;
  String? createDate;
  String? messageSubject;
  String? messageText;
  String? toUsers;
  int? fileCount;
  bool? isDeleted;
  bool? isSeen;
  List<SubMessageList>? subMessageList;
  List<FileList>? fileList;
  List<ToUserList>? toUserList;
  int? commonGroupId;
  int? messageCategoryId;

  MessageList(
      {this.id,
      this.mainMessageId,
      this.fromUser,
      this.fromUserNameAndSurname,
      this.fromUserPhotoPath,
      this.fromUserMail,
      this.createDate,
      this.messageSubject,
      this.messageText,
      this.toUsers,
      this.fileCount,
      this.isDeleted,
      this.isSeen,
      this.subMessageList,
      this.fileList,
      this.toUserList,
      this.commonGroupId,
      this.messageCategoryId});

  MessageList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    mainMessageId = json['MainMessageId'];
    fromUser = json['FromUser'];
    fromUserNameAndSurname = json['FromUserNameAndSurname'];
    fromUserPhotoPath = json['FromUserPhotoPath'];
    fromUserMail = json['FromUserMail'];
    createDate = json['CreateDate'];
    messageSubject = json['MessageSubject'];
    messageText = json['MessageText'];
    toUsers = json['ToUsers'];
    fileCount = json['FileCount'];
    isDeleted = json['IsDeleted'];
    commonGroupId = json['CommonGroupId'];
    messageCategoryId = json['MessageCategoryId'];
    isSeen = json['IsSeen'];
    if (json['SubMessageList'] != null) {
      subMessageList = <SubMessageList>[];
      json['SubMessageList'].forEach((v) {
        subMessageList!.add(new SubMessageList.fromJson(v));
      });
    }
    if (json['FileList'] != null) {
      fileList = <FileList>[];
      json['FileList'].forEach((v) {
        fileList!.add(new FileList.fromJson(v));
      });
    }
    if (json['ToUserList'] != null) {
      toUserList = <ToUserList>[];
      json['ToUserList'].forEach((v) {
        toUserList!.add(new ToUserList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['MainMessageId'] = this.mainMessageId;
    data['FromUser'] = this.fromUser;
    data['FromUserNameAndSurname'] = this.fromUserNameAndSurname;
    data['FromUserPhotoPath'] = this.fromUserPhotoPath;
    data['FromUserMail'] = this.fromUserMail;
    data['CreateDate'] = this.createDate;
    data['MessageSubject'] = this.messageSubject;
    data['CommonGroupId'] = this.commonGroupId;
    data['MessageCategoryId'] = this.messageCategoryId;
    data['MessageText'] = this.messageText;
    data['ToUsers'] = this.toUsers;
    data['FileCount'] = this.fileCount;
    data['IsDeleted'] = this.isDeleted;
    data['IsSeen'] = this.isSeen;
    data['SubMessageList'] =
        this.subMessageList!.map((v) => v.toJson()).toList();
      data['FileList'] = this.fileList;
    data['ToUserList'] = this.toUserList!.map((v) => v.toJson()).toList();
      return data;
  }
}

class SubMessageList {
  int? id;
  int? mainMessageId;
  int? fromUser;
  String? fromUserNameAndSurname;
  String? fromUserPhotoPath;
  String? fromUserMail;
  String? createDate;
  String? messageSubject;
  String? messageText;
  String? toUsers;
  int? fileCount;
  bool? isDeleted;
  bool? isSeen;
  List<SubMessageList>? subMessageList;
  List<FileList>? fileList;
  List<ToUserList>? toUserList;

  SubMessageList(
      {this.id,
      this.mainMessageId,
      this.fromUser,
      this.fromUserNameAndSurname,
      this.fromUserPhotoPath,
      this.fromUserMail,
      this.createDate,
      this.messageSubject,
      this.messageText,
      this.toUsers,
      this.fileCount,
      this.isDeleted,
      this.isSeen,
      this.subMessageList,
      this.fileList,
      this.toUserList});

  SubMessageList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    mainMessageId = json['MainMessageId'];
    fromUser = json['FromUser'];
    fromUserNameAndSurname = json['FromUserNameAndSurname'];
    fromUserPhotoPath = json['FromUserPhotoPath'];
    fromUserMail = json['FromUserMail'];
    createDate = json['CreateDate'];
    messageSubject = json['MessageSubject'];
    messageText = json['MessageText'];
    toUsers = json['ToUsers'];
    fileCount = json['FileCount'];
    isDeleted = json['IsDeleted'];
    isSeen = json['IsSeen'];
    subMessageList = json['SubMessageList'];
    if (json['FileList'] != null) {
      fileList = <FileList>[];
      json['FileList'].forEach((v) {
        fileList!.add(new FileList.fromJson(v));
      });
    }
    toUserList = json['ToUserList'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['MainMessageId'] = this.mainMessageId;
    data['FromUser'] = this.fromUser;
    data['FromUserNameAndSurname'] = this.fromUserNameAndSurname;
    data['FromUserPhotoPath'] = this.fromUserPhotoPath;
    data['FromUserMail'] = this.fromUserMail;
    data['CreateDate'] = this.createDate;
    data['MessageSubject'] = this.messageSubject;
    data['MessageText'] = this.messageText;
    data['ToUsers'] = this.toUsers;
    data['FileCount'] = this.fileCount;
    data['IsDeleted'] = this.isDeleted;
    data['IsSeen'] = this.isSeen;
    data['SubMessageList'] = this.subMessageList;
    data['FileList'] = this.fileList;
    data['ToUserList'] = this.toUserList;
    return data;
  }
}

class ToUserList {
  int? id;
  String? name;
  String? mailAddress;

  ToUserList({this.id, this.name, this.mailAddress});

  ToUserList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    mailAddress = json['MailAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['MailAddress'] = this.mailAddress;
    return data;
  }
}

class FileList {
  int? id;
  int? ownerId;
  int? ocrStatus;
  String? fileName;
  String? path;
  String? extension;
  String? ocrResult;
  String? ocrDate;
  int? moduleType;
  int? userId;
  String? createDate;
  int? customerId;
  String? ocrStatusText;
  String? thumbnailPath;

  FileList(
      {this.id,
      this.ownerId,
      this.ocrStatus,
      this.fileName,
      this.path,
      this.extension,
      this.ocrResult,
      this.ocrDate,
      this.moduleType,
      this.userId,
      this.createDate,
      this.customerId,
      this.ocrStatusText,
      this.thumbnailPath});

  FileList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    ownerId = json['OwnerId'];
    ocrStatus = json['OcrStatus'];
    fileName = json['FileName'];
    path = json['Path'];
    extension = json['Extension'];
    ocrResult = json['OcrResult'];
    ocrDate = json['OcrDate'];
    moduleType = json['ModuleType'];
    userId = json['UserId'];
    createDate = json['CreateDate'];
    customerId = json['CustomerId'];
    ocrStatusText = json['OcrStatusText'];
    thumbnailPath = json['ThumbnailPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['OwnerId'] = this.ownerId;
    data['OcrStatus'] = this.ocrStatus;
    data['FileName'] = this.fileName;
    data['Path'] = this.path;
    data['Extension'] = this.extension;
    data['OcrResult'] = this.ocrResult;
    data['OcrDate'] = this.ocrDate;
    data['ModuleType'] = this.moduleType;
    data['UserId'] = this.userId;
    data['CreateDate'] = this.createDate;
    data['CustomerId'] = this.customerId;
    data['OcrStatusText'] = this.ocrStatusText;
    data['ThumbnailPath'] = this.thumbnailPath;
    return data;
  }
}

class EmailList {
  String? version;
  bool? hasError;
  String? resultCode;
  String? resultMessage;
  String? authenticationToken;
  List<String>? result;
  dynamic header;

  EmailList({
    this.version,
    this.hasError,
    this.resultCode,
    this.resultMessage,
    this.authenticationToken,
    this.result,
    this.header,
  });

  // Parsing JSON into the EmailList model
  EmailList.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    result = json['Result'] != null ? List<String>.from(json['Result']) : null;
    header = json['Header']; // Adjust accordingly if 'Header' is complex
  }

  // Converting EmailList model into JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Version'] = this.version;
    data['HasError'] = this.hasError;
    data['ResultCode'] = this.resultCode;
    data['ResultMessage'] = this.resultMessage;
    data['AuthenticationToken'] = this.authenticationToken;
    data['Result'] = this.result;
      data['Header'] = this.header;
    return data;
  }
}

class Folder {
  String? name;
  List<Folder>? subFolders;

  Folder({this.name, this.subFolders});

  // Parsing JSON into the Folder model
  Folder.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    if (json['SubFolders'] != null) {
      subFolders = List<Folder>.from(
          json['SubFolders'].map((subFolder) => Folder.fromJson(subFolder)));
    } else {
      subFolders = [];
    }
  }

  // Converting Folder model into JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['SubFolders'] =
        this.subFolders!.map((subFolder) => subFolder.toJson()).toList();
      return data;
  }
}

class FolderListModel {
  String? version;
  bool? hasError;
  String? resultCode;
  String? resultMessage;
  String? authenticationToken;
  List<Folder>? result;
  dynamic header;

  FolderListModel({
    this.version,
    this.hasError,
    this.resultCode,
    this.resultMessage,
    this.authenticationToken,
    this.result,
    this.header,
  });

  // Parsing JSON into the FolderListModel model
  FolderListModel.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    if (json['Result'] != null) {
      result = List<Folder>.from(
          json['Result'].map((folder) => Folder.fromJson(folder)));
    } else {
      result = [];
    }
    header = json['Header']; // Adjust if Header is more complex
  }

  // Converting EmailList model into JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Version'] = this.version;
    data['HasError'] = this.hasError;
    data['ResultCode'] = this.resultCode;
    data['ResultMessage'] = this.resultMessage;
    data['AuthenticationToken'] = this.authenticationToken;
    data['Result'] = this.result!.map((folder) => folder.toJson()).toList();
      data['Header'] = this.header;
    return data;
  }
}

class EmailResponse {
  String? version;
  bool? hasError;
  String? resultCode;
  String? resultMessage;
  String? authenticationToken;
  List<EmailResult>? result;

  EmailResponse({
    this.version,
    this.hasError,
    this.resultCode,
    this.resultMessage,
    this.authenticationToken,
    this.result,
  });

  factory EmailResponse.fromJson(Map<String, dynamic> json) {
    return EmailResponse(
      version: json['Version'],
      hasError: json['HasError'],
      resultCode: json['ResultCode'],
      resultMessage: json['ResultMessage'],
      authenticationToken: json['AuthenticationToken'],
      result: List<EmailResult>.from(
        json['Result'].map((item) => EmailResult.fromJson(item)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Version': version,
      'HasError': hasError,
      'ResultCode': resultCode,
      'ResultMessage': resultMessage,
      'AuthenticationToken': authenticationToken,
      'Result': result!.map((item) => item.toJson()).toList(),
    };
  }
}

class EmailDetailResponse {
  dynamic header;
  String? version;
  bool? hasError;
  String? resultCode;
  String? resultMessage;
  String? authenticationToken;
  EmailResult? result; // This should be of type EmailResult

  EmailDetailResponse({
    this.version,
    this.hasError,
    this.resultCode,
    this.resultMessage,
    this.authenticationToken,
    this.result,
    this.header,
  });

  factory EmailDetailResponse.fromJson(Map<String, dynamic> json) {
    return EmailDetailResponse(
      version: json['Version'] as String,
      hasError: json['HasError'] as bool,
      resultCode: json['ResultCode'] as String,
      resultMessage: json['ResultMessage'] as String,
      authenticationToken: json['AuthenticationToken'] as String,
      result: EmailResult.fromJson(json['Result']), // Parse as EmailResult
      header: json['Header'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Version': version,
      'HasError': hasError,
      'ResultCode': resultCode,
      'ResultMessage': resultMessage,
      'AuthenticationToken': authenticationToken,
      'Result': result!.toJson(), // Convert EmailResult to JSON
      'Header': header,
    };
  }
}

class EmailResult {
  int? id;
  EmailContact? from;
  EmailContact? sender;
  List<EmailContact>? to;
  String? subject;
  String? body;
  DateTime? date;
  List<Attachment>? attachments;

  EmailResult({
    this.id,
    this.from,
    this.sender,
    this.to,
    this.subject,
    this.body,
    this.date,
    this.attachments,
  });

  factory EmailResult.fromJson(Map<String, dynamic> json) {
    return EmailResult(
      id: json['Id'],
      from: EmailContact.fromJson(json['From']),
      sender: EmailContact.fromJson(json['Sender']),
      to: json['To'] != null
          ? List<EmailContact>.from(
              json['To'].map((item) => EmailContact.fromJson(item)),
            )
          : null,
      subject: json['Subject'],
      body: json['Body'],
      date: DateTime.parse(json['Date']),
      attachments: json['Attachments'] != null
          ? List<Attachment>.from(
              json['Attachments'].map((item) => Attachment.fromJson(item)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'From': from!.toJson(),
      'Sender': sender!.toJson(),
      'To': to!.map((item) => item.toJson()).toList(),
      'Subject': subject,
      'Body': body,
      'Date': date!.toIso8601String(),
      'Attachments': attachments!.map((item) => item.toJson()).toList(),
    };
  }
}

class EmailContact {
  String? name;
  String? email;

  EmailContact({
    this.name,
    this.email,
  });

  factory EmailContact.fromJson(Map<String, dynamic> json) {
    return EmailContact(
      name: json['Name'],
      email: json['Email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Email': email,
    };
  }
}

class Attachment {
  String? fileName;
  String? contentType;
  String? data;
  String? contentId;

  Attachment({
    this.fileName,
    this.contentType,
    this.data,
    this.contentId,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      fileName: json['FileName'] as String,
      contentType: json['ContentType'] as String,
      data: json['Data'] as String,
      contentId: json['ContentId'] as String, // Nullable field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FileName': fileName,
      'ContentType': contentType,
      'Data': data,
      'ContentId': contentId,
    };
  }
}
