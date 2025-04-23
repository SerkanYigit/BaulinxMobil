import 'package:undede/model/CityServiceCountry/CityServiceCountry.dart';
import 'package:undede/model/User/UserData.dart';

class Office {
  int? statusCode;
  Null exceptionInfo;
  Null pageSortSearch;
  bool? hasError;
  List<OfficeData>? data;

  Office(
      {this.statusCode,
        this.exceptionInfo,
        this.pageSortSearch,
        this.hasError,
        this.data});

  Office.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    exceptionInfo = json['exceptionInfo'];
    pageSortSearch = json['pageSortSearch'];
    hasError = json['hasError'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new OfficeData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['exceptionInfo'] = this.exceptionInfo;
    data['pageSortSearch'] = this.pageSortSearch;
    data['hasError'] = this.hasError;
    data['data'] = this.data!.map((v) => v.toJson()).toList();
      return data;
  }
}

class OfficeData {
  int? id;
  int? createdUserId;
  String? description;
  double? commentAverage;
  int? commentCount;
  String? title;
  UserData? user;
  List<Images>? images;
  String? modifiedDate;
  String? logo;
  String? createdDate;
  List<Category>? service;
  List<City>? country;
  List<City>? city;
  List<District>? district;
  List<Street>? street;

  OfficeData(
      {this.id,
        this.createdUserId,
        this.description,
        this.commentCount,
        this.commentAverage,
        this.title,
        this.logo,
        this.images,
        this.modifiedDate,
        this.createdDate,
        this.service,
        this.country,
        this.city,
        this.street,
        this.district});

  OfficeData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdUserId = json['createdUserId'];
    description = json['description'];
    logo = json['logo'];
    commentCount = json['commentCount'];
    commentAverage =json['commentAverage'].runtimeType==int?json['commentAverage'].toDouble():json['commentAverage'];
    title = json['title'];
    user = json['user']==null?UserData():UserData.fromJson(json['user']);
    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }

    if (json['service'] != null) {
      service = [];
      json['service'].forEach((v) {
        service!.add(new Category.fromJson(v));
      });
    }
    modifiedDate = json['modifiedDate'];
    createdDate = json['createdDate'];
   /* service =
    json['service'] != null ? new CscData.fromJson(json['service']) : null;*/


    if (json['country'] != null) {
      country = [];
      json['country'].forEach((v) {
        country!.add(new City.fromJson(v));
      });
    }

    if (json['city'] != null) {
      city = [];
      json['city'].forEach((v) {
        city!.add(new City.fromJson(v));
      });
    }

    if (json['district'] != null) {
      district = [];
      json['district'].forEach((v) {
        district!.add(new District.fromJson(v));
      });
    }
    if (json['street'] != null) {
      street = [];
      json['street'].forEach((v) {
        street!.add(new Street.fromJson(v));
      });
    }


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdUserId'] = this.createdUserId;
    data['description'] = this.description;
    data['commentCount'] = this.commentCount;
    data['commentAverage'] = this.commentAverage;

    data['logo'] = this.logo;
    data['user'] = this.user!.toJson();
    data['title'] = this.title;
    data['images'] = this.images!.map((v) => v.toJson()).toList();
  
    data['service'] = this.service!.map((v) => v.toJson()).toList();
      data['modifiedDate'] = this.modifiedDate;
    data['createdDate'] = this.createdDate;
/*    if (this.service != null) {
      data['service'] = this.service.toJson();
    }*/

    data['country'] = this.country!.map((v) => v.toJson()).toList();
      data['street'] = this.street!.map((v) => v.toJson()).toList();
  
    data['city'] = this.city!.map((v) => v.toJson()).toList();
  
    data['district'] = this.district!.map((v) => v.toJson()).toList();
  
  /*  if (this.country != null) {
      data['country'] = this.country.toJson();
    }
    if (this.city != null) {
      data['city'] = this.city.toJson();
    }
    if (this.district != null) {
      data['district'] = this.district.toJson();
    }*/
    return data;
  }


}

class Images {
  int? id;
  int? messageId;
  int? ocrStatus;
  String? fileName;
  Null path;
  Null thumbnailUrl;
  Null extension;
  int? ocrResult;
  String? ocrDate;
  int? moduleType;
  int? userId;
  int? customerId;
  int? todoId;
  int? projectId;
  String? createDate;
  Null ocrStatusText;
  Null folderName;
  int? totalFileCount;

  Images(
      {this.id,
        this.messageId,
        this.ocrStatus,
        this.fileName,
        this.path,
        this.thumbnailUrl,
        this.extension,
        this.ocrResult,
        this.ocrDate,
        this.moduleType,
        this.userId,
        this.customerId,
        this.todoId,
        this.projectId,
        this.createDate,
        this.ocrStatusText,
        this.folderName,
        this.totalFileCount});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    messageId = json['messageId'];
    ocrStatus = json['ocrStatus'];
    fileName = json['fileName'];
    path = json['path'];
    thumbnailUrl = json['thumbnailUrl'];
    extension = json['extension'];
    ocrResult = json['ocrResult'];
    ocrDate = json['ocrDate'];
    moduleType = json['moduleType'];
    userId = json['userId'];
    customerId = json['customerId'];
    todoId = json['todoId'];
    projectId = json['projectId'];
    createDate = json['createDate'];
    ocrStatusText = json['ocrStatusText'];
    folderName = json['folderName'];
    totalFileCount = json['totalFileCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['messageId'] = this.messageId;
    data['ocrStatus'] = this.ocrStatus;
    data['fileName'] = this.fileName;
    data['path'] = this.path;
    data['thumbnailUrl'] = this.thumbnailUrl;
    data['extension'] = this.extension;
    data['ocrResult'] = this.ocrResult;
    data['ocrDate'] = this.ocrDate;
    data['moduleType'] = this.moduleType;
    data['userId'] = this.userId;
    data['customerId'] = this.customerId;
    data['todoId'] = this.todoId;
    data['projectId'] = this.projectId;
    data['createDate'] = this.createDate;
    data['ocrStatusText'] = this.ocrStatusText;
    data['folderName'] = this.folderName;
    data['totalFileCount'] = this.totalFileCount;
    return data;
  }
}