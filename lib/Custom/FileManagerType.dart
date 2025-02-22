import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum FileManagerType {
  None,
  Project,
  WorksGroup,
  Lesson,
  Courses,
  NewsCategory,
  Conference,
  ConferenceCategory,
  Administration,
  Customer,
  Invoice,
  InvoiceDocument,
  Report, //
  Salary, //
  CommonDocument, //
  PrivateDocument,
  GeneralDocument,
  UserRoles,
  TodoComment,
  Message,
  GeneralDocumentCustomer,
  News,
  CommonTask,
  BoardTaskPermission,
  Calendar,
  Homework
}

extension FileManagerTypeExtension on FileManagerType {
  int? get typeId {
    switch (this) {
      case FileManagerType.Customer:
        return 9;
      case FileManagerType.Report:
        return 12;
      case FileManagerType.Salary:
        return 13;
      case FileManagerType.PrivateDocument:
        return 15;
      case FileManagerType.GeneralDocument:
        return 16;
      case FileManagerType.CommonDocument: // board
        return 14;
      case FileManagerType.CommonTask: // board
        return 31;
      case FileManagerType.Calendar: // board
        return 33;
      case FileManagerType.Invoice:
        return 10;
      default:
        return null;
    }
  }

  String? header(context) {
    switch (this) {
      case FileManagerType.Customer:
        return AppLocalizations.of(context)!.customer;
      case FileManagerType.Report:
        return AppLocalizations.of(context)!.contact;
      case FileManagerType.Salary:
        return AppLocalizations.of(context)!.commonCloud;
      case FileManagerType.PrivateDocument:
        return AppLocalizations.of(context)!.privateCloud;
      case FileManagerType.GeneralDocument:
        return "";

      case FileManagerType.CommonDocument: // board
        return AppLocalizations.of(context)!.collaboration;
      case FileManagerType.CommonTask:
        return AppLocalizations.of(context)!.collaborationTask;
      case FileManagerType.Invoice:
        return AppLocalizations.of(context)!.invoice;
      default:
        return null;
    }
  }
}

FileManagerType? giveFileManagerEnum(int i) {
  switch (i) {
    case 9:
      return FileManagerType.Customer;
    case 12:
      return FileManagerType.Report;
    case 13:
      return FileManagerType.Salary;
    case 15:
      return FileManagerType.PrivateDocument;
    case 16:
      return FileManagerType.GeneralDocument;
    case 21: // board
      return FileManagerType.CommonDocument;

    case 31: // board
      return FileManagerType.Calendar;
    case 10:
      return FileManagerType.Invoice;
    case 14:
      return FileManagerType.CommonDocument;
    default:
      return null;
  }
}

enum FileManagerTypeForSearch {
  Customer,
  Report, //
  Salary, //
  Invoice,
  CommonDocument,
  PrivateDocument,
  GeneralDocument,

  GeneralDocumentCustomer,
  CommonTask,
}

extension FileManagerTypeExtensionV2 on FileManagerTypeForSearch {
  int? get typeSearchId {
    switch (this) {
      case FileManagerTypeForSearch.Customer:
        return 9;
      case FileManagerTypeForSearch.Invoice:
        return 10;
      case FileManagerTypeForSearch.Report:
        return 12;
      case FileManagerTypeForSearch.Salary:
        return 13;
      case FileManagerTypeForSearch.PrivateDocument:
        return 15;
      case FileManagerTypeForSearch.GeneralDocument:
        return 16;
      case FileManagerTypeForSearch.CommonDocument: // board
        return 14;
      case FileManagerTypeForSearch.CommonTask: // board
        return 31;
      case FileManagerTypeForSearch.GeneralDocumentCustomer: // board
        return 24;
      default:
        return null;
    }
  }

  String headerSearch(context) {
    switch (this) {
      case FileManagerTypeForSearch.Customer:
        return AppLocalizations.of(context)!.customer;
      case FileManagerTypeForSearch.Report:
        return AppLocalizations.of(context)!.contact;
      case FileManagerTypeForSearch.Salary:
        return AppLocalizations.of(context)!.salary;
      case FileManagerTypeForSearch.Invoice:
        return AppLocalizations.of(context)!.invoice;
      case FileManagerTypeForSearch.PrivateDocument:
        return AppLocalizations.of(context)!.privateCloud;
      case FileManagerTypeForSearch.GeneralDocument:
        return "GeneralDocument";

      case FileManagerTypeForSearch.CommonDocument: // board
        return AppLocalizations.of(context)!.collaboration;
      case FileManagerTypeForSearch.CommonTask:
        return "Common Task";

      case FileManagerTypeForSearch.GeneralDocumentCustomer:
        return "GeneralDocumentCustomer";
      default:
        return "";
    }
  }
}
