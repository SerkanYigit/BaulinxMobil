import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/PDFCreater/ProductClass.dart';
import 'package:undede/Services/Invoice/InvoiceBase.dart';
import 'package:undede/Services/Invoice/InvoiceDB.dart';
import 'package:undede/Services/ServiceUrl.dart';
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
import 'package:undede/model/Invoice/InvoiceInsert.dart';

import 'ControllerBottomNavigationBar.dart';
import 'ControllerDB.dart';

class InvoiceSetting {
  int? CustomerId;
  bool? ShowUnpaid;

  InvoiceSetting(this.CustomerId, this.ShowUnpaid);

  InvoiceSetting.fromJson(Map<String, dynamic> json) {
    CustomerId = json['CustomerId'];
    ShowUnpaid = json['ShowUnpaid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CustomerId'] = this.CustomerId;
    data['ShowUnpaid'] = this.ShowUnpaid;
    return data;
  }
}

class ControllerInvoice extends GetxController implements InvoiceBase {
  InvoiceDB _filesService = InvoiceDB();
  final ServiceUrl _serviceUrl = ServiceUrl();
  final ControllerDB _controllerDB = Get.put(ControllerDB());
  List<Invoice> invoices = [];
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  List<InvoiceSetting> invoiceSettings = [];
  bool showUnpaid = true;
  int totalCount = 0;
  double totalAmount = 0.0;
  bool refreshIWD = false;
  Rx<GetInvoicePeriodListResult?> getInvoicePeriod = null.obs;
  final ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  List<Product> products = [];
  int? CreatedForUserId;
  bool? MyCustomer;
  String? InvoiceName;
  String? InvoiceNumber;
  int? productType = 0;
  int? CommonGroupId;
  List<InvoiceSetting> mapInvoiceSettingsData(List<dynamic> InvoiceSettings) {
    try {
      List<InvoiceSetting> res =
          InvoiceSettings.map((v) => InvoiceSetting.fromJson(v)).toList();
      return res;
    } catch (err) {
      // Just in case
      return [];
    }
  }

  double percenteg = 0;

  @override
  Future<GetInvoiceListResult> GetInvoiceList(
    Map<String, String> header, {
    int? userId,
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
    int invoiceType = 0,
  }) async {
    print('GetFilesByUserIdForDirectory: $invoiceType');
    var value = await _filesService.GetInvoiceList(
      header,
      userId: userId,
      year: year!,
      month: month!,
      invoiceBlock: invoiceBlock!,
      page: page!,
      size: size!,
      invoiceTargetAccountId: invoiceTargetAccountId,
      TaxAccountId: TaxAccountId,
      SearchDescription: SearchDescription,
      WithOutTaxValue: WithOutTaxValue,
      WithTaxValue: WithTaxValue,
      invoiceType: invoiceType,
    );
    /*var valueforSummary = await _filesService.GetInvoiceSummary(header,
        userId: userId,
        year: year,
        month: month,
        invoiceBlock: invoiceBlock,
        InvoiceTargetAccountId: invoiceTargetAccountId);*/
    totalCount = value.result!.invoiceSummary!.totalCount!;
    totalAmount = value.result!.invoiceSummary!.totalAmount ?? 0.0;

    update();
    return value;
  }

  @override
  Future<bool> InvoiceFileInsert(
    Map<String, String> header, {
    int? Id,
    int? FileId,
    int? CustomerId,
    int? AccountTypeId,
    int? Type,
    String InvoiceName = "",
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
    String Description = "",
    String? CreateDate,
    int? CreateUser,
    int? Status,
    String? FileName,
    String? FileContent,
  }) async {
    _controllerBottomNavigationBar.lockUI = true;
    _controllerBottomNavigationBar.update();
    var value = await _filesService.InvoiceFileInsert(
      header,
      Id: Id!,
      FileId: FileId!,
      CustomerId: CustomerId!,
      AccountTypeId: AccountTypeId!,
      Type: Type!,
      InvoiceName: InvoiceName,
      Date: Date!,
      Year: Year!,
      Month: Month!,
      Day: Day!,
      TaxFreeAmount: TaxFreeAmount!,
      Tax: Tax!,
      TaxAddAmount: TaxAddAmount!,
      InvoiceTargetAccountId: InvoiceTargetAccountId!,
      InvoiceBlock: InvoiceBlock!,
      TaxAccountId: TaxAccountId!,
      TaxAmount: TaxAmount!,
      IsDeleted: IsDeleted!,
      Description: Description,
      CreateDate: CreateDate!,
      CreateUser: CreateUser!,
      Status: Status!,
      FileName: FileName!,
      FileContent: FileContent!,
    );
    _controllerBottomNavigationBar.lockUI = false;
    _controllerBottomNavigationBar.update();
    return value;
  }

