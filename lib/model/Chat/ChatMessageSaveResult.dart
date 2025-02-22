class ChatMessageSaveResult {
  Result? result;

  ChatMessageSaveResult({this.result, required bool hasError});

  ChatMessageSaveResult.fromJson(Map<String, dynamic> json) {
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
  int? receiverId;
  int? type;
  int? unread;
  String? message;
  String? createDate;
  int? groupId;
  int? publicId;

  Result(
      {this.id,
      this.senderId,
      this.receiverId,
      this.type,
      this.unread,
      this.message,
      this.createDate,
      this.groupId,
      this.publicId});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    senderId = json['SenderId'];
    receiverId = json['ReceiverId'];
    type = json['Type'];
    unread = json['Unread'];
    message = json['Message'];
    createDate = json['CreateDate'];
    groupId = json['GroupId'];
    publicId = json['PublicId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SenderId'] = this.senderId;
    data['ReceiverId'] = this.receiverId;
    data['Type'] = this.type;
    data['Unread'] = this.unread;
    data['Message'] = this.message;
    data['CreateDate'] = this.createDate;
    data['GroupId'] = this.groupId;
    data['PublicId'] = this.publicId;
    return data;
  }
}
