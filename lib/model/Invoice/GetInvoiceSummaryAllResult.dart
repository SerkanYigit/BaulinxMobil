class InvoiceSummaryAllResult {
  Result? result;

  InvoiceSummaryAllResult({this.result, required bool hasError});

  InvoiceSummaryAllResult.fromJson(Map<String, dynamic> json) {
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
  List<InvoiceSummaryResponse>? invoiceSummaryResponse;
  InvoiceSummariesIncomePaid2? invoiceSummariesIncomePaid2Summary;
  InvoiceSummariesIncomePaid2? invoiceSummariesOutGoingPaid4Summary;
  InvoiceSummariesIncomeUnPaid1? invoiceSummariesIncomeUnPaid1Summary;
  InvoiceSummariesIncomeUnPaid1? invoiceSummariesOutGoingUnPaid3Summary;

  Result(
      {this.invoiceSummaryResponse,
      this.invoiceSummariesIncomePaid2Summary,
      this.invoiceSummariesOutGoingPaid4Summary,
      this.invoiceSummariesIncomeUnPaid1Summary,
      this.invoiceSummariesOutGoingUnPaid3Summary});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['InvoiceSummaryResponse'] != null) {
      invoiceSummaryResponse = <InvoiceSummaryResponse>[];
      json['InvoiceSummaryResponse'].forEach((v) {
        invoiceSummaryResponse!.add(new InvoiceSummaryResponse.fromJson(v));
      });
    }
    invoiceSummariesIncomePaid2Summary =
        json['InvoiceSummariesIncomePaid2Summary'] != null
            ? new InvoiceSummariesIncomePaid2.fromJson(
                json['InvoiceSummariesIncomePaid2Summary'])
            : null;
    invoiceSummariesOutGoingPaid4Summary =
        json['InvoiceSummariesOutGoingPaid4Summary'] != null
            ? new InvoiceSummariesIncomePaid2.fromJson(
                json['InvoiceSummariesOutGoingPaid4Summary'])
            : null;
    invoiceSummariesIncomeUnPaid1Summary =
        json['InvoiceSummariesIncomeUnPaid1Summary'] != null
            ? new InvoiceSummariesIncomeUnPaid1.fromJson(
                json['InvoiceSummariesIncomeUnPaid1Summary'])
            : null;
    invoiceSummariesOutGoingUnPaid3Summary =
        json['InvoiceSummariesOutGoingUnPaid3Summary'] != null
            ? new InvoiceSummariesIncomeUnPaid1.fromJson(
                json['InvoiceSummariesOutGoingUnPaid3Summary'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['InvoiceSummaryResponse'] =
        this.invoiceSummaryResponse!.map((v) => v.toJson()).toList();
      data['InvoiceSummariesIncomePaid2Summary'] =
        this.invoiceSummariesIncomePaid2Summary!.toJson();
      data['InvoiceSummariesOutGoingPaid4Summary'] =
        this.invoiceSummariesOutGoingPaid4Summary!.toJson();
      data['InvoiceSummariesIncomeUnPaid1Summary'] =
        this.invoiceSummariesIncomeUnPaid1Summary!.toJson();
      data['InvoiceSummariesOutGoingUnPaid3Summary'] =
        this.invoiceSummariesOutGoingUnPaid3Summary!.toJson();
      return data;
  }
}

class InvoiceSummaryResponse {
  InvoiceSummariesIncomePaid2? invoiceSummariesIncomePaid2;
  InvoiceSummariesIncomePaid2? invoiceSummariesOutGoingPaid4;
  InvoiceSummariesIncomeUnPaid1? invoiceSummariesIncomeUnPaid1;
  InvoiceSummariesIncomeUnPaid1? invoiceSummariesOutGoingUnPaid3;
  int? month;

  InvoiceSummaryResponse(
      {this.invoiceSummariesIncomePaid2,
      this.invoiceSummariesOutGoingPaid4,
      this.invoiceSummariesIncomeUnPaid1,
      this.invoiceSummariesOutGoingUnPaid3,
      this.month});

  InvoiceSummaryResponse.fromJson(Map<String, dynamic> json) {
    invoiceSummariesIncomePaid2 = json['InvoiceSummariesIncomePaid2'] != null
        ? new InvoiceSummariesIncomePaid2.fromJson(
            json['InvoiceSummariesIncomePaid2'])
        : null;
    invoiceSummariesOutGoingPaid4 =
        json['InvoiceSummariesOutGoingPaid4'] != null
            ? new InvoiceSummariesIncomePaid2.fromJson(
                json['InvoiceSummariesOutGoingPaid4'])
            : null;
    invoiceSummariesIncomeUnPaid1 =
        json['InvoiceSummariesIncomeUnPaid1'] != null
            ? new InvoiceSummariesIncomeUnPaid1.fromJson(
                json['InvoiceSummariesIncomeUnPaid1'])
            : null;
    invoiceSummariesOutGoingUnPaid3 =
        json['InvoiceSummariesOutGoingUnPaid3'] != null
            ? new InvoiceSummariesIncomeUnPaid1.fromJson(
                json['InvoiceSummariesOutGoingUnPaid3'])
            : null;
    month = json['Month'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['InvoiceSummariesIncomePaid2'] =
        this.invoiceSummariesIncomePaid2!.toJson();
      data['InvoiceSummariesOutGoingPaid4'] =
        this.invoiceSummariesOutGoingPaid4!.toJson();
      data['InvoiceSummariesIncomeUnPaid1'] =
        this.invoiceSummariesIncomeUnPaid1!.toJson();
      data['InvoiceSummariesOutGoingUnPaid3'] =
        this.invoiceSummariesOutGoingUnPaid3!.toJson();
      data['Month'] = this.month;
    return data;
  }
}

class InvoiceSummariesIncomePaid2 {
  num? totalCount;
  num? totalAmount;
  num? totalTax;
  num? totalTaxFreeAmount;

  InvoiceSummariesIncomePaid2(
      {this.totalCount,
      this.totalAmount,
      this.totalTax,
      this.totalTaxFreeAmount});

  InvoiceSummariesIncomePaid2.fromJson(Map<String, dynamic> json) {
    totalCount = json['TotalCount'];
    totalAmount = json['TotalAmount'];
    totalTax = json['TotalTax'];
    totalTaxFreeAmount = json['TotalTaxFreeAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TotalCount'] = this.totalCount;
    data['TotalAmount'] = this.totalAmount;
    data['TotalTax'] = this.totalTax;
    data['TotalTaxFreeAmount'] = this.totalTaxFreeAmount;
    return data;
  }
}

class InvoiceSummariesIncomeUnPaid1 {
  num? totalCount;
  num? totalAmount;
  num? totalTax;
  num? totalTaxFreeAmount;

  InvoiceSummariesIncomeUnPaid1(
      {this.totalCount,
      this.totalAmount,
      this.totalTax,
      this.totalTaxFreeAmount});

  InvoiceSummariesIncomeUnPaid1.fromJson(Map<String, dynamic> json) {
    totalCount = json['TotalCount'];
    totalAmount = json['TotalAmount'];
    totalTax = json['TotalTax'];
    totalTaxFreeAmount = json['TotalTaxFreeAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TotalCount'] = this.totalCount;
    data['TotalAmount'] = this.totalAmount;
    data['TotalTax'] = this.totalTax;
    data['TotalTaxFreeAmount'] = this.totalTaxFreeAmount;
    return data;
  }
}
