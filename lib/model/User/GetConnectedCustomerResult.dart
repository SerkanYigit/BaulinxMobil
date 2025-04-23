class GetConnectedCustomerResult {
  List<GetConnectedCustomerItem>? result;

  GetConnectedCustomerResult({this.result, required bool hasError});

  GetConnectedCustomerResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <GetConnectedCustomerItem>[];
      json['Result'].forEach((v) {
        result!.add(new GetConnectedCustomerItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      return data;
  }
}

class GetConnectedCustomerItem {
  int? id;
  int? userId;
  int? customerId;
  String? customerName;

  GetConnectedCustomerItem(
      {this.id, this.userId, this.customerId, this.customerName, required bool hasError});

  GetConnectedCustomerItem.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    userId = json['UserId'];
    customerId = json['CustomerId'];
    customerName = json['CustomerName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['UserId'] = this.userId;
    data['CustomerId'] = this.customerId;
    data['CustomerName'] = this.customerName;
    return data;
  }
}
