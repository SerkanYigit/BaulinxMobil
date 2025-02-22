import 'package:get/get.dart';
import 'package:undede/Services/CustomersBills/CustomersBillsBase.dart';
import 'package:undede/Services/CustomersBills/CustomersBillsDB.dart';
import 'package:undede/model/CustomersBills/CustomersBillsResult.dart';

class ControllerCustomersBills extends GetxController
    implements CustomersBillsBase {
  CustomersBillsDB _billsDB = CustomersBillsDB();
  List<CustomerBill> customerBills = [];

  @override
  Future<bool> DeleteCustomersBill(Map<String, String> header, {int? Id}) async {
    return await _billsDB.DeleteCustomersBill(header, Id: Id!);
  }

  @override
  Future<CustomersBillsResult> GetAllCustomersBills(Map<String, String> header,
      {int? userId, int? customerId}) async {
    var value = await _billsDB.GetAllCustomersBills(header,
        userId: userId!, customerId: customerId!);
    customerBills = value.result!;
    update();
    return value;
  }

  @override
  Future<CustomerBill> InsertOrUpdateCustomersBill(Map<String, String> header,
      {int? Id,
      int? UserId,
      int? CustomerId,
      String? BillName,
      String? BillAddress,
      String? BillUserName}) async {
    return await _billsDB.InsertOrUpdateCustomersBill(header,
        Id: Id!,
        UserId: UserId!,
        CustomerId: CustomerId!,
        BillName: BillName!,
        BillAddress: BillAddress!,
        BillUserName: BillUserName!);
  }
}
