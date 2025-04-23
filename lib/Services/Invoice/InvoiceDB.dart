import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Services/Invoice/InvoiceBase.dart';
import 'package:undede/model/Common/DataLayoutAPI.dart';
import 'package:undede/model/Invoice/%C4%B0nvoicePosition.dart';
import 'package:undede/model/Invoice/GetAccountTypeListResult.dart';
import 'package:undede/model/Invoice/GetAllOfferResult.dart';
import 'package:undede/model/Invoice/GetInvoiceListResult.dart';
import 'package:undede/model/Invoice/GetInvoicePeriodListResult.dart';
import 'package:undede/model/Invoice/GetInvoiceSummaryAllResult.dart';
import 'package:undede/model/Invoice/GetInvoiceSummaryResult.dart';
import 'package:undede/model/Invoice/GetInvoiceTargetAccountList.dart';
import 'package:undede/model/Invoice/GetTaxAccountListResult.dart';
import 'package:undede/model/Invoice/InsertOfferResult.dart';
import 'package:undede/model/Invoice/InvoiceFileInsertFiles.dart';
import 'package:dio/dio.dart';
import 'package:undede/model/Invoice/InvoiceInsert.dart';

import '../ServiceUrl.dart';

class InvoiceDB implements InvoiceBase {
  final ServiceUrl _serviceUrl = ServiceUrl();
  final ControllerDB _controllerDB = Get.put(ControllerDB());
  @override
  Future<GetInvoiceListResult> GetInvoiceList(Map<String, String> header,
      {int? userId,
      int? year,
      int? month,
      int? invoiceBlock,
      int? page,
      int? size,
      int? invoiceTargetAccountId,
      int? TaxAccountId,
      String? SearchDescription,
      double? WithTaxValue,
      double? WithOutTaxValue,
      int invoiceType = 0}) async {
    var responseBody = jsonEncode({
      "UserId": userId,
      "Year": year,
      "Month": month,
      "InvoiceBlock": invoiceBlock,
      "Page": page,
      "Size": size,
      "InvoiceTargetAccountId": invoiceTargetAccountId,
      "TaxAccountId": TaxAccountId,
      "SearchDescription": SearchDescription,
      "TaxAddAmount": WithTaxValue,
      "TaxFreeAmount": WithOutTaxValue,
      "InvoiceType": invoiceType
    });

    var response = await http.post(
        Uri.parse(_serviceUrl.getInvoiceListRequestUrl),
        headers: header,
        body: responseBody);

    log(response.request.toString());
    log(responseBody.toString());
    log("GetFilesByUserIdForDirectory = " + response.body);

    if (response.body.isEmpty) {
      return GetInvoiceListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetInvoiceListResult.fromJson(responseData);
    }
  }

