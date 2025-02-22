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

abstract class InvoiceBase {
  Future<GetInvoiceListResult> GetInvoiceList(Map<String, String> header,
      {int userId,
      int year,
      int month,
      int invoiceBlock,
      int page,
      int size,
      int invoiceTargetAccountId,
      int TaxAccountId,
      String SearchDescription,
      double WithTaxValue,
      double WithOutTaxValue});

  Future<bool> InvoiceFileInsert(Map<String, String> header,
      {int Id,
      int FileId,
      int CustomerId,
      int AccountTypeId,
      int Type,
      String InvoiceName,
      String Date,
      int Year,
      int Month,
      int Day,
      double TaxFreeAmount,
      int Tax,
      double TaxAddAmount,
      int InvoiceTargetAccountId,
      int InvoiceBlock,
      int TaxAccountId,
      double TaxAmount,
      bool IsDeleted,
      String Description,
      String CreateDate,
      int CreateUser,
      int Status,
      String FileName,
      String FileContent});

  Future<int> InvoiceFileListInsert(
    Map<String, String> header, {
    int CustomerId,
    int FileId,
    bool IsDeleted,
    int Status,
    String Date,
    int Type,
    int Year,
    int Month,
    int InvoiceTargetAccountId,
    int InvoiceBlock,
    String CreateDate,
    int CreateUser,
    InvoiceFileInsertFiles Files,
    bool IsCombine,
    String CombineFileName,
  });

  Future<GetInvoiceTargetAccountListResult> GetInvoiceTargetAccountList(
      Map<String, String> header,
      {int UserId});

  Future<DataLayoutAPI> InvoiceMultiUpdate(Map<String, String> header,
      {int UserId, List<Invoice> InvoiceList});

  Future<GetAccountTypeListResult> GetAccountTypeList(
      Map<String, String> header,
      {int UserId,
      int Type});

  Future<GetTaxAccountListResult> GetTaxAccountList(Map<String, String> header,
      {int UserId, int Type});
  Future DeleteInvoice(Map<String, String> header, {int UserId, int InvoiceId});
  Future DeleteInvoiceList(Map<String, String> header,
      {int UserId, List<int> InvoiceIdList});
  Future ClosePeriod(Map<String, String> header,
      {int UserId, int CustomerId, int Year, int Month, bool IsFileTransfer});
  Future<GetInvoicePeriodListResult> GetInvoicePeriodList(
      Map<String, String> header,
      {int CustomerId,
      int Year,
      String Language});
  Future<GetInvoiceSummaryResult> GetInvoiceSummary(Map<String, String> header,
      {int userId,
      int year,
      int month,
      int invoiceBlock,
      int InvoiceTargetAccountId});
  Future OpenPeriod(Map<String, String> header,
      {int UserId, int CustomerId, int Year, int Month, bool IsFileTransfer});
  Future ConfirmPeriod(Map<String, String> header,
      {int UserId, int CustomerId, int Year, int Month, bool IsFileTransfer});
  Future<GetInvoiceListResult> GetInvoiceListWithOutFile(
      Map<String, String> header,
      {int userId,
      int year,
      int month,
      int invoiceBlock,
      int page,
      int size,
      int invoiceTargetAccountId,
      int TaxAccountId,
      String SearchDescription,
      double WithTaxValue,
      double WithOutTaxValue});

  Future<InvoiceSummaryAllResult> GetInvoiceSummaryAll(
    Map<String, String> header, {
    int userId,
    int year,
    int month,
  });
  Future<InvoicePositionResult> GetInvoicePositions(Map<String, String> header,
      {int invoiceId});
  Future<InvoicePositionResult> AddInvoicePositions(Map<String, String> header,
      {List<InvoicePosition> Invoice});
  Future<InvoiceHistoryResult> GetInvoiceHandMadeInvoice(
      Map<String, String> header,
      {int UserId,
      int CreatedForUserId,
      int InvoiceType,
      bool MyCustomer,
      int Year,
      int Month,
      String Search});
  Future<InvoicePositionResult> AddOfferPositions(Map<String, String> header,
      {List<InvoicePosition> Invoice});
  Future<InvoicePositionResult> GetOfferPositions(Map<String, String> header,
      {int invoiceId});
  Future<InsertOfferResult> InsertOffer(Map<String, String> header,
      {InsertOfferItem insertOfferItem});
  Future<GetAllOfferResult> GetAllOffer(Map<String, String> header,
      {int UserId});
}
