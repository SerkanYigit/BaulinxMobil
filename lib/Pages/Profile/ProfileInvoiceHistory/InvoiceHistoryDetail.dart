import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undede/Controller/ControllerCustomersBills.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerInvoice.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Pages/PDFCreater/ProductClass.dart';
import 'package:undede/Pages/PDFCreater/ProductPage.dart';
import 'package:undede/Pages/Profile/ProfileCustomersBills/ProfileCustomersBills.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/model/Invoice/GetInvoiceListResult.dart';
import 'package:undede/model/Invoice/InvoiceInsert.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../../Custom/CustomLoadingCircle.dart';

class InvoiceHistoryDetail extends StatefulWidget {
  final int? invoiceId;

  const InvoiceHistoryDetail({Key? key, this.invoiceId}) : super(key: key);
  @override
  _InvoiceHistoryDetailState createState() => _InvoiceHistoryDetailState();
}

enum SelectData { first, second }

class _InvoiceHistoryDetailState extends State<InvoiceHistoryDetail> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCustomersBills _customersBills =
      Get.put(ControllerCustomersBills());
  ControllerUser _controllerUser = Get.put(ControllerUser());
  ControllerInvoice _controllerInvoice = Get.put(ControllerInvoice());
  DateTime startDate = DateTime.now();
  DateTime startDate1 = DateTime.now();
  DateTime endDate1 = DateTime.now();

  bool isLoading = true;
  final List<DropdownMenuItem> dmiPersons = [];
  int? selectedPerson;

  bool isSelected = false;
  SelectData _data = SelectData.first;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences? prefs;
  List<String> dmiQuantity = [];
  List<String> months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];
  int selectedMonth = DateTime.now().month;
  final selectedMonthKey = GlobalKey();
  int selectedYear = DateTime.now().year;
  InvoiceHistoryResult _invoiceHistoryResult = InvoiceHistoryResult();
  List<Product> _list = [];
  Future<void> GetPositions() async {
    _list = [];
    _controllerInvoice.GetInvoicePositions(_controllerDB.headers(),
            invoiceId: widget.invoiceId)
        .then((value) {
      _controllerInvoice.products.clear();
      if (!value.result!.isNullOrBlank!) {
        value.result!.forEach((element) {
          _list.add(Product(
            "0",
            element.positionName!,
            element.unitPrice!,
            int.tryParse(element.quantity.toString()) ??
                double.parse(element.quantity.toString()),
            element.quantityType!,
            element.vat!,
            (element.quantity! * element.unitPrice!),
            (element.quantity! * element.unitPrice!) * (1 + (element.vat! / 100)),
            dmiQuantity[element.quantityType!],
          ));
        });
      }
      setState(() {});
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prefs = await _prefs;
      dmiQuantity = [
        AppLocalizations.of(context)!.pieces,
        AppLocalizations.of(context)!.day,
        "KM",
        AppLocalizations.of(context)!.hours,
        AppLocalizations.of(context)!.flatRate
      ];

      GetPositions();
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> GetInvoiceHandMadeInvoice() async {
    _controllerInvoice.GetInvoiceHandMadeInvoice(_controllerDB.headers(),
            UserId: _controllerDB
                .user.value!.result!.userCustomers!.userCustomerList!
                .firstWhere((element) =>
                    element.id == _controllerDB.user.value!.result!.customerId)
                .customerAdminId,
            CreatedForUserId: selectedPerson,
            MyCustomer: dmiPersons
                .firstWhere((element) => element.value == selectedPerson)
                .key
                .toString()
                .contains("true"),
            Year: selectedYear,
            Month: selectedMonth)
        .then((value) {
      _invoiceHistoryResult = value;

      setState(() {});
    });
  }

  /*Future<void> GetPositions() async {
    _controllerInvoice.GetInvoicePositions(_controllerDB.headers(),
            invoiceId: selectedHandInvoice)
        .then((value) {
      _controllerInvoice.products.clear();
      if (!value.result.isNullOrBlank) {
        value.result.forEach((element) {
          _controllerInvoice.products.add(Product(
            "0",
            element.positionName,
            element.unitPrice,
            int.tryParse(element.quantity.toString()) ??
                double.parse(element.quantity.toString()),
            element.quantityType,
            element.vat,
            (element.quantity * element.unitPrice),
            (element.quantity * element.unitPrice) * (1 + (element.vat / 100)),
            dmiQuantity[element.quantityType],
          ));
        });
      }
      setState(() {});
    });


    setState(() {});
  }
*/
  final formKey = GlobalKey<FormState>();
  var oCcy = new NumberFormat("#,##0.00", "de-DE");

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.invoicePosition),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [],
      ),

      //resizeToAvoidBottomInset: false,
      body: isLoading
          ? CustomLoadingCircle()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            GetBuilder<ControllerInvoice>(
                                builder: (controllerInvoice) {
                              return ListView.builder(
                                  itemCount: _list.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, i) {
                                    return createProduct(i, _list);
                                  });
                            }),
                            SizedBox(
                              height: 75,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget FileViewInListView(HistoryResult item, int index) {
    var dateFormatter =
        new DateFormat.yMMMMd(AppLocalizations.of(context)!.localeName);

    return GestureDetector(
      onTap: () {},
      child: Container(
        color: isSelected ? Colors.grey : null,
        width: Get.width,
        height: 80,
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Icon(
                      Icons.receipt_long,
                      size: 25,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  /*if (details.primaryVelocity > 0) {
                    setState(() {
                      openMenuAnimateValue[index] = false;
                    });
                  }*/
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.invoiceName!,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "${dateFormatter.format(DateTime.parse(item.createDate!))}",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: Get.width - 145,
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: item.taxFreeAmount == null
                                            ? Colors.red
                                            : Colors.green,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    width: 18,
                                    height: 18,
                                    child: Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                      "${AppLocalizations.of(context)!.symbol} ${item.taxAddAmount == null ? "0,0" : oCcy.format(item.taxAddAmount)}"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      /*Container(
                        width: 80,
                        height: 70,
                        child: Stack(
                          children: [
                            AnimatedOpacity(
                              opacity: openMenuAnimateValue[index] ? 0 : 1,
                              duration: Duration(milliseconds: 700),
                              curve: Curves.fastOutSlowIn,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    openMenuAnimateValue[index] =
                                    !openMenuAnimateValue[index];
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 15),
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.menu_open,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              height: 70,
                              width: openMenuAnimateValue[index] ? 80 : 0,
                              right: openMenuAnimateValue[index] ? 0 : 0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInBack,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                child: Container(
                                  height: 70,
                                  width: 90,
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                color: Get
                                                    .theme.secondaryHeaderColor
                                                    .withOpacity(0.8),
                                                padding:
                                                EdgeInsets.only(left: 10),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 15,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )),
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                color: Get
                                                    .theme.secondaryHeaderColor,
                                                padding:
                                                EdgeInsets.only(left: 10),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.file_upload,
                                                    size: 17,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            color: Colors.white),
                                        width: 15,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )*/
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget createProduct(int i, List<Product> product) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product[i].productName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    product[i].quantity.toString().split(".").last == "0"
                        ? product[i].quantity.toString().split(".").first +
                            " x "
                        : product[i].quantity.toString() + " x ",
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    product[i].quantityTypeName.toString(),
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    oCcy.format(product[i].price) +
                        " " +
                        AppLocalizations.of(context)!.symbol,
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    product[i].kdv.toString() + "%",
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    oCcy.format(product[i].brut) +
                        " " +
                        AppLocalizations.of(context)!.symbol,
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ],
          ),
          product.length - 1 == i ? Container() : Divider(),
        ],
      ),
    );
  }
}
