import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/model/CustomersBills/CustomersBillsResult.dart';
import 'package:undede/model/CustomersBills/CustomersBillsResult.dart';
import 'package:undede/model/User/UpdatedCustomerResult.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'ProductClass.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreatePdf {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerUser _controllerUser = Get.put(ControllerUser());

  final CustomerBill? customerBill;
  final String? InvoiceNumber;
  final List<Product>? Products;
  final String? moneySign;
  final BuildContext? context;
  final String? myAddress;
  final CompanyResult? myCustomer;
  final DateTime? startDate;
  final DateTime? endDate;
  final NumberFormat? oCcy;
  final DateTime? invoiceDateTime;
  final int? productType;
  CreatePdf({
    this.customerBill,
    this.InvoiceNumber,
    this.Products,
    this.moneySign,
    this.context,
    this.myAddress,
    this.myCustomer,
    this.startDate,
    this.endDate,
    this.oCcy,
    this.invoiceDateTime,
    this.productType,
  });

  Future<String> generateInvoice() async {
    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    final PdfPage page2 = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    //Draw rectangle
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219)));
    //Generate PDF grid.
    final PdfGrid grid = getGrid();
    final PdfGrid grid2 = getGrid2();
    //Draw the header section by creating text element
    final PdfLayoutResult result = drawHeader(page, pageSize, grid);

    //Draw grid
    final PdfLayoutResult result3 = drawGrid(page, grid, result);

    if (result3.page.size == 2) {
      final PdfPage page3 = document.pages.add();
      final Size pageSize2 = page3.getClientSize();
      final PdfLayoutResult result2 = drawHeader2(page3, pageSize2, grid2);
      drawGrid2(page3, grid2, result2);
    } else {
      final Size pageSize2 = page2.getClientSize();
      final PdfLayoutResult result2 = drawHeader2(page2, pageSize2, grid2);
      drawGrid2(page2, grid2, result2);
    }

    //Add invoice footer
    //drawFooter(page, pageSize);
    final appStorage = await getApplicationDocumentsDirectory();

    final path = File(appStorage.path + "/" + 'output.pdf');
    print("" + document.pages.count.toString());
    final file = await File(path.path).writeAsBytes(await document.save());
    // OpenFile.open(file.path);
    return file.path;
  }

