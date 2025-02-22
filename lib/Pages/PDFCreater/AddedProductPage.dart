import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:undede/Pages/PDFCreater/ProductClass.dart';
import 'package:undede/Pages/PDFCreater/ProductPage.dart';

import '../../Controller/ControllerDB.dart';
import '../../Controller/ControllerInvoice.dart';
import '../../WidgetsV2/CustomAppBar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddedProductPage extends StatelessWidget {
  const AddedProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var oCcy = new NumberFormat("#,##0.00", "de-DE");
    ControllerInvoice _controllerInvoice = Get.put(ControllerInvoice());
    ControllerDB _controllerDB = Get.put(ControllerDB());
    int? selectedHandInvoice;
    List<String> dmiQuantity = [];

    Future<void> GetPositions() async {
      _controllerInvoice.GetInvoicePositions(_controllerDB.headers(),
              invoiceId: selectedHandInvoice)
          .then((value) {
        _controllerInvoice.products.clear();
        if (!value.result.isNullOrBlank!) {
          value.result!.forEach((element) {
            _controllerInvoice.products.add(Product(
              "0",
              element.positionName!,
              element.unitPrice!,
              int.tryParse(element.quantity.toString()) ??
                  double.parse(element.quantity.toString()),
              element.quantityType!,
              element.vat!,
                (element.quantity! * element.unitPrice!),
              (element.quantity! * element.unitPrice!) *
                  (1 + (element.vat! / 100)),
              dmiQuantity[element.quantityType!],
            ));
          });
        }
      });
    }

    void initState() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await GetPositions();
        dmiQuantity = [
          AppLocalizations.of(context)!.pieces,
          AppLocalizations.of(context)!.day,
          "KM",
          AppLocalizations.of(context)!.hours,
          AppLocalizations.of(context)!.flatRate
        ];
      });
    }

    Widget createProduct(int i) {
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _controllerInvoice.products[i].productName,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _controllerInvoice.products[i].quantity
                                  .toString()
                                  .split(".")
                                  .last ==
                              "0"
                          ? _controllerInvoice.products[i].quantity
                                  .toString()
                                  .split(".")
                                  .first +
                              " x "
                          : _controllerInvoice.products[i].quantity.toString() +
                              " x ",
                      style: TextStyle(fontSize: 17),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      _controllerInvoice.products[i].quantityTypeName
                          .toString(),
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      oCcy.format(_controllerInvoice.products[i].price) +
                          " " +
                          AppLocalizations.of(context)!.symbol,
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      _controllerInvoice.products[i].kdv.toString() + "%",
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      oCcy.format(_controllerInvoice.products[i].brut) +
                          " " +
                          AppLocalizations.of(context)!.symbol,
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                InkWell(
                    onTap: () {
                      _controllerInvoice.products.removeAt(i);
                      _controllerInvoice.update();
                    },
                    child: Icon(Icons.delete_outline)),
                InkWell(
                    onTap: () async {
                      Product _product = await Get.to(() =>
                          AddProduct(product: _controllerInvoice.products[i]));
                      if (_product.isNullOrBlank!) {
                        return;
                      }
                      _controllerInvoice.products[i] = _product;
                      _controllerInvoice.update();
                    },
                    child: Icon(Icons.edit_outlined))
              ],
            ),
            _controllerInvoice.products.length - 1 == i
                ? Container()
                : Divider(),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Added Position'),
      floatingActionButton:
          GetBuilder<ControllerInvoice>(builder: (controllerInvoice) {
        double sum = 0;
        _controllerInvoice.products.forEach((element) {
          sum += (element.quantity * element.price) * (1 + (element.kdv / 100));
        });
        return Container(
          margin: EdgeInsets.only(top: 10, right: 10, bottom: 5),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Get.theme.primaryColor,
              borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
              ),
                Text(AppLocalizations.of(context)!.totalGross),
              SizedBox(
                width: 20,
              ),
              Text(sum.toStringAsFixed(2) +
                  " " +
                  AppLocalizations.of(context)!.symbol),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        );
      }),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            GetBuilder<ControllerInvoice>(builder: (controllerInvoice) {
              return ListView.builder(
                  itemCount: _controllerInvoice.products.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return createProduct(
                      i,
                    );
                  });
            }),
            SizedBox(
              height: 75,
            ),
          ],
        ),
      ),
    );
  }
}
