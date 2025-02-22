class GetInvoicePeriodListResult {
  List<Result>? result;

  GetInvoicePeriodListResult({this.result, required bool hasError});

  GetInvoicePeriodListResult.fromJson(Map<String, dynamic> json) {
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
  int? customerId;
  int? year;
  int? month;
  String? monthName;
  int? status;

  Result(
      {this.id,
      this.customerId,
      this.year,
      this.month,
      this.monthName,
      this.status});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    customerId = json['CustomerId'];
    year = json['Year'];
    month = json['Month'];
    monthName = json['MonthName'];
    status = json['Status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CustomerId'] = this.customerId;
    data['Year'] = this.year;
    data['Month'] = this.month;
    data['MonthName'] = this.monthName;
    data['Status'] = this.status;
    return data;
  }
}
