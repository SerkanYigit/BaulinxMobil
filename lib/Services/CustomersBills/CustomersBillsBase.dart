import 'package:undede/model/CustomersBills/CustomersBillsResult.dart';

abstract class CustomersBillsBase {
  Future<CustomersBillsResult> GetAllCustomersBills(
    Map<String, String> header, {
    int userId,
    int customerId,
  });
  Future<CustomerBill> InsertOrUpdateCustomersBill(Map<String, String> header,
      {int Id,
      int UserId,
      int CustomerId,
      String BillName,
      String BillAddress,
      String BillUserName});
  Future<bool> DeleteCustomersBill(Map<String, String> header, {int Id});
}