  @override
  Future<int> InvoiceFileListInsert(
    Map<String, String> header, {
    int? CustomerId,
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
    String? CombineFileName,
    int? TaxAccountId,
    num? TaxFreeAmount,
    num? Tax,
    num? TaxAmount,
    num? TaxAddAmount,
    String? Description,
    String? InvoiceName,
    bool? HandCreatedInvoice,
    int? CreatedForUserId,
    bool? MyCustomer,
    String? InvoiceNumber,
    int? InvoiceType,
    int? CommonGroupId,
  }) async {
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
      "TaxAccountId": TaxAccountId,
      "TaxAmount": TaxAmount,
      "TaxFreeAmount": TaxFreeAmount,
      "Tax": Tax,
      "TaxAddAmount": TaxAddAmount,
      "Description": Description,
      "InvoiceName": InvoiceName,
      "HandCreatedInvoice": HandCreatedInvoice,
      "InvoiceNumber": InvoiceNumber,
      "CreatedForUserId": CreatedForUserId,
      "MyCustomer": MyCustomer,
      "Files": Files != null ? Files.toJson() : null,
      "IsCombine": IsCombine,
      "CombineFileName": CombineFileName,
      "InvoiceType": InvoiceType,
      "CommonGroupId": CommonGroupId
    });
    var dio = Dio();
    final response = await dio.post<Map<String, dynamic>>(
      (_serviceUrl.invoiceFileListInsert),
      options: Options(headers: {
        "content-type": "application/json",
        "accept": "application/json",
        "Authorization": "Bearer " + _controllerDB.token.value
      }),
      data: reqBody,
      onSendProgress: (i, j) async {
        percenteg = (i / j * 100).roundToDouble();
        update();
        if (i == j) {
          percenteg = 99;
          update();
        }
        print("i değeri :" + i.toString() + "j değeri :" + j.toString());
      },
      onReceiveProgress: (i, j) async {
        print("i değeri :" + i.toString() + "j değeri :" + j.toString());

        percenteg = 100;
        update();
        await Future.delayed(Duration(milliseconds: 250));
        percenteg = 0;
        update();
      },
    );

    //  var response = await http.post(Uri.parse(_serviceUrl.invoiceFileListInsert), headers: header, body: reqBody);
