class GetPublicChatListResult {
  List<Result>? result;

  GetPublicChatListResult({this.result, required bool hasError});

  GetPublicChatListResult.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? senderId;
  int? receiverId;
  int? unreadCount;
  String? lastMessageDate;
  Null groupId;
  int? publicId;
  String? groupName;
  String? groupPhoto;
  int? isAdmin;
  Null mute;
  int? isDeleted;

  Result(
      {this.id,
      this.senderId,
      this.receiverId,
      this.unreadCount,
      this.lastMessageDate,
      this.groupId,
      this.publicId,
      this.groupName,
      this.groupPhoto,
      this.isAdmin,
      this.mute,
      this.isDeleted});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    senderId = json['SenderId'];
    receiverId = json['ReceiverId'];
    unreadCount = json['UnreadCount'];
    lastMessageDate = json['LastMessageDate'];
    groupId = json['GroupId'];
    publicId = json['PublicId'];
    groupName = json['GroupName'];
    groupPhoto = json['GroupPhoto'];
    isAdmin = json['IsAdmin'];
    mute = json['Mute'];
    isDeleted = json['IsDeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SenderId'] = this.senderId;
    data['ReceiverId'] = this.receiverId;
    data['UnreadCount'] = this.unreadCount;
    data['LastMessageDate'] = this.lastMessageDate;
    data['GroupId'] = this.groupId;
    data['PublicId'] = this.publicId;
    data['GroupName'] = this.groupName;
    data['GroupPhoto'] = this.groupPhoto;
    data['IsAdmin'] = this.isAdmin;
    data['Mute'] = this.mute;
    data['IsDeleted'] = this.isDeleted;
    return data;
  }
}
