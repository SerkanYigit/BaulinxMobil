import 'package:intl/intl.dart';
import 'package:undede/model/Common/DataLayoutAPI.dart';
import 'package:undede/model/Todo/GetTodoCommentsResult.dart';

class GetCommonTodosResult extends DataLayoutAPI {
  List<CommonTodo>? listOfCommonTodo;

  GetCommonTodosResult({this.listOfCommonTodo, required bool hasError});

  GetCommonTodosResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      listOfCommonTodo = <CommonTodo>[];
      json['Result'].forEach((v) {
        listOfCommonTodo!.add(new CommonTodo.fromJson(v));
      });
    }
  }
}

class GetTodoResult extends DataLayoutAPI {
  CommonTodo? commonTodo;

  GetTodoResult({this.commonTodo, required bool hasError});

  GetTodoResult.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    if (json['Result'] != null) {
      commonTodo = new CommonTodo.fromJson(json['Result']);
    }
  }
}

class CommonTodo {
  int? id;
  int? ownerId;
  String? ownerName;
  dynamic ownerPicture;
  int? ownerType;
  String? content;
  int? status;
  int? userId;
  String? userPhoto;
  String? createDate;
  int? todoAdminId;
  String? description;
  String? startDate;
  String? endDate;
  String? remindDate;
  int? fileCount;
  int? commentCount;
  String? noteUrl;
  String? meetingUrl;

  List<LabelList>? labelList;
  int? orderNumber;
  List<UserList>? userList;
  String? color;
  dynamic backgroundImage;
  int? checkListCount;
  int? definedRoleId;
  dynamic boardName;
  bool? isLinked;
  String? iconPath;
  dynamic navigationLink;

  DateTime? startDateTime;

  DateTime? endDateTime;

  DateTime? remindDateTime;
  int? parentId;
  /* RESULT DIŞI */
  List<Comments>? todoComments = [];

  CommonTodo({
    this.id,
    this.ownerId,
    this.ownerName,
    this.ownerPicture,
    this.ownerType,
    this.content,
    this.status,
    this.userId,
    this.userPhoto,
    this.createDate,
    this.todoAdminId,
    this.description,
    this.startDate,
    this.endDate,
    this.remindDate,
    this.fileCount,
    this.commentCount,
    this.noteUrl,
    this.meetingUrl,
    this.labelList,
    this.orderNumber,
    this.userList,
    this.color,
    this.backgroundImage,
    this.checkListCount,
    this.definedRoleId,
    this.boardName,
    this.isLinked,
    this.navigationLink,
    this.iconPath,
    this.parentId,
  });

  CommonTodo.fromJson(Map<String, dynamic> json) {
    DateTime now = DateTime.now();

    // İstenen formatta tarih-saat bilgisini oluştur
    String formattedDate = DateFormat("yyyy-MM-ddThh:mm").format(now);
    id = json['Id'];
    ownerId = json['OwnerId'];
    ownerName = json['OwnerName'];
    ownerPicture = json['OwnerPicture'];
    ownerType = json['OwnerType'];
    content = json['Content'];
    status = json['Status'];
    userId = json['UserId'];
    userPhoto = json['UserPhoto'];
    createDate = json['CreateDate'];
    todoAdminId = json['TodoAdminId'];
    description = json['Description'] ?? "";
    startDate = json['StartDate'] ?? formattedDate;

//! DateTime.now().toString() eklendi
    startDateTime =
        new DateFormat("yyyy-MM-ddThh:mm").parse(startDate ?? formattedDate);

    endDate = json['EndDate'] ?? formattedDate;
    endDateTime = new DateFormat("yyyy-MM-ddThh:mm").parse(endDate!);
    remindDate = json['RemindDate'] ?? formattedDate;
    remindDateTime = new DateFormat("yyyy-MM-ddThh:mm").parse(remindDate!);

    fileCount = json['FileCount'];
    commentCount = json['CommentCount'];
    noteUrl = json['NoteUrl'];
    meetingUrl = json['MeetingUrl'];
    if (json['LabelList'] != null) {
      labelList = <LabelList>[];
      json['LabelList'].forEach((v) {
        labelList!.add(new LabelList.fromJson(v));
      });
    }

    orderNumber = json['OrderNumber'];
    if (json['UserList'] != null) {
      userList = <UserList>[];
      json['UserList'].forEach((v) {
        userList!.add(new UserList.fromJson(v));
      });
    }
    color = json['Color'] ?? "";
    backgroundImage = json['BackgroundImage'];
    checkListCount = json['CheckListCount'];
    definedRoleId = json['DefinedRoleId'];
    boardName = json['BoardName'];
    isLinked = json['IsLinked'];
    navigationLink = json['NavigationLink'];
    iconPath = json['IconPath'];
    parentId = json['ParentId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['OwnerId'] = this.ownerId;

    data['OwnerName'] = this.ownerName;
    data['OwnerPicture'] = this.ownerPicture;
    data['OwnerType'] = this.ownerType;
    data['Content'] = this.content;
    data['Status'] = this.status;
    data['UserId'] = this.userId;
    data['UserPhoto'] = this.userPhoto;
    data['CreateDate'] = this.createDate;

    data['TodoAdminId'] = this.todoAdminId;
    data['Description'] = this.description;
    data['StartDate'] = this.startDate;
    data['EndDate'] = this.endDate;
    data['RemindDate'] = this.remindDate;
    data['FileCount'] = this.fileCount;
    data['CommentCount'] = this.commentCount;
    data['NoteUrl'] = this.noteUrl;
    data['MeetingUrl'] = this.meetingUrl;
    data['LabelList'] = this.labelList!.map((v) => v.toJson()).toList();
    data['OrderNumber'] = this.orderNumber;
    data['UserList'] = this.userList!.map((v) => v.toJson()).toList();
    data['Color'] = this.color;
    data['BackgroundImage'] = this.backgroundImage;
    data['CheckListCount'] = this.checkListCount;
    data['DefinedRoleId'] = this.definedRoleId;
    data['BoardName'] = this.boardName;
    data['IsLinked'] = this.isLinked;
    data['NavigationLink'] = this.navigationLink;
    data['IconPath'] = this.iconPath;
    data['ParentId'] = this.parentId;

    return data;
  }
}

class LabelList {
  int? todoLabelId;
  int? labelId;
  String? labelTitle;
  String? labelColor;

  LabelList({this.todoLabelId, this.labelId, this.labelTitle, this.labelColor});

  LabelList.fromJson(Map<String, dynamic> json) {
    todoLabelId = json['TodoLabelId'];
    labelId = json['LabelId'];
    labelTitle = json['LabelTitle'];
    labelColor = json['LabelColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TodoLabelId'] = this.todoLabelId;
    data['LabelId'] = this.labelId;
    data['LabelTitle'] = this.labelTitle;
    data['LabelColor'] = this.labelColor;
    return data;
  }
}

class UserList {
  int? id;
  String? name;
  String? surname;
  List<UserRules>? userRules;
  String? photo;

  UserList({this.id, this.name, this.surname, this.userRules, this.photo});

  UserList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    surname = json['Surname'];
    if (json['UserRules'] != null) {
      userRules = <UserRules>[];
      json['UserRules'].forEach((v) {
        userRules!.add(new UserRules.fromJson(v));
      });
    }
    photo = json['Photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Surname'] = this.surname;
    data['UserRules'] = this.userRules!.map((v) => v.toJson()).toList();
    data['Photo'] = this.photo;
    return data;
  }
}

class UserRules {
  int? id;
  String? title;

  UserRules({this.id, this.title});

  UserRules.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Title'] = this.title;
    return data;
  }
}
