class CustomersBillsResult {
  List<CustomerBill>? result;

  CustomersBillsResult({this.result, required bool hasError});

  CustomersBillsResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <CustomerBill>[];
      json['Result'].forEach((v) {
        result!.add(new CustomerBill.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      return data;
  }
}

class CustomerBill {
  int? id;
  int? userId;
  int? customerId;
  String? billName;
  String? billAddress;
  String? billUserName;

  CustomerBill(
      {this.id,
      this.userId,
      this.customerId,
      this.billName,
      this.billAddress,
      this.billUserName, required bool hasError});

  CustomerBill.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    userId = json['UserId'];
    customerId = json['CustomerId'];
    billName = json['BillName'];
    billAddress = json['BillAddress'];
    billUserName = json['BillUserName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['UserId'] = this.userId;
    data['CustomerId'] = this.customerId;
    data['BillName'] = this.billName;
    data['BillAddress'] = this.billAddress;
    data['BillUserName'] = this.billUserName;
    return data;
  }
}