//Draws the invoice header
  PdfLayoutResult drawHeader(PdfPage page, Size pageSize, PdfGrid grid) {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(35, 101, 101)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));
    //Draw string
    page.graphics.drawString(
        "${productType == 0 ? AppLocalizations.of(context!)!.invoiceNumber.toUpperCase() : productType == 1 ? AppLocalizations.of(context!)!.cancel.toUpperCase() : productType == 2 ? AppLocalizations.of(context!)!.offer.toUpperCase() : AppLocalizations.of(context!)!.inquiry.toUpperCase()} : ${InvoiceNumber!.toUpperCase()}",
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
        brush: PdfSolidBrush(PdfColor(0, 101, 101)));

    page.graphics.drawString(
        AppLocalizations.of(context!)!.symbol == "€"
            ? String.fromCharCode(128) +
                "${productType == 0 ? "" : productType == 1 ? " - " : ""}" +
                oCcy!.format(getTotalAmount(grid))
            : AppLocalizations.of(context!)!.symbol +
                "${productType == 0 ? "" : productType == 1 ? " - " : ""}" +
                oCcy!.format(getTotalAmount(grid)),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
        brush: PdfBrushes.white,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));

    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    //Draw string
    page.graphics.drawString(AppLocalizations.of(context!)!.amount, contentFont,
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 33),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.bottom));
    //Create data foramt and convert it to text.
    final DateFormat format =
        DateFormat.yMMMMd(AppLocalizations.of(context!)!.date);
    final String invoiceDate =
        "${AppLocalizations.of(context!)!.invoiceDate} : ${format.format(invoiceDateTime!)}";

    String cleanAddress(String address) {
      List<String> parts = address.replaceFirst("\n", "").split(",");
      String firstPart = parts.first.trim();
      String lastPart = parts.last.trim();

      if (firstPart == lastPart) {
        return firstPart.isNotEmpty ? firstPart : "";
      } else {
        return "${firstPart.isNotEmpty ? firstPart + "," : ""}${lastPart.isNotEmpty ? lastPart : ""}";
      }
    }

    String addressCust = myCustomer!.address!;
    String processedAddress = cleanAddress(addressCust);

    String footerContent =
        // ignore: leading_newlines_in_multiline_strings
        '''
        ${AppLocalizations.of(context!)!.fromTo}: \r\n
        ${myCustomer!.title ?? ""}
        ${processedAddress}
        ${processedAddress}
        ${myCustomer!.companyNumber ?? ""}
        ${myCustomer!.taxNumber ?? ""}
        ${myCustomer!.iban ?? ""}
        ${AppLocalizations.of(context!)!.phoneCod + myCustomer!.phone! ?? ""}
        ${myCustomer!.mail ?? ""}
        ${myCustomer!.companyDetail ?? ""}\r\n
        ${invoiceDate}
         ''';

    /*
    page.graphics.drawString(
        footerContent, PdfStandardFont(PdfFontFamily.helvetica, 8),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.left,
        ),
        bounds:
        Rect.fromLTWH(pageSize.width - 120, pageSize.height - 90, 0, 0));

     */
    final String invoiceNumber =
        AppLocalizations.of(context!)!.invoiceNumber + ': ${InvoiceNumber}';

    final Size contentSize = contentFont.measureString(footerContent);
    String endDateString =
        endDate!.isNullOrBlank! ? "" : " - " + format.format(endDate!);
    String dateName = endDate!.isNullOrBlank!
        ? AppLocalizations.of(context!)!.dateName
        : AppLocalizations.of(context!)!.period;
    String address =
        '''${AppLocalizations.of(context!)!.billTo}: \r\n\r\n${customerBill!.billUserName}, 
        \r\n\r\n${customerBill!.billAddress}''';
    String dateRange = '''\r\n${dateName}
        \r\n${format.format(startDate!) + endDateString}
        \r\n${AppLocalizations.of(context!)!.invoicePosition}''';
    PdfTextElement(text: footerContent, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(pageSize.width - (contentSize.width + 30), 95,
            contentSize.width + 30, pageSize.height - 120));

    PdfTextElement(
            text: dateRange,
            font: PdfStandardFont(PdfFontFamily.helvetica, 9,
                style: PdfFontStyle.bold))
        .draw(
            page: page,
            bounds: Rect.fromLTWH(30, 227,
                pageSize.width - (contentSize.width + 30), pageSize.height));
    PdfTextElement(text: address, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(30, 100,
            pageSize.width - (contentSize.width + 30), pageSize.height - 80));
    PdfTextElement(text: invoiceNumber, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(30, 213,
            pageSize.width - (contentSize.width + 30), pageSize.height - 80));

    return PdfTextElement(text: "", font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(30, 252,
            pageSize.width - (contentSize.width + 30), pageSize.height - 80)
            )!;
  }

  PdfLayoutResult drawHeader2(PdfPage page, Size pageSize, PdfGrid grid) {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(35, 101, 101)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));
    //Draw string
    page.graphics.drawString(
        AppLocalizations.of(context!)!.invoiceNumber.toUpperCase() +
            " " +
            InvoiceNumber!.toUpperCase(),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
        brush: PdfSolidBrush(PdfColor(0, 101, 101)));

    page.graphics.drawString(
        AppLocalizations.of(context!)!.symbol == "€"
            ? String.fromCharCode(128) +
                "${productType == 0 ? "" : productType == 1 ? " - " : ""}" +
                oCcy!.format(getTotalAmount(grid))
            : AppLocalizations.of(context!)!.symbol +
                "${productType == 0 ? "" : productType == 1 ? " - " : ""}" +
                oCcy!.format(getTotalAmount(grid)),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
        brush: PdfBrushes.white,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));

    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    //Draw string
    page.graphics.drawString(AppLocalizations.of(context!)!.amount, contentFont,
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 33),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.bottom));
    //Create data foramt and convert it to text.

    return PdfTextElement(text: "", font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(
            30, 252, pageSize.width - (0 + 30), pageSize.height - 80))!;
  }

