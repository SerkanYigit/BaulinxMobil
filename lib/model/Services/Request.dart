import 'package:undede/model/Adress/Adress.dart';
import 'package:undede/model/CityServiceCountry/CityServiceCountry.dart';
import 'package:undede/model/User/UserData.dart';
class RequestList {
  int? statusCode;
  Null exceptionInfo;
  Null pageSortSearch;
  bool? hasError;
  List<Request>? data;

  RequestList(
      {this.statusCode,
        this.exceptionInfo,
        this.pageSortSearch,
        this.hasError,
        this.data});

  RequestList.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    exceptionInfo = json['exceptionInfo'];
    pageSortSearch = json['pageSortSearch'];
    hasError = json['hasError'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new Request.fromJson(v));
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

class Request {
  int? id;
  UserData? user;
  Category? service;
  AdressData? adress;
  String? title;
  List<Images>? images;
  String? description;
  String? createDate;
  String? deadline;
  int? isDeleted;
  int? jetonRequestOfferPrice;
  int? status;


  Request(
      {this.id =0,
        this.user,
        this.service,
        this.adress,
        this.title,
        this.images,
        this.description,
        this.createDate,
        this.jetonRequestOfferPrice,
        this.status,
        this.isDeleted =0,
        this.deadline});

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new UserData.fromJson(json['user']) : null;
    service =
    json['service'] != null ? new Category.fromJson(json['service']) : null;
    adress =
    json['adress'] != null ? new AdressData.fromJson(json['adress']) : null;
    title = json['title'];
    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
    description = json['description'];
    createDate = json['createDate'];
    deadline = json['deadline'];
    jetonRequestOfferPrice = json['jeton_RequestOfferPrice'];
    status = json['status'];
    isDeleted = json['isDeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id??0;
    data['user'] = this.user!.toJson();
      data['service'] = this.service!.toJson();
      data['adress'] = this.adress!.toJson();
      data['title'] = this.title;
    data['images'] = this.images!.map((v) => v.toJson()).toList();
      data['description'] = this.description;
    data['createDate'] = this.createDate;
    data['jeton_RequestOfferPrice'] = this.jetonRequestOfferPrice;
    data['status'] = this.status;
    data['deadline'] = this.deadline??"";
    data['isDeleted'] = this.isDeleted??0;
    return data;
  }
}


class Images {
  int? id;
  String? image;
  String? base64;

  Images({this.id =0, this.image, this.base64});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id']??0;
    image = json['image'];
    base64 = json['base64'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id??0;
    data['image'] = this.image??"";
    data['base64'] = this.base64??"";
    return data;
  }
}
