import 'package:intl/intl.dart';
import 'package:undede/model/Common/DataLayoutAPI.dart';
import 'package:undede/model/Files/FileLabel.dart';

class GetInvoiceListResult extends DataLayoutAPI {
  Result? result;

  GetInvoiceListResult({this.result, required bool hasError});

  GetInvoiceListResult.fromJson(Map<String, dynamic> json) {
    result =
        json['Result'] != null ? new Result.fromJson(json['Result']) : null;

    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    header = json['Header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.toJson();
      return data;
  }
}

class Result {
  int? totalPage;
  int? selectedPage;
  int? size;
  List<Invoice>? invoiceListResponse;
  InvoiceSummary? invoiceSummary;

  Result(
      {this.totalPage,
      this.selectedPage,
      this.size,
      this.invoiceListResponse,
      this.invoiceSummary});

  Result.fromJson(Map<String, dynamic> json) {
    totalPage = json['TotalPage'];
    selectedPage = json['SelectedPage'];
    size = json['Size'];
    if (json['InvoiceListResponse'] != null) {
      invoiceListResponse = <Invoice>[];
      json['InvoiceListResponse'].forEach((v) {
        invoiceListResponse!.add(new Invoice.fromJson(v));
      });
    }
    invoiceSummary = json['InvoiceSummary'] != null
        ? new InvoiceSummary.fromJson(json['InvoiceSummary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TotalPage'] = this.totalPage;
    data['SelectedPage'] = this.selectedPage;
    data['Size'] = this.size;
    data['InvoiceListResponse'] =
        this.invoiceListResponse!.map((v) => v.toJson()).toList();
      data['InvoiceSummary'] = this.invoiceSummary!.toJson();
      return data;
  }
}

class Invoice {
  int? id;
  int? fileId;
  int? customerId;
  int? accountTypeId;
  int? type;
  String? invoiceName;
  String? date;
  int? year;
  int? month;
  int? day;
  num? taxFreeAmount;
  num? tax;
  double? taxAddAmount;
  int? invoiceTargetAccountId;
  int? invoiceBlock;
  int? taxAccountId;
  num? taxAmount;
  int? isDeleted;
  String? description;
  String? createDate;
  DateTime? createDateTime;
  int? createUser;
  int? status;
  int? totalPage;
  InvoiceFile? file;
  FileLabel? todoLabels;
  bool? handCreatedInvoice;
  Invoice(
      {this.id,
      this.fileId,
      this.customerId,
      this.accountTypeId,
      this.type,
      this.invoiceName,
      this.date,
      this.year,
      this.month,
      this.day,
      this.taxFreeAmount,
      this.tax,
      this.taxAddAmount,
      this.invoiceTargetAccountId,
      this.invoiceBlock,
      this.taxAccountId,
      this.taxAmount,
      this.isDeleted,
      this.description,
      this.createDate,
      this.createUser,
      this.status,
      this.totalPage,
      this.file,
      this.handCreatedInvoice});

  Invoice.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    fileId = json['FileId'];
    customerId = json['CustomerId'];
    accountTypeId = json['AccountTypeId'];
    type = json['Type'];
    invoiceName = json['InvoiceName'];
    date = json['Date'];
    year = json['Year'];
    month = json['Month'];
    day = json['Day'];
    taxFreeAmount = json['TaxFreeAmount'];
    tax = json['Tax'];
    taxAddAmount = json['TaxAddAmount'];
    invoiceTargetAccountId = json['InvoiceTargetAccountId'];
    invoiceBlock = json['InvoiceBlock'];
    taxAccountId = json['TaxAccountId'];
    taxAmount = json['TaxAmount'];
    isDeleted = json['IsDeleted'];
    description = json['Description'];
    createDate = json['CreateDate'];
    createDateTime = new DateFormat("yyyy-MM-ddThh:mm").parse(createDate!);
    createUser = json['CreateUser'];
    status = json['Status'];
    totalPage = json['TotalPage'];
    handCreatedInvoice = json['HandCreatedInvoice'];
    file = json['File'] != null ? new InvoiceFile.fromJson(json['File']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['FileId'] = this.fileId;
    data['CustomerId'] = this.customerId;
    data['AccountTypeId'] = this.accountTypeId;
    data['Type'] = this.type;
    data['InvoiceName'] = this.invoiceName;
    data['Date'] = this.date;
    data['Year'] = this.year;
    data['Month'] = this.month;
    data['Day'] = this.day;
    data['TaxFreeAmount'] = this.taxFreeAmount;
    data['Tax'] = this.tax;
    data['TaxAddAmount'] = this.taxAddAmount;
    data['InvoiceTargetAccountId'] = this.invoiceTargetAccountId;
    data['InvoiceBlock'] = this.invoiceBlock;
    data['TaxAccountId'] = this.taxAccountId;
    data['TaxAmount'] = this.taxAmount;
    data['IsDeleted'] = this.isDeleted;
    data['Description'] = this.description;
    data['CreateDate'] = this.createDate;
    data['CreateUser'] = this.createUser;
    data['Status'] = this.status;
    data['TotalPage'] = this.totalPage;
    data['HandCreatedInvoice'] = this.handCreatedInvoice;
    data['File'] = this.file!.toJson();
      return data;
  }
}

class InvoiceFile {
  int? id;
  String? path;
  String? thumbnailPath;
  String? fileName;
  String? createDate;
  DateTime? createDateTime;
  String? extension;
  int? moduleType;

  InvoiceFile(
      {this.id,
      this.path,
      this.thumbnailPath,
      this.fileName,
      this.createDate,
      this.extension,
      this.moduleType});

  InvoiceFile.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    path = json['Path'];
    thumbnailPath = json['ThumbnailPath'];
    fileName = json['FileName'];
    createDate = json['CreateDate'];
    createDateTime = new DateFormat("yyyy-MM-ddThh:mm").parse(createDate!);
    extension = json['Extension'];
    moduleType = json['ModuleType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Path'] = this.path;
    data['ThumbnailPath'] = this.thumbnailPath;
    data['FileName'] = this.fileName;
    data['CreateDate'] = this.createDate;
    data['Extension'] = this.extension;
    data['ModuleType'] = this.moduleType;
    return data;
  }
}

class InvoiceSummary {
  int? totalCount;
  double? totalAmount;

  InvoiceSummary({this.totalCount, this.totalAmount});

  InvoiceSummary.fromJson(Map<String, dynamic> json) {
    totalCount = json['TotalCount'];
    totalAmount = json['TotalAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TotalCount'] = this.totalCount;
    data['TotalAmount'] = this.totalAmount;
    return data;
  }
}
