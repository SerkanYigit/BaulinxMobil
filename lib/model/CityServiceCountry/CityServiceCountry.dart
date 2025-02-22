class Csc {
  int? statusCode;
  Null exceptionInfo;
  Null pageSortSearch;
  bool? hasError;
  List<City>? data;

  Csc(
      {this.statusCode,
        this.exceptionInfo,
        this.pageSortSearch,
        this.hasError,
        this.data});

  Csc.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    exceptionInfo = json['exceptionInfo'];
    pageSortSearch = json['pageSortSearch'];
    hasError = json['hasError'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new City.fromJson(v));
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

class City {
  int? id;
  String? name;

  City({this.id, this.name});

  City.fromJson(Map<String, dynamic> json) {
    id = json['id']??0;
    name = json['name']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }

  @override
  String toString() {
    return 'CscData{id: $id, name: $name}';
  }
}






//Districtt

class DistrictList {
  int? statusCode;
  Null exceptionInfo;
  Null pageSortSearch;
  bool? hasError;
  List<District>? data;

  DistrictList(
      {this.statusCode,
        this.exceptionInfo,
        this.pageSortSearch,
        this.hasError,
        this.data});

  DistrictList.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    exceptionInfo = json['exceptionInfo'];
    pageSortSearch = json['pageSortSearch'];
    hasError = json['hasError'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new District.fromJson(v));
      });
    }
  }


}




class District {
  int? id;
  String? name;
  int? cityId;

  District({this.id, this.name,this.cityId});

  District.fromJson(Map<String, dynamic> json) {
    id = json['id']??0;
    name = json['name']??"";
    cityId = json['cityId']??0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id??0;
    data['name'] = this.name??"";
    data['cityId'] = this.cityId??0;
    return data;
  }

  @override
  String toString() {
    return 'District{id: $id, name: $name, cityId: $cityId}';
  }
}


//Street
class StreetList {
  int? statusCode;
  Null exceptionInfo;
  Null pageSortSearch;
  bool? hasError;
  List<Street>? data;

  StreetList(
      {this.statusCode,
        this.exceptionInfo,
        this.pageSortSearch,
        this.hasError,
        this.data});

  StreetList.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    exceptionInfo = json['exceptionInfo'];
    pageSortSearch = json['pageSortSearch'];
    hasError = json['hasError'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new Street.fromJson(v));
      });
    }
  }


}

class Street {
  int? id;
  String? name;
  int? districtId;

  Street({this.id, this.name,this.districtId});

  Street.fromJson(Map<String, dynamic> json) {
    id = json['id']??0;
    name = json['name']??"";
    districtId = json['districtId']??0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id??0;
    data['name'] = this.name??"";
    data['districtId'] = this.districtId??0;
    return data;
  }

  @override
  String toString() {
    return 'District{id: $id, name: $name, districtId: $districtId}';
  }
}

class CategoryList {
  int? statusCode;
  Null exceptionInfo;
  Null pageSortSearch;
  bool? hasError;
  List<Category>? data;

  CategoryList(
      {this.statusCode,
        this.exceptionInfo,
        this.pageSortSearch,
        this.hasError,
        this.data});

  CategoryList.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    exceptionInfo = json['exceptionInfo'];
    pageSortSearch = json['pageSortSearch'];
    hasError = json['hasError'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new Category.fromJson(v));
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

class Category {
  int? id;
  int? parentId;
  String? name;
  String? photo;
  bool checkedForFilter = false;

  Category({this.id, this.parentId, this.name,this.photo});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parentId'];
    name = json['name'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['photo'] = this.photo;
    data['parentServiceId'] = this.parentId;
    data['name'] = this.name;
    return data;
  }
}






