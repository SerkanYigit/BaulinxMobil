import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum FileTypes {
  xlsx,
  xls,
  docx,
  doc,
  png,
  jpg,
  jpeg,
  pdf,
  txt,
  ppt,
  zip,
}

extension FileTypesExtension on FileTypes {
  String get icon {
    switch (this) {
      case FileTypes.xlsx:
        return 'assets/images/file_types/xls.png';
      case FileTypes.xls:
        return 'assets/images/file_types/xls.png';
      case FileTypes.docx:
        return 'assets/images/file_types/doc.png';
      case FileTypes.doc:
        return 'assets/images/file_types/doc.png';
      case FileTypes.png:
        return 'assets/images/file_types/png.png';
      case FileTypes.jpg:
        return 'assets/images/file_types/jpg.png';
      case FileTypes.jpeg:
        return 'assets/images/file_types/jpg.png';
      case FileTypes.pdf:
        return 'assets/images/file_types/pdf.png';
      case FileTypes.txt:
        return 'assets/images/file_types/txt.png';
      case FileTypes.ppt:
        return 'assets/images/file_types/ppt.png';
      case FileTypes.zip:
        return 'assets/images/file_types/zip.png';
      default:
        return "";
    }
  }

  String get string {
    switch (this) {
      case FileTypes.xlsx:
        return 'xlsx';
      case FileTypes.xls:
        return 'xls';
      case FileTypes.docx:
        return 'docx';
      case FileTypes.doc:
        return 'doc';
      case FileTypes.png:
        return 'png';
      case FileTypes.jpg:
        return 'jpg';
      case FileTypes.jpeg:
        return 'jpeg';
      case FileTypes.pdf:
        return 'pdf';
      case FileTypes.txt:
        return 'txt';
      case FileTypes.ppt:
        return 'ppt';
      case FileTypes.zip:
        return 'zip';
      default:
        return "";
    }
  }
}

String getImagePathByFileExtension(String extension) {
  extension = extension.toLowerCase();
  switch (extension) {
    case 'xlsx':
      return 'assets/images/file_types/xls.png';
    case 'xls':
      return 'assets/images/file_types/xls.png';
    case 'docx':
      return 'assets/images/file_types/doc.png';
    case 'doc':
      return 'assets/images/file_types/doc.png';
    case 'png':
      return 'assets/images/file_types/png.png';
    case 'jpg':
      return 'assets/images/file_types/jpg.png';
    case 'jpeg':
      return 'assets/images/file_types/jpg.png';
    case 'pdf':
      return 'assets/images/file_types/pdf.png';
    case 'txt':
      return 'assets/images/file_types/txt.png';
    case 'ppt':
      return 'assets/images/file_types/ppt.png';
    case 'zip':
      return 'assets/images/file_types/zip.png';
    case 'mp4':
      return 'assets/images/file_types/mp4.png';
    case 'm4a':
    case 'mp3':
      return 'assets/images/file_types/mp3.png';
    default:
      return 'assets/images/file_types/txt.png';
  }
}

String getImagePathByFileExtensionWithDot(String extension) {
  extension = extension.toLowerCase();
  switch (extension) {
    case '.xlsx':
      return 'assets/images/file_types/xls.png';
    case '.xls':
      return 'assets/images/file_types/xls.png';
    case '.docx':
      return 'assets/images/file_types/doc.png';
    case '.doc':
      return 'assets/images/file_types/doc.png';
    case '.png':
      return 'assets/images/file_types/png.png';
    case '.jpg':
      return 'assets/images/file_types/jpg.png';
    case '.jpeg':
      return 'assets/images/file_types/jpg.png';
    case '.pdf':
      return 'assets/images/file_types/pdf.png';
    case '.txt':
      return 'assets/images/file_types/txt.png';
    case '.ppt':
      return 'assets/images/file_types/ppt.png';
    case '.zip':
      return 'assets/images/file_types/zip.png';
    case '.mp4':
      return 'assets/images/file_types/mp4.png';
    case '.m4a':
    case '.mp3':
      return 'assets/images/file_types/mp3.png';
    default:
      return 'assets/images/file_types/txt.png';
  }
}

String getImageByInvoiceBlock(int InvoiceBlock) {
  switch (InvoiceBlock) {
    case 2:
      return 'https://plattform.baulinx.com/material-ui-static/images/cards/bg.png';
    case 4:
      return 'https://plattform.baulinx.com/material-ui-static/images/cards/bg.png';
    case 1:
      return 'https://plattform.baulinx.com/material-ui-static/images/cards/bg.png';
    case 3:
      return 'https://plattform.baulinx.com/material-ui-static/images/cards/bg.png';
    default:
      return 'https://plattform.baulinx.com/material-ui-static/images/cards/bg.png';
  }
}

String getTitleByInvoiceBlock(int InvoiceBlock, BuildContext context) {
  switch (InvoiceBlock) {
    case 2:
      return AppLocalizations.of(context)!.incomePaid;
    case 4:
      return AppLocalizations.of(context)!.incomeUnpaid;
    case 1:
      return AppLocalizations.of(context)!.outgoingPaid;
    case 3:
      return AppLocalizations.of(context)!.outgoingUnpaid;
    default:
      return '';
  }
}
