import 'package:undede/model/Invoice/InvoiceFileInsertFiles.dart';

class InsertOfferResult {
  InsertOfferItem? result;

  InsertOfferResult({this.result, required bool hasError});

  InsertOfferResult.fromJson(Map<String, dynamic> json) {
    result = json['Result'] != null
        ? new InsertOfferItem.fromJson(json['Result'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.toJson();
      return data;
  }
}

class InsertOfferItem {
  int? id;
  int? fileId;
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
  InvoiceFileInsertFiles? files;
  String? offerNumber;
  InsertOfferItem(
      {this.id,
      this.fileId,
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
      this.files,
      this.offerNumber});

  InsertOfferItem.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    fileId = json['FileId'];
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
    files = json['Files'] != null
        ? new InvoiceFileInsertFiles.fromJson(json['Files'])
        : null;
    offerNumber = json["OfferNumber"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['FileId'] = this.fileId;
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
    data['Files'] = this.files!.toJson();
      data['OfferNumber'] = this.offerNumber;
    return data;
  }
}
