import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:undede/Services/CustomersBills/CustomersBillsBase.dart';
import 'package:undede/model/CustomersBills/CustomersBillsResult.dart';
import '../ServiceUrl.dart';

class CustomersBillsDB implements CustomersBillsBase {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<bool> DeleteCustomersBill(Map<String, String> header, {int? Id}) async {
    var reqBody = jsonEncode({"Id": Id});
    var response = await http.post(Uri.parse(_serviceUrl.deleteCustomersBill),
        headers: header, body: reqBody);

    log("req DeleteCustomersBill = " + reqBody);
    log("res DeleteCustomersBill = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return responseData["Result"];
    }
  }

  @override
  Future<CustomersBillsResult> GetAllCustomersBills(Map<String, String> header,
      {int? userId, int? customerId}) async {
    var reqBody = jsonEncode({"UserId": userId, "CustomerId": customerId});
    var response = await http.post(Uri.parse(_serviceUrl.getCustomersBills),
        headers: header, body: reqBody);

    log("req CustomersBillsResult = " + reqBody);
    log("res CustomersBillsResult = " + response.body);

    if (response.body.isEmpty) {
      return CustomersBillsResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return CustomersBillsResult.fromJson(responseData);
    }
  }

  @override
  Future<CustomerBill> InsertOrUpdateCustomersBill(Map<String, String> header,
      {int? Id,
      int? UserId,
      int? CustomerId,
      String? BillName,
      String? BillAddress,
      String? BillUserName}) async {
    var reqBody = jsonEncode({
      "Id": Id,
      "UserId": UserId,
      "CustomerId": CustomerId,
      "BillName": BillName,
      "BillAddress": BillAddress,
      "BillUserName": BillUserName
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.insertOrUpdateCustomersBills),
        headers: header,
        body: reqBody);

    log("req InsertOrUpdateCustomersBill = " + reqBody);
    log("res InsertOrUpdateCustomersBill = " + response.body);

    if (response.body.isEmpty) {
      return CustomerBill(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return CustomerBill.fromJson(responseData);
    }
  }
}
