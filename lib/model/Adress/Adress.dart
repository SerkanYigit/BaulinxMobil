import 'package:undede/model/CityServiceCountry/CityServiceCountry.dart';
import 'package:undede/model/User/UserData.dart';

class Adress {
  int? statusCode;
  Null exceptionInfo;
  Null pageSortSearch;
  bool? hasError;
  List<AdressData>? data;

  Adress(
      {this.statusCode,
        this.exceptionInfo,
        this.pageSortSearch,
        this.hasError,
        this.data});

  Adress.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    exceptionInfo = json['exceptionInfo'];
    pageSortSearch = json['pageSortSearch'];
    hasError = json['hasError'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new AdressData.fromJson(v));
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

class AdressData {
  int? id;
  UserData? user;
  City? country;
  City? city;
  District? district;
  Street? street;
  String? title;
  String? description;
  String? zipCode;
  String? firstname;
  String? lastname;
  String? phoneNumber;
  String? latitude;
  String? longitude;
  int? isDeleted;
  String? createDate;
  String? deleteDate;
  String? modifiedDate;

  AdressData(
      {this.id =0,
        this.user,
        this.country,
        this.city,
        this.street,
        this.district,
        this.title,
        this.description,
        this.zipCode,
        this.firstname,
        this.lastname,
        this.phoneNumber,
        this.latitude,
        this.longitude,
        this.isDeleted =0,
        this.createDate,
        this.deleteDate,
        this.modifiedDate});

  AdressData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new UserData.fromJson(json['user']) : null;
    country =
    json['country'] != null ? new City.fromJson(json['country']) : null;
    city = json['city'] != null ? new City.fromJson(json['city']) : null;
    district = json['district'] != null
        ? new District.fromJson(json['district'])
        : null;
    street = json['street'] != null
        ? new Street.fromJson(json['street'])
        : null;
    title = json['title'];
    description = json['description'];
    zipCode = json['zipCode'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    phoneNumber = json['phoneNumber'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    isDeleted = json['isDeleted'];
    createDate = json['createDate'];
    deleteDate = json['deleteDate'];
    modifiedDate = json['modifiedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id??0;
    data['user'] = this.user!.toJson();
  
    data['country'] = this.country!.toJson();
      data['city'] = this.city!.toJson();
      data['district'] = this.district!.toJson();
      data['street'] = this.street!.toJson();
      data['title'] = this.title;
    data['description'] = this.description;
    data['zipCode'] = this.zipCode??"";
    data['firstname'] = this.firstname??"";
    data['lastname'] = this.lastname??"";
    data['phoneNumber'] = this.phoneNumber??"";
    data['latitude'] = this.latitude??"";
    data['longitude'] = this.longitude??"";
    data['isDeleted'] = this.isDeleted??0;
    data['createDate'] = this.createDate??"2019-01-06T17:16:40";
    data['deleteDate'] = this.deleteDate??"2019-01-06T17:16:40";
    data['modifiedDate'] = this.modifiedDate??"2019-01-06T17:16:40";
    return data;
  }

  @override
  String toString() {
    return 'AdressData{id: $id, user: $user, country: $country, city: $city, district: $district, title: $title, description: $description, zipCode: $zipCode, firstname: $firstname, lastname: $lastname, phoneNumber: $phoneNumber, latitude: $latitude, longitude: $longitude, isDeleted: $isDeleted, createDate: $createDate, deleteDate: $deleteDate, modifiedDate: $modifiedDate}';
  }
}