  @override
  Future<bool> InvoiceFileInsert(Map<String, String> header,
      {int? Id,
      int? FileId,
      int? CustomerId,
      int? AccountTypeId,
      int? Type,
      String? InvoiceName,
      String? Date,
      int? Year,
      int? Month,
      int? Day,
      double? TaxFreeAmount,
      int? Tax,
      double? TaxAddAmount,
      int? InvoiceTargetAccountId,
      int? InvoiceBlock,
      int? TaxAccountId,
      double? TaxAmount,
      bool? IsDeleted,
      String? Description,
      String? CreateDate,
      int? CreateUser,
      int? Status,
      String? FileName,
      String? FileContent}) async {
    var responseBody = jsonEncode({
      "Id": Id,
      "FileId": FileId,
      "CustomerId": CustomerId,
      "AccountTypeId": AccountTypeId,
      "Type": Type,
      "InvoiceName": InvoiceName,
      "Date": Date,
      "Year": Year,
      "Month": Month,
      "Day": Day,
      "TaxFreeAmount": TaxFreeAmount,
      "Tax": Tax,
      "TaxAddAmount": TaxAddAmount,
      "InvoiceTargetAccountId": InvoiceTargetAccountId,
      "InvoiceBlock": InvoiceBlock,
      "TaxAccountId": TaxAccountId,
      "TaxAmount": TaxAmount,
      "IsDeleted": IsDeleted,
      "Description": Description,
      "CreateDate": CreateDate,
      "CreateUser": CreateUser,
      "Status": Status,
      "FileName": FileName,
      "FileContent": FileContent
    });

    var response = await http.post(Uri.parse(_serviceUrl.invoiceFileInsert),
        headers: header, body: responseBody);

    log(response.request.toString());
    log("req InvoiceFileInsert" + responseBody.toString());
    log("InvoiceFileInsert = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  @override
  Future<int> InvoiceFileListInsert(Map<String, String> header,
      {int? CustomerId,
      int? FileId,
      bool? IsDeleted,
      int? Status,
      String? Date,
      int? AccountTypeId,
      int? Type,
      int? Year,
      int? Month,
      int? InvoiceTargetAccountId,
      int? InvoiceBlock,
      String? CreateDate,
      int? CreateUser,
      InvoiceFileInsertFiles? Files,
      bool? IsCombine,
      String? CombineFileName}) async {
    var reqBody = jsonEncode({
      "CustomerId": CustomerId,
      "FileId": FileId,
      "IsDeleted": IsDeleted,
      "Status": Status,
      "Date": Date,
      "AccountTypeId": AccountTypeId,
      "Type": Type,
      "Year": Year,
      "Month": Month,
      "InvoiceTargetAccountId": InvoiceTargetAccountId,
      "InvoiceBlock": InvoiceBlock,
      "CreateDate": CreateDate,
      "CreateUser": CreateUser,
      "Files": Files?.toJson(),
      "IsCombine": IsCombine,
      "CombineFileName": CombineFileName,
    });
    var dio = Dio();
    final response = await dio.post((_serviceUrl.invoiceFileListInsert),
        options: Options(headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Bearer " + _controllerDB.token.value
        }),
        data: reqBody, onSendProgress: (i, j) {
      print("i değeri :" + i.toString() + "j değeri :" + j.toString());
    });

    //  var response = await http.post(Uri.parse(_serviceUrl.invoiceFileListInsert), headers: header, body: reqBody);
    log(response.data.toString());
    // log("Request InvoiceFileListInsert = " + reqBody);
    log("Response InvoiceFileListInsert = " + response.statusMessage.toString());
//!buraya bir bak mesaj ne geliyor
    if (response.statusMessage==false) {
      return 0;
    } else {
      //final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return 1;
    }
  }

  @override
  Future<GetInvoiceTargetAccountListResult> GetInvoiceTargetAccountList(
      Map<String, String> header,
      {int? UserId}) async {
    var response = await http.post(
        Uri.parse(_serviceUrl.getInvoiceTargetAccountList),
        headers: header,
        body: jsonEncode({'UserId': UserId}));

    log("GetInvoiceTargetAccountList = " + response.body);

    if (response.body.isEmpty) {
      return GetInvoiceTargetAccountListResult(hasError: true);
    } else {
      final responseData =
          GetInvoiceTargetAccountListResult.fromJson(jsonDecode(response.body));
      return responseData;
    }
  }

  @override
  Future<DataLayoutAPI> InvoiceMultiUpdate(Map<String, String> header,
      {int? UserId, List<Invoice>? InvoiceList}) async {
    var requestBody = jsonEncode({
      "UserId": UserId,
      "InvoiceList": InvoiceList?.map((e) => e.toJson()).toList()
    });

    var response = await http.post(Uri.parse(_serviceUrl.invoiceMultiUpdate),
        headers: header, body: requestBody);

    log("req InvoiceMultiUpdate" + requestBody);
    log("InvoiceMultiUpdate = " + response.body);

    if (response.body.isEmpty) {
      return DataLayoutAPI(hasError: true);
    } else {
      return DataLayoutAPI.fromJson(jsonDecode(response.body));
    }
  }

  @override
  Future<GetAccountTypeListResult> GetAccountTypeList(
      Map<String, String> header,
      {int? UserId,
      int? Type}) async {
    var requestBody = {"UserId": UserId, "Type": Type};

    print(requestBody);
    var response = await http.post(Uri.parse(_serviceUrl.getAccountTypeList),
        headers: header, body: jsonEncode(requestBody));

    log("GetAccountTypeList = " + response.body);

    if (response.body.isEmpty) {
      return GetAccountTypeListResult(hasError: true);
    } else {
      return GetAccountTypeListResult.fromJson(jsonDecode(response.body));
    }
  }

  @override
  Future<GetTaxAccountListResult> GetTaxAccountList(Map<String, String> header,
      {int? UserId, int? Type}) async {
    var requestBody = {"UserId": UserId, "Type": Type};

    print(requestBody);
    var response = await http.post(Uri.parse(_serviceUrl.getTaxAccountList),
        headers: header, body: jsonEncode(requestBody));

    log("GetTaxAccountList = " + response.body);

    if (response.body.isEmpty) {
      return GetTaxAccountListResult(hasError: true);
    } else {
      return GetTaxAccountListResult.fromJson(jsonDecode(response.body));
    }
  }

  @override
  Future DeleteInvoice(Map<String, String> header,
      {int? UserId, int? InvoiceId}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "InvoiceId": InvoiceId,
    });

