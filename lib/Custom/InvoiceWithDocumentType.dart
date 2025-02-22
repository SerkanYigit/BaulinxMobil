enum InvoiceWithDocumentType {
  IncomeUnpaid,
  IncomePaid,
  OutgoingPaid,
  OutgoingUnpaid,
  WithOutFilePaid
}

/*extension InvoiceWithDocumentTypeExtension on InvoiceWithDocumentType {

  int get typeId {
    switch (this) {
      case InvoiceWithDocumentType.IncomeUnpaid:
        return 1;
      case InvoiceWithDocumentType.IncomePaid:
        return 2;
      case InvoiceWithDocumentType.OutgoingPaid:
        return 3;
      case InvoiceWithDocumentType.OutgoingUnpaid:
        return 4;
      default:
        return null;
    }
  }

}*/
