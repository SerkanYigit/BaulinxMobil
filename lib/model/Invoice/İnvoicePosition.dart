class InvoicePositionResult {
  List<InvoicePosition>? result;

  InvoicePositionResult({this.result, required bool hasError});

  InvoicePositionResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <InvoicePosition>[];
      json['Result'].forEach((v) {
        result!.add(new InvoicePosition.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      return data;
  }
}

class InvoicePosition {
  int? id;
  int? invoiceId;
  String? positionName;
  double? quantity;
  int? quantityType;
  double? unitPrice;
  int? vat;

  InvoicePosition(
      {this.id,
      this.invoiceId,
      this.positionName,
      this.quantity,
      this.quantityType,
      this.unitPrice,
      this.vat});

  InvoicePosition.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    invoiceId = json['InvoiceId'];
    positionName = json['PositionName'];
    quantity = json['Quantity'];
    quantityType = json['QuantityType'];
    unitPrice = json['UnitPrice'];
    vat = json['Vat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['InvoiceId'] = this.invoiceId;
    data['PositionName'] = this.positionName;
    data['Quantity'] = this.quantity;
    data['QuantityType'] = this.quantityType;
    data['UnitPrice'] = this.unitPrice;
    data['Vat'] = this.vat;
    return data;
  }
}