    var response = await http.post(Uri.parse(_serviceUrl.deleteInvoice),
        headers: header, body: responseBody);

    log(responseBody.toString());
    log("DeleteInvoice = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  @override
  Future DeleteInvoiceList(Map<String, String> header,
      {int? UserId, List<int>? InvoiceIdList}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "InvoiceIdList": InvoiceIdList,
    });

    var response = await http.post(Uri.parse(_serviceUrl.deleteInvoiceList),
        headers: header, body: responseBody);

    log("DeleteInvoice = " + responseBody.toString());
    log("DeleteInvoice = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  @override
  Future ClosePeriod(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? Year,
      int? Month,
      bool? IsFileTransfer}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "Year": Year,
      "Month": Month,
      "IsFileTransfer": IsFileTransfer,
    });

    var response = await http.post(Uri.parse(_serviceUrl.closePeriod),
        headers: header, body: responseBody);

    log(responseBody.toString());
    log("ClosePeriod = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  @override
  Future<GetInvoicePeriodListResult> GetInvoicePeriodList(
      Map<String, String> header,
      {int? CustomerId,
      int? Year,
      String? Language}) async {
    var responseBody = jsonEncode({
      "CustomerId": CustomerId,
      "Year": Year,
      "Language": Language,
    });

    var response = await http.post(Uri.parse(_serviceUrl.getInvoicePeriodList),
        headers: header, body: responseBody);
    log("res GetInvoicePeriodList" + response.body.toString());
    if (response.body.isEmpty) {
      return GetInvoicePeriodListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetInvoicePeriodListResult.fromJson(responseData);
    }
  }

  @override
  Future<GetInvoiceSummaryResult> GetInvoiceSummary(Map<String, String> header,
      {int? userId,
      int? year,
      int? month,
      int? invoiceBlock,
      int? InvoiceTargetAccountId}) async {
    var reqBody = jsonEncode({
      "UserId": userId,
      "Year": year,
      "Month": month,
      "InvoiceBlock": invoiceBlock,
      "InvoiceTargetAccountId": InvoiceTargetAccountId
    });

    var response = await http.post(Uri.parse(_serviceUrl.getInvoiceSummary),
        headers: header, body: reqBody);

    log("req GetInvoiceSummaryResultbody" + reqBody.toString());
    log("res GetInvoiceSummaryResultbody" + response.body);

    if (response.body.isEmpty) {
      return GetInvoiceSummaryResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetInvoiceSummaryResult.fromJson(responseData);
    }
  }

  @override
  Future ConfirmPeriod(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? Year,
      int? Month,
      bool? IsFileTransfer}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "Year": Year,
      "Month": Month,
      "IsFileTransfer": IsFileTransfer,
    });

    var response = await http.post(Uri.parse(_serviceUrl.confirmPeriod),
        headers: header, body: responseBody);

    log(responseBody.toString());
    log("ClosePeriod = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  @override
  Future OpenPeriod(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? Year,
      int? Month,
      bool? IsFileTransfer}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "Year": Year,
      "Month": Month,
      "IsFileTransfer": IsFileTransfer,
    });

    var response = await http.post(Uri.parse(_serviceUrl.openPeriod),
        headers: header, body: responseBody);

    log(responseBody.toString());
    log("ClosePeriod = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    }
  }

  @override
  Future<GetInvoiceListResult> GetInvoiceListWithOutFile(
      Map<String, String> header,
      {int? userId,
      int? year,
      int? month,
      int? invoiceBlock,
      int? page,
      int? size,
      int? invoiceTargetAccountId,
      int? TaxAccountId,
      String? SearchDescription,
      double? WithTaxValue,
      double? WithOutTaxValue,
      int? FileType}) async {
    var responseBody = jsonEncode({
      "UserId": userId,
      "Year": year,
      "Month": month,
      "InvoiceBlock": invoiceBlock,
      "Page": page,
      "Size": size,
      "InvoiceTargetAccountId": invoiceTargetAccountId,
      "TaxAccountId": TaxAccountId,
      "SearchDescription": SearchDescription,
      "WithTaxValue": WithTaxValue,
      "WithOutTaxValue": WithOutTaxValue,
      "FileType": FileType
    });

    print("GetInvoiceListWithOutFile = " + responseBody.toString());

    var response = await http.post(
        Uri.parse(_serviceUrl.getInvoiceListWithOutFile),
        headers: header,
        body: responseBody);

    log(response.request.toString());
    log(responseBody.toString());
    log("GetFilesByUserIdForDirectory = " + response.body);

    if (response.body.isEmpty) {
      return GetInvoiceListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetInvoiceListResult.fromJson(responseData);
    }
  }

  @override
  Future<InvoiceSummaryAllResult> GetInvoiceSummaryAll(
      Map<String, String> header,
      {int? userId,
      int? year,
      int? month}) async {
    var responseBody = jsonEncode({
      "UserId": userId,
      "Year": year,
      "Month": month,
    });

    var response = await http.post(Uri.parse(_serviceUrl.getInvoiceSummaryAll),
        headers: header, body: responseBody);

    log(response.request.toString());
    log(responseBody.toString());
    log("GetFilesByUserIdForDirectory = " + response.body);

    if (response.body.isEmpty) {
      return InvoiceSummaryAllResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return InvoiceSummaryAllResult.fromJson(responseData);
    }
  }

  @override
  Future<InvoicePositionResult> AddInvoicePositions(Map<String, String> header,
      {List<InvoicePosition>? Invoice}) async {
    var responseBody = jsonEncode({
      "InvoicePositionsResponses": Invoice?.map((e) => e.toJson()).toList(),
    });

    var response = await http.post(Uri.parse(_serviceUrl.addInvoicePositions),
        headers: header, body: responseBody);

    log("AddInvoicePositions" + responseBody.toString());
    log("AddInvoicePositions = " + response.body);

    if (response.body.isEmpty) {
      return InvoicePositionResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return InvoicePositionResult.fromJson(responseData);
    }
  }

  @override
  Future<InvoicePositionResult> GetInvoicePositions(Map<String, String> header,
      {int? invoiceId}) async {
    var responseBody = jsonEncode({
      "invoiceId": invoiceId,
    });

    var response = await http.post(Uri.parse(_serviceUrl.getInvoicePositions),
        headers: header, body: responseBody);

    log("GetInvoicePositions" + responseBody.toString());
    log("GetInvoicePositions = " + response.body);

    if (response.body.isEmpty) {
      return InvoicePositionResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return InvoicePositionResult.fromJson(responseData);
    }
  }

  @override
  Future<InvoiceHistoryResult> GetInvoiceHandMadeInvoice(
      Map<String, String> header,
      {int? UserId,
      int? CreatedForUserId,
      int? InvoiceType,
      bool? MyCustomer,
      int? Year,
      int? Month,
      String? Search}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "CreatedForUserId": CreatedForUserId,
      "InvoiceType": InvoiceType,
      "MyCustomer": MyCustomer,
      "Year": Year,
      "Month": Month,
      "Search": Search
    });

    var response = await http.post(
        Uri.parse(_serviceUrl.getInvoiceHandMadeInvoice),
        headers: header,
        body: responseBody);

    log("GetInvoiceHandMadeInvoice" + responseBody.toString());
    log("GetInvoiceHandMadeInvoice = " + response.body);

    if (response.body.isEmpty) {
      return InvoiceHistoryResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return InvoiceHistoryResult.fromJson(responseData);
    }
  }

  @override
  Future<InvoicePositionResult> AddOfferPositions(Map<String, String> header,
      {List<InvoicePosition>? Invoice}) async {
    var responseBody = jsonEncode({
      "InvoicePositionsResponses": Invoice?.map((e) => e.toJson()).toList(),
    });

    var response = await http.post(Uri.parse(_serviceUrl.addOfferPositions),
        headers: header, body: responseBody);

    log("AddOfferPositions" + responseBody.toString());
    log("AddOfferPositions = " + response.body);

    if (response.body.isEmpty) {
      return InvoicePositionResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return InvoicePositionResult.fromJson(responseData);
    }
  }

  @override
  Future<GetAllOfferResult> GetAllOffer(Map<String, String> header,
      {int? UserId, int? CreatedForUserId, bool? MyCustomer}) async {
    var response = await http.get(
      Uri.parse(_serviceUrl.getAllOffer +
          "?userId=$UserId" +
          "&createdForUserId=$CreatedForUserId" +
          "&myCustomer=$MyCustomer"),
      headers: header,
    );

    log("GetAllOffer" + response.request!.url.toString());
    log("GetAllOffer = " + response.body);

    if (response.body.isEmpty) {
      return GetAllOfferResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetAllOfferResult.fromJson(responseData);
    }
  }

  @override
  Future<InvoicePositionResult> GetOfferPositions(Map<String, String> header,
      {int? invoiceId}) async {
    var responseBody = jsonEncode({
      "invoiceId": invoiceId,
    });

    var response = await http.post(Uri.parse(_serviceUrl.getOfferPositions),
        headers: header, body: responseBody);

    log("GetOfferPositions" + responseBody.toString());
    log("GetOfferPositions = " + response.body);

    if (response.body.isEmpty) {
      return InvoicePositionResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return InvoicePositionResult.fromJson(responseData);
    }
  }

  @override
  Future<InsertOfferResult> InsertOffer(
    Map<String, String> header,
      {InsertOfferItem? insertOfferItem}) 
      async {
    var reqBody = jsonEncode({
      "CustomerId": insertOfferItem!.customerId,
      "OfferName": insertOfferItem.offerName,
      "FileId": insertOfferItem.fileId,
      "Date": insertOfferItem.date,
      "Year": insertOfferItem.year,
      "Month": insertOfferItem.month,
      "TaxFreeAmount": insertOfferItem.taxFreeAmount,
      "Tax": insertOfferItem.tax,
      "TaxAddAmount": insertOfferItem.taxAddAmount,
      "TaxAmount": insertOfferItem.taxAmount,
      "CreateDate": insertOfferItem.createDate,
      "CreateUser": insertOfferItem.createUser,
      "CreatedForUserId": insertOfferItem.createdForUserId,
      "MyCustomer": insertOfferItem.myCustomer,
      "OfferNumber": insertOfferItem.offerNumber,
      "Files": insertOfferItem.files!.toJson(),
    });
    var response = await http.post(Uri.parse(_serviceUrl.insertOffer),
        headers: header, body: reqBody);

    log("req InsertOffer :" + reqBody);
    log("res InsertOffer :" + response.body);

    if (response.body.isEmpty) {
      return InsertOfferResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return InsertOfferResult.fromJson(responseData);
    }
  }
}