//Draws the grid
  PdfLayoutResult drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    Rect totalPriceCellBounds;
    Rect quantityCellBounds;
    //Invoke the beginCellLayout event.
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    //Draw the PDF grid and get the result.
    result = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0),
    )!;
    return result;
  }

  PdfLayoutResult drawGrid2(
      PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;
    //Invoke the beginCellLayout event.
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    //Draw the PDF grid and get the result.
    result = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(
          0, Products!.length > 4 ? result.bounds.top : result.bounds.top, 0, 0),
    )!;
    //Draw grand total.
    result.page.graphics.drawString(AppLocalizations.of(context!)!.totalGross,
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(48, result.bounds.bottom + 10,
            quantityCellBounds!.width, quantityCellBounds!.height));
    result.page.graphics.drawString(
        "${productType == 0 ? "" : productType == 1 ? " - " : ""}" +
            oCcy!.format(getTotalAmount(grid)),
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            totalPriceCellBounds!.left + 10,
            result.bounds.bottom + 10,
            totalPriceCellBounds!.width,
            totalPriceCellBounds!.height));
    double totalNet = 0;
    Products!.forEach((element) {
      totalNet += element.total;
    });
    final PdfPen linePen = PdfPen(
      PdfColor(0, 0, 0),
    );
    result.page.graphics.drawString(AppLocalizations.of(context!)!.totalNet,
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            48,
            Products!.length > 4
                ? result.bounds.top - 2
                : result.bounds.top - 15,
            quantityCellBounds!.width,
            quantityCellBounds!.height));
    result.page.graphics.drawString(AppLocalizations.of(context!)!.unitPrice,
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            150,
            Products!.length > 4
                ? result.bounds.top - 2
                : result.bounds.top - 15,
            quantityCellBounds!.width,
            quantityCellBounds!.height));
    result.page.graphics.drawString(AppLocalizations.of(context!)!.vat,
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            250,
            Products!.length > 4
                ? result.bounds.top - 2
                : result.bounds.top - 15,
            quantityCellBounds!.width,
            quantityCellBounds!.height));
    result.page.graphics.drawLine(
        linePen,
        Offset(
          0,
          Products!.length > 4 ? result.bounds.top + 10 : result.bounds.top - 4,
        ),
        Offset(
          page.size.width,
          Products!.length > 4 ? result.bounds.top + 10 : result.bounds.top - 4,
        ));
    result.page.graphics.drawLine(
        linePen,
        Offset(
          0,
          result.bounds.bottom + 22,
        ),
        Offset(
          page.size.width,
          result.bounds.bottom + 22,
        ));
    result.page.graphics.drawString(oCcy!.format(totalNet),
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            totalPriceCellBounds!.left + 10,
            Products!.length > 4
                ? result.bounds.top - 2
                : result.bounds.top - 15,
            totalPriceCellBounds!.width,
            totalPriceCellBounds!.height));

    // bottom text
    result.page.graphics.drawString(
        AppLocalizations.of(context!)!.deduction +
            "\n\n" +
            AppLocalizations.of(context!)!.kindRegards +
            "\n\n" +
            myCustomer!.title!,
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(48, result.bounds.bottom + 75, 0, 0));
    return result;
  }

//Draw the invoice footer data.
  void drawFooter(PdfPage page, Size pageSize) {
    final PdfPen linePen =
        PdfPen(PdfColor(142, 170, 219), dashStyle: PdfDashStyle.custom);
    linePen.dashPattern = <double>[3, 3];
    //Draw line
    page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
        Offset(pageSize.width, pageSize.height - 100));
    // page.graphics.drawImage(PdfUr, Rect.fromLTWH(0, 0, page.getClientSize().width, page.getClientSize().height))
  }

//Create PDF grid and return
  PdfGrid getGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 4);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];

    //Set style
    // headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.black;
    headerRow.cells[0].value = AppLocalizations.of(context!)!.productName;
    headerRow.cells[1].value = AppLocalizations.of(context!)!.unitPrice;
    headerRow.cells[2].value = AppLocalizations.of(context!)!.vat;
    headerRow.cells[3].value = AppLocalizations.of(context!)!.totalNet;

    //Add rows
    Products!.forEach((element) {
      addProducts2('''
      ${element.productName}
      ${element.quantity.toString().split(".").last == "0" ? element.quantity.toString().split(".").first : element.quantity} x ${element.quantityTypeName}
             ''', element.price, element.kdv, element.price * element.quantity,
          grid);
    });

    //Apply the table built-in style
    grid.applyBuiltInStyle(
      PdfGridBuiltInStyle.tableGridLight,
    );

    //Set gird columns width

    grid.columns[1].width = 150;
    grid.columns[0].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          //  cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 0, left: 3, right: 3, top: 3);
      }
    }
    //grid.headers.clear();

    return grid;
  }

  PdfGrid getGrid2() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 4);
    grid.style.cellSpacing = 8;
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];

    //Set style
    // headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.black;
    headerRow.cells[0].value = AppLocalizations.of(context!)!.productName;
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = AppLocalizations.of(context!)!.gross;
    headerRow.cells[2].value = AppLocalizations.of(context!)!.vat;
    headerRow.cells[3].value = AppLocalizations.of(context!)!.vatAmount;

    //Add rows
    double? total0;
    double? total5;
    double? total7;
    double? total19;


