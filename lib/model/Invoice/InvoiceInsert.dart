class InvoiceHistoryResult {
  String? version;
  bool? hasError;
  String? resultCode;
  String? resultMessage;
  Null authenticationToken;
  List<HistoryResult>? historyResult;
  Null header;

  InvoiceHistoryResult(
      {this.version,
      this.hasError,
      this.resultCode,
      this.resultMessage,
      this.authenticationToken,
      this.historyResult,
      this.header});

  InvoiceHistoryResult.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    if (json['Result'] != null) {
      historyResult = <HistoryResult>[];
      json['Result'].forEach((v) {
        historyResult!.add(new HistoryResult.fromJson(v));
      });
    }
    header = json['Header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Version'] = this.version;
    data['HasError'] = this.hasError;
    data['ResultCode'] = this.resultCode;
    data['ResultMessage'] = this.resultMessage;
    data['AuthenticationToken'] = this.authenticationToken;
    data['Result'] = this.historyResult!.map((v) => v.toJson()).toList();
      data['Header'] = this.header;
    return data;
  }
}

class HistoryResult {
  int? id;
  int? fileId;
  int? customerId;
  int? accountTypeId;
  int? type;
  String? invoiceName;
  String? invoiceNumber;
  String? date;
  int? year;
  int? month;
  int? day;
  double? taxFreeAmount;
  double? tax;
  double? taxAddAmount;
  int? invoiceTargetAccountId;
  int? invoiceBlock;
  num? taxAccountId;
  double? taxAmount;
  int? isDeleted;
  String? description;
  String? createDate;
  int? createUser;
  int? status;
  InvoiceFile? file;
  bool? handCreatedInvoice;

  HistoryResult(
      {this.id,
      this.fileId,
      this.customerId,
      this.accountTypeId,
      this.type,
      this.invoiceName,
      this.invoiceNumber,
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
      this.file,
      this.handCreatedInvoice});

  HistoryResult.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    fileId = json['FileId'];
    customerId = json['CustomerId'];
    accountTypeId = json['AccountTypeId'];
    type = json['Type'];
    invoiceName = json['InvoiceName'];
    invoiceNumber = json['InvoiceNumber'];
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
    createUser = json['CreateUser'];
    status = json['Status'];
    file = json['File'] != null ? new InvoiceFile.fromJson(json['File']) : null;
    handCreatedInvoice = json['HandCreatedInvoice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['FileId'] = this.fileId;
    data['CustomerId'] = this.customerId;
    data['AccountTypeId'] = this.accountTypeId;
    data['Type'] = this.type;
    data['InvoiceName'] = this.invoiceName;
    data['InvoiceNumber'] = this.invoiceNumber;

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
    data['File'] = this.file!.toJson();
      data['HandCreatedInvoice'] = this.handCreatedInvoice;
    return data;
  }
}

class InvoiceFile {
  int? id;
  String? path;
  String? thumbnailPath;
  String? fileName;
  String? createDate;
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