//Todo
    log("Request InvoiceFileListInsert = " + reqBody);
    log("Response InvoiceFileListInsert = " + response.data.toString());

    if (true) {
      return response.data!["Result"][0]["Id"];
    }
    // final responseData = jsonDecode(response.data) as Map<String, dynamic>;
    //  log(responseData["Result"][0]["Id"]);
  }

  @override
  Future<GetInvoiceTargetAccountListResult> GetInvoiceTargetAccountList(
      Map<String, String> header,
      {int? UserId}) async {
    return await _filesService.GetInvoiceTargetAccountList(
      header,
      UserId: UserId!,
    );
  }

  @override
  Future<DataLayoutAPI> InvoiceMultiUpdate(Map<String, String> header,
      {int? UserId, List<Invoice>? InvoiceList}) async {
    DataLayoutAPI result = await _filesService.InvoiceMultiUpdate(
      header,
      UserId: UserId!,
      InvoiceList: InvoiceList!,
    );

    if (result.hasError!) {
      showToast('Error: ' + result.resultMessage!);
    } else {
      showToast('Files are moved succesfuly.');
    }
    return result;
  }

  @override
  Future<GetAccountTypeListResult> GetAccountTypeList(
      Map<String, String> header,
      {int? UserId,
      int? Type}) async {
    return await _filesService.GetAccountTypeList(header,
        UserId: UserId!, Type: Type!);
  }

  @override
  Future<GetTaxAccountListResult> GetTaxAccountList(Map<String, String> header,
      {int? UserId, int? Type}) async {
    return await _filesService.GetTaxAccountList(header,
        UserId: UserId!, Type: Type!);
  }

  @override
  Future DeleteInvoice(Map<String, String> header,
      {int? UserId, int? InvoiceId}) async {
    return await _filesService.DeleteInvoice(header,
        UserId: UserId!, InvoiceId: InvoiceId!);
  }

  @override
  Future DeleteInvoiceList(Map<String, String> header,
      {int? UserId, List<int>? InvoiceIdList}) async {
    return await _filesService.DeleteInvoiceList(header,
        UserId: UserId!, InvoiceIdList: InvoiceIdList!);
  }

  @override
  Future ClosePeriod(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? Year,
      int? Month,
      bool? IsFileTransfer}) async {
    return await _filesService.ClosePeriod(header,
        UserId: UserId!,
        CustomerId: CustomerId!,
        Year: Year!,
        Month: Month!,
        IsFileTransfer: IsFileTransfer!);
  }

  @override
  Future<GetInvoicePeriodListResult> GetInvoicePeriodList(
      Map<String, String> header,
      {int? CustomerId,
      int? Year,
      String? Language}) async {
    var value = await _filesService.GetInvoicePeriodList(header,
        CustomerId: CustomerId!, Year: Year!, Language: Language!);
    update();
    getInvoicePeriod = value.obs;
    update();
    return await value;
  }

  @override
  Future<GetInvoiceSummaryResult> GetInvoiceSummary(Map<String, String> header,
      {int? userId,
      int? year,
      int? month,
      int? invoiceBlock,
      int? InvoiceTargetAccountId}) {
    // TODO: implement GetInvoiceSummary
    throw UnimplementedError();
  }

  @override
  Future ConfirmPeriod(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? Year,
      int? Month,
      bool? IsFileTransfer}) async {
    // TODO: implement ContinuePeriod
    await _filesService.ConfirmPeriod(
      header,
      UserId: UserId!,
      CustomerId: CustomerId!,
      Year: Year!,
      Month: Month!,
      IsFileTransfer: IsFileTransfer!,
    );
  }

  @override
  Future OpenPeriod(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? Year,
      int? Month,
      bool? IsFileTransfer}) async {
    await _filesService.OpenPeriod(
      header,
      UserId: UserId!,
      CustomerId: CustomerId!,
      Year: Year!,
      Month: Month!,
      IsFileTransfer: IsFileTransfer!,
    );
  }

  @override
  Future<GetInvoiceListResult> GetInvoiceListWithOutFile(
    Map<String, String> header, {
    int? userId,
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
    int? FileType,
  }) async {
    var value = await _filesService.GetInvoiceListWithOutFile(
      header,
      userId: userId!,
      year: year!,
      month: month!,
      invoiceBlock: invoiceBlock!,
      page: page!,
      size: size!,
      invoiceTargetAccountId: invoiceTargetAccountId!,
      TaxAccountId: TaxAccountId!,
      SearchDescription: SearchDescription!,
      WithOutTaxValue: WithOutTaxValue!,
      WithTaxValue: WithTaxValue!,
      FileType: FileType!,
    );
    totalCount = value.result!.invoiceSummary!.totalCount!;
    totalAmount = value.result!.invoiceSummary!.totalAmount ?? 0.0;
    return value;
  }

  @override
  Future<InvoiceSummaryAllResult> GetInvoiceSummaryAll(
    Map<String, String> header, {
    int? userId,
    int? year,
    int? month,
  }) async {
    var value = await _filesService.GetInvoiceSummaryAll(
      header,
      userId: userId!,
      year: year!,
      month: month!,
    );
    return value;
  }

  @override
  Future<InvoicePositionResult> AddInvoicePositions(Map<String, String> header,
      {List<InvoicePosition>? Invoice}) async {
    return await _filesService.AddInvoicePositions(header, Invoice: Invoice!);
  }

  @override
  Future<InvoicePositionResult> GetInvoicePositions(Map<String, String> header,
      {int? invoiceId}) async {
    return await _filesService.GetInvoicePositions(header,
        invoiceId: invoiceId!);
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
    return await _filesService.GetInvoiceHandMadeInvoice(header,
        UserId: UserId!,
        CreatedForUserId: CreatedForUserId!,
        MyCustomer: MyCustomer!,
        Year: Year!,
        Month: Month!,
        Search: Search!,
        InvoiceType: InvoiceType!);
  }

  @override
  Future<InvoicePositionResult> AddOfferPositions(Map<String, String> header,
      {List<InvoicePosition>? Invoice}) async {
    return await _filesService.AddOfferPositions(header, Invoice: Invoice!);
  }

  @override
  Future<GetAllOfferResult> GetAllOffer(
    Map<String, String> header, {
    int? UserId,
    int? CreatedForUserId,
    bool? MyCustomer,
  }) async {
    return await _filesService.GetAllOffer(
      header,
      UserId: UserId!,
      CreatedForUserId: CreatedForUserId!,
      MyCustomer: MyCustomer!,
    );
  }

  @override
  Future<InvoicePositionResult> GetOfferPositions(Map<String, String> header,
      {int? invoiceId}) async {
    return await _filesService.GetOfferPositions(header, invoiceId: invoiceId!);
  }

  @override
  Future<InsertOfferResult> InsertOffer(Map<String, String> header,
      {InsertOfferItem? insertOfferItem}) async {
    return await _filesService.InsertOffer(header,
        insertOfferItem: insertOfferItem!);
  }
}
