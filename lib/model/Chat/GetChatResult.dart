class GetChatResult {
  Result? result;

  GetChatResult({this.result, required bool hasError});

  GetChatResult.fromJson(Map<String, dynamic> json) {
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
  int? groupId;
  int? publicId;
  List<Messages>? messages;
  int? otherUserId;
  String? otherUserName;
  String? otherUserSurname;
  String? otherUserPhoto;
  int? isGroup;
  int? isPublic;
  int? isAdmin;
  List<UserList>? userList;

  Result(
      {this.id,
      this.groupId,
      this.publicId,
      this.messages,
      this.otherUserId,
      this.otherUserName,
      this.otherUserSurname,
      this.otherUserPhoto,
      this.isGroup,
      this.isPublic,
      this.isAdmin,
      this.userList});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    groupId = json['GroupId'];
    publicId = json['PublicId'];
    if (json['Messages'] != null) {
      messages = <Messages>[];
      json['Messages'].forEach((v) {
        messages!.add(new Messages.fromJson(v));
      });
    }
    otherUserId = json['OtherUserId'];
    otherUserName = json['OtherUserName'];
    otherUserSurname = json['OtherUserSurname'];
    otherUserPhoto = json['OtherUserPhoto'] ?? "";
    isGroup = json['IsGroup'];
    isPublic = json['IsPublic'];
    isAdmin = json['IsAdmin'];
    if (json['UserList'] != null) {
      userList = <UserList>[];
      json['UserList'].forEach((v) {
        userList!.add(new UserList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['GroupId'] = this.groupId;
    data['PublicId'] = this.publicId;
    data['Messages'] = this.messages!.map((v) => v.toJson()).toList();
      data['OtherUserId'] = this.otherUserId;
    data['OtherUserName'] = this.otherUserName;
    data['OtherUserSurname'] = this.otherUserSurname;
    data['OtherUserPhoto'] = this.otherUserPhoto ?? "";
    data['IsGroup'] = this.isGroup;
    data['IsPublic'] = this.isPublic;
    data['IsAdmin'] = this.isAdmin;
    data['UserList'] = this.userList!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Messages {
  int? id;
  int? senderId;
  String? senderName;
  String? senderSurname;
  String? senderPhoto;
  int? receiverId;
  int? type;
  int? unread;
  String? message;
  List<FileObj>? fileList;
  String? createDate;
  int? groupId;
  int? publicId;
  int? relatedMessageId;

  Messages(
      {this.id,
      this.senderId,
      this.senderName,
      this.senderSurname,
      this.senderPhoto,
      this.receiverId,
      this.type,
      this.unread,
      this.message,
      this.fileList,
      this.createDate,
      this.groupId,
      this.publicId,
      this.relatedMessageId});

  Messages.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    senderId = json['SenderId'];
    senderName = json['SenderName'];
    senderSurname = json['SenderSurname'];
    senderPhoto = json['SenderPhoto'];
    receiverId = json['ReceiverId'];
    type = json['Type'];
    unread = json['Unread'];
    message = json['Message'];
    if (json['FileList'] != null) {
      fileList = <FileObj>[];
      json['FileList'].forEach((v) {
        fileList!.add(new FileObj.fromJson(v));
      });
    }
    createDate = json['CreateDate'];
    groupId = json['GroupId'];
    publicId = json['PublicId'];
    relatedMessageId = json['RelatedMessageId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SenderId'] = this.senderId;
    data['SenderName'] = this.senderName;
    data['SenderSurname'] = this.senderSurname;
    data['SenderPhoto'] = this.senderPhoto;
    data['ReceiverId'] = this.receiverId;
    data['Type'] = this.type;
    data['Unread'] = this.unread;
    data['Message'] = this.message;
    data['FileList'] = this.fileList;
    data['CreateDate'] = this.createDate;
    data['GroupId'] = this.groupId;
    data['PublicId'] = this.publicId;
    data['RelatedMessageId'] = this.relatedMessageId;
    return data;
  }
}

class FileObj {
  String? path;
  String? thumbnailPath;
  String? fileName;

  FileObj(
      {this.path,
        this.thumbnailPath,
        this.fileName});

  FileObj.fromJson(Map<String, dynamic> json) {
    path = json['Path'];
    thumbnailPath = json['ThumbnailPath'];
    fileName = json['FileName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Path'] = this.path;
    data['ThumbnailPath'] = this.thumbnailPath;
    data['FileName'] = this.fileName;
    return data;
  }
}

class UserList {
  int? isChatAdmin;
  int? id;
  String? name;
  String? surname;
  String? mailAddress;
  String? phoneNumber;
  String? photo;
  Null nickName;

  UserList(
      {this.isChatAdmin,
      this.id,
      this.name,
      this.surname,
      this.mailAddress,
      this.phoneNumber,
      this.photo,
      this.nickName});

  UserList.fromJson(Map<String, dynamic> json) {
    isChatAdmin = json['IsChatAdmin'];
    id = json['Id'];
    name = json['Name'];
    surname = json['Surname'];
    mailAddress = json['MailAddress'];
    phoneNumber = json['PhoneNumber'];
    photo = json['Photo'];
    nickName = json['NickName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsChatAdmin'] = this.isChatAdmin;
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Surname'] = this.surname;
    data['MailAddress'] = this.mailAddress;
    data['PhoneNumber'] = this.phoneNumber;
    data['Photo'] = this.photo;
    data['NickName'] = this.nickName;
    return data;
  }
}