//! asagidaki eklendi

 /* Products!.where((element) => element.kdv == 0).toList().forEach((c)
     {
      if (total0.isNullOrBlank!) 
      total0 = 0;
      total0 += c.total;
*/

    Products!.where((element) => element.kdv == 0).toList().forEach((c) {
      if (total0.isNullOrBlank!) {
        total0 = 0;
      }
      total0 = total0! + c.total;
    });
   
   
   
   
    Products!.where((element) => element.kdv == 5).toList().forEach((c) {
      if (total5.isNullOrBlank!) total5 = 0;

      total5 = total5! + c.total;
    });
    Products!.where((element) => element.kdv == 7).toList().forEach((c) {
      if (total7.isNullOrBlank!) total7 = 0;

      total7 = total7! + c.total;
    });
    Products!.where((element) => element.kdv == 19).toList().forEach((c) {
      if (total19.isNullOrBlank!) total19 = 0;

      total19 = total19! + c.total;
    });
    if (!total0.isNullOrBlank!)
      addProducts(
        AppLocalizations.of(context!)!.vat,
        0,
        total0!,
        (0 / 100) * total0!,
        grid,
      );

    if (!total5.isNullOrBlank!)
      addProducts(
        AppLocalizations.of(context!)!.vat,
        5,
        total5!,
        (5 / 100) * total5!,
        grid,
      );

    if (!total7.isNullOrBlank!)
      addProducts(
        AppLocalizations.of(context!)!.vat,
        7,
        total7!,
        (7 / 100) * total7!,
        grid,
      );

    if (!total19.isNullOrBlank!)
      addProducts(
        AppLocalizations.of(context!)!.vat,
        19,
        total19!,
          (19 / 100) * total19!,
        grid,
      );
      








    //Apply the table built-in style
    /*  grid.applyBuiltInStyle(PdfGridBuiltInStyle.tableGridLight,);

   */
    //Set gird columns width

    grid.columns[1].width = 100;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
        cell.style.borders = PdfBorders(
            left: PdfPen(
                PdfColor(
                  255,
                  255,
                  255,
                ),
                width: 0),
            top: PdfPen(
                PdfColor(
                  255,
                  255,
                  255,
                ),
                width: 0),
            bottom: PdfPen(
                PdfColor(
                  255,
                  255,
                  255,
                ),
                width: 0),
            right: PdfPen(
              PdfColor(
                255,
                255,
                255,
              ),
              width: 0,
            ));
      }
    }
    grid.headers.clear();

    return grid;
  }

//Create and row for the grid.
  void addProducts(
    String productName,
    int kdv,
    double brut,
    double kdvTotal,
    PdfGrid grid,
  ) {
    final PdfGridRow row = grid.rows.add();

    row.cells[0].value = productName;
    row.cells[1].value = AppLocalizations.of(context!)!.symbol == "€"
        ? oCcy!.format(brut) + " " + String.fromCharCode(128)
        : oCcy!.format(brut) + " " + AppLocalizations.of(context!)!.symbol;
    row.cells[2].value = kdv.toString() + " %";

    row.cells[3].value = oCcy!.format(kdvTotal);
  }

  void addProducts2(String productName, double price, int kdv, double kdvTotal,
      PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = productName;
    row.cells[1].value = AppLocalizations.of(context!)!.symbol == "€"
        ? "\n" + oCcy!.format(price) + " " + String.fromCharCode(128)
        : "\n" + oCcy!.format(price) + " " + AppLocalizations.of(context!)!.symbol;

    row.cells[2].value = "\n" + kdv.toString() + " %";

    row.cells[3].value = "\n" + oCcy!.format(kdvTotal);
  }

//Get the total amount.
  double getTotalAmount(PdfGrid grid) {
    double total = 0;
    Products!.forEach((element) {
      total += element.brut;
    });

    return total;
  }
}
