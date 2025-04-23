class GetInvoiceSummaryResult {
  Result? result;

  GetInvoiceSummaryResult({this.result, required bool hasError});

  GetInvoiceSummaryResult.fromJson(Map<String, dynamic> json) {
    result =
        json['Result'] != null ? new Result.fromJson(json['Result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.toJson();
      return data;
  }
}

class Result {
  int? totalCount;
  double? totalAmount;

  Result({this.totalCount, this.totalAmount});

  Result.fromJson(Map<String, dynamic> json) {
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
