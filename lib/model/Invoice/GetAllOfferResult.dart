class GetAllOfferResult {
  List<Result>? result;

  GetAllOfferResult({this.result, required bool hasError});

  GetAllOfferResult.fromJson(Map<String, dynamic> json) {
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
  int? fileId;
  String? fileUrl;
  String? fileThumbNailUrl;
  int? customerId;
  String? offerName;
  String? date;
  int? year;
  int? month;
  int? day;
  double? taxFreeAmount;
  double? tax;
  double? taxAddAmount;
  double? taxAmount;
  String? createDate;
  int? createUser;
  int? createdForUserId;
  bool? myCustomer;
  String? offerNumber;

  Result(
      {this.id,
      this.fileId,
      this.fileUrl,
      this.fileThumbNailUrl,
      this.customerId,
      this.offerName,
      this.date,
      this.year,
      this.month,
      this.day,
      this.taxFreeAmount,
      this.tax,
      this.taxAddAmount,
      this.taxAmount,
      this.createDate,
      this.createUser,
      this.createdForUserId,
      this.myCustomer,
      this.offerNumber});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    fileId = json['FileId'];
    fileUrl = json['FileUrl'];
    fileThumbNailUrl = json['FileThumbNailUrl'];
    customerId = json['CustomerId'];
    offerName = json['OfferName'];
    date = json['Date'];
    year = json['Year'];
    month = json['Month'];
    day = json['Day'];
    taxFreeAmount = json['TaxFreeAmount'];
    tax = json['Tax'];
    taxAddAmount = json['TaxAddAmount'];
    taxAmount = json['TaxAmount'];
    createDate = json['CreateDate'];
    createUser = json['CreateUser'];
    createdForUserId = json['CreatedForUserId'];
    myCustomer = json['MyCustomer'];
    offerNumber = json['OfferNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['FileId'] = this.fileId;
    data['FileUrl'] = this.fileUrl;
    data['FileThumbNailUrl'] = this.fileThumbNailUrl;
    data['CustomerId'] = this.customerId;
    data['OfferName'] = this.offerName;
    data['Date'] = this.date;
    data['Year'] = this.year;
    data['Month'] = this.month;
    data['Day'] = this.day;
    data['TaxFreeAmount'] = this.taxFreeAmount;
    data['Tax'] = this.tax;
    data['TaxAddAmount'] = this.taxAddAmount;
    data['TaxAmount'] = this.taxAmount;
    data['CreateDate'] = this.createDate;
    data['CreateUser'] = this.createUser;
    data['CreatedForUserId'] = this.createdForUserId;
    data['MyCustomer'] = this.myCustomer;
    data['OfferNumber'] = this.offerNumber;

    return data;
  }
}
