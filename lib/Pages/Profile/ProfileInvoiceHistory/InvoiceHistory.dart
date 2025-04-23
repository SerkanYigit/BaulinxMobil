import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:undede/Custom/DebouncerForSearch.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Pages/Chat/PDFviewChat.dart';
import 'package:undede/Pages/PDFCreater/ProductClass.dart';
import 'package:undede/Pages/PDFCreater/ProductPage.dart';
import 'package:undede/Pages/Profile/ProfileCustomersBills/ProfileCustomersBills.dart';
import 'package:undede/WidgetsV2/Helper.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Invoice/GetInvoiceListResult.dart';
import 'package:undede/model/Invoice/InvoiceInsert.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../../Custom/CustomLoadingCircle.dart';
import '../../PDFView.dart' as pdfView;
import 'InvoiceHistoryDetail.dart';

class InvoiceHistory extends StatefulWidget {
  final int? CreatePage;

  const InvoiceHistory({Key? key, this.CreatePage}) : super(key: key);
  @override
  _InvoiceHistoryState createState() => _InvoiceHistoryState();
}

enum SelectData { first, second }

class _InvoiceHistoryState extends State<InvoiceHistory> {
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
  bool isListView = false;

  List<DropdownMenuItem> productType = [];

  int selectedProductType = 0;
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
      productType = [
        DropdownMenuItem(
          child: Text(AppLocalizations.of(context)!.invoice),
          value: 0,
          key: Key(AppLocalizations.of(context)!.invoice),
        ),
        DropdownMenuItem(
          child: Text(AppLocalizations.of(context)!.cancelInvoice),
          value: 1,
          key: Key(AppLocalizations.of(context)!.cancelInvoice),
        ),
        DropdownMenuItem(
          child: Text(AppLocalizations.of(context)!.offer),
          value: 2,
          key: Key(AppLocalizations.of(context)!.offer),
        ),
        DropdownMenuItem(
          child: Text(AppLocalizations.of(context)!.inquiry),
          value: 3,
          key: Key(AppLocalizations.of(context)!.inquiry),
        ),
      ];
      await _customersBills.GetAllCustomersBills(_controllerDB.headers(),
              userId: _controllerDB.user.value!.result!.id!, customerId: 0)
          .then((value) {
        value.result!.forEach((element) {
          dmiPersons.add(DropdownMenuItem(
            child: Text(element.billUserName!),
            value: element.id,
            key: Key("false" + element.billUserName!),
          ));
        });
        if (value.result!.isNotEmpty) {
          selectedPerson = value.result!.first.id;
        } else {
          selectedPerson = _controllerDB
              .user.value!.result!.userCustomers!.userCustomerList!.first.id!;
        }
        setState(() {});
      });

      var xxx = await _controllerDB
          .user.value!.result!.userCustomers!.userCustomerList!;
      //  .forEach
//! foreach yerine for kullanildi
      //((element)
      for (var element in xxx) {
        {
          dmiPersons.add(DropdownMenuItem(
            child: Text(element.customerAdminName! +
                " " +
                element.customerAdminSurname!),
            value: element.id,
            key: Key("true" +
                element.customerAdminName! +
                element.customerAdminSurname!),
          ));
        }
      }

      _controllerUser.GetCustomer(_controllerDB.headers(),
              Id: _controllerDB.user.value!.result!.customerId!)
          .then((value) {
        setState(() {});
      });
      await GetInvoiceHandMadeInvoice();

      isLoading = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> GetInvoiceHandMadeInvoice({String Search = ""}) async {
    _controllerInvoice.GetInvoiceHandMadeInvoice(_controllerDB.headers(),
            UserId: _controllerDB
                .user.value!.result!.userCustomers!.userCustomerList!
                .firstWhere((element) =>
                    element.id == _controllerDB.user.value!.result!.customerId!)
                .customerAdminId!,
            CreatedForUserId: selectedPerson,
            MyCustomer: dmiPersons
                .firstWhere((element) => element.value == selectedPerson)
                .key
                .toString()
                .contains("true"),
            Year: selectedYear,
            Month: selectedMonth,
            InvoiceType: selectedProductType,
            Search: Search)
        .then((value) {
      _invoiceHistoryResult = value;

      setState(() {});
    });
  }

  final formKey = GlobalKey<FormState>();
  var oCcy = new NumberFormat("#,##0.00", "de-DE");
  final _debouncer = DebouncerForSearch();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      //Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.invoiceHistory),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [],
      ),
      floatingActionButton: isLoading
          ? Container()
          : _invoiceHistoryResult.historyResult != null
              ? Builder(builder: (context) {
                  double sum = 0;

                  _invoiceHistoryResult.historyResult!.forEach((element) {
                    sum += element.taxAddAmount!;
                  });
                  return Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: 35,
                            top: 10,
                            bottom: widget.CreatePage != null
                                ? 0
                                : WidgetsBinding
                                            .instance.window.viewInsets.bottom >
                                        0
                                    ? 0
                                    : 100),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.pink,
                            //Get.theme.primaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Text(_invoiceHistoryResult.historyResult!.length ==
                                    null
                                ? "0"
                                : _invoiceHistoryResult.historyResult!.length
                                    .toString()),
                            SizedBox(
                              width: 20,
                            ),
                            Text(AppLocalizations.of(context)!.invoice),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Container(
                        margin: EdgeInsets.only(
                            top: 10,
                            bottom: widget.CreatePage != null
                                ? 0
                                : WidgetsBinding
                                            .instance.window.viewInsets.bottom >
                                        0
                                    ? 0
                                    : 100),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.pink,
                            // Get.theme.primaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Text(oCcy.format(sum) +
                                " " +
                                AppLocalizations.of(context)!.symbol),
                            SizedBox(
                              width: 20,
                            ),
                            Text(AppLocalizations.of(context)!.totalGross),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                })
              : Container(),

      body: isLoading
          ? CustomLoadingCircle()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
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
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: standartCardShadow(),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                          ),
                          child: SearchableDropdown.single(
                            color: Colors.white,
                            height: 42,
                            displayClearIcon: false,
                            menuBackgroundColor:
                                Get.theme.scaffoldBackgroundColor,
                            value: selectedProductType,
                            items: productType,
                            onChanged: (value) {
                              setState(() {
                                selectedProductType = value;
                              });
                              GetInvoiceHandMadeInvoice();
                            },
                            icon: Icon(Icons.expand_more),
                            hint: AppLocalizations.of(context)!.selectType,
                            searchHint:
                                AppLocalizations.of(context)!.selectType,
                            doneButton: AppLocalizations.of(context)!.done,
                            displayItem: (item, selected) {
                              return (Row(children: [
                                selected
                                    ? Icon(
                                        Icons.radio_button_checked,
                                        color: Colors.grey,
                                      )
                                    : Icon(
                                        Icons.radio_button_unchecked,
                                        color: Colors.grey,
                                      ),
                                SizedBox(width: 7),
                                Expanded(
                                  child: item,
                                ),
                              ]));
                            },
                            isExpanded: true,
                            searchFn: dropdownSearchFn,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: standartCardShadow(),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.grey[400]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: SearchableDropdown.single(
                                      color: Colors.white,
                                      height: 40,
                                      displayClearIcon: false,
                                      menuBackgroundColor:
                                          Get.theme.scaffoldBackgroundColor,
                                      value: selectedPerson,
                                      items: dmiPersons,
                                      icon: Icon(Icons.expand_more),
                                      hint: AppLocalizations.of(context)!
                                          .selectType,
                                      searchHint: AppLocalizations.of(context)!
                                          .selectType,
                                      onChanged: (value) async {
                                        setState(() {
                                          selectedPerson = value;
                                          GetInvoiceHandMadeInvoice();
                                        });
                                      },
                                      doneButton:
                                          AppLocalizations.of(context)!.done,
                                      displayItem: (item, selected) {
                                        return (Row(children: [
                                          selected
                                              ? Icon(
                                                  Icons.radio_button_checked,
                                                  color: Colors.grey,
                                                )
                                              : Icon(
                                                  Icons.radio_button_unchecked,
                                                  color: Colors.grey,
                                                ),
                                          SizedBox(width: 7),
                                          Expanded(
                                            child: item,
                                          ),
                                        ]));
                                      },
                                      isExpanded: true,
                                      searchFn: dropdownSearchFn,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: FloatingActionButton(
                                    mini: true,
                                    key: Key("InvoiceHistory"),
                                    heroTag: "InvoiceHistory",
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileCustomersBills()));
                                    },
                                    backgroundColor:
                                        Get.theme.colorScheme.primary,
                                    child: Icon(
                                      Icons.add,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: standartCardShadow(),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                          ),
                          child: CustomTextField(
                            label: AppLocalizations.of(context)!.search,
                            onChanged: (text) async {
                              await _debouncer.run(() {
                                GetInvoiceHandMadeInvoice(Search: text);
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 35,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ScrollablePositionedList.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: months.length,
                                      initialScrollIndex: selectedMonth - 1,
                                      initialAlignment: 0.5,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              selectedMonth = index + 1;
                                              _controllerInvoice.selectedMonth =
                                                  selectedMonth;
                                            });
                                            //   await refresh();
                                            GetInvoiceHandMadeInvoice();
                                          },
                                          child: Container(
                                              width: 35,
                                              height: 35,
                                              key: selectedMonth == index + 1
                                                  ? selectedMonthKey
                                                  : null,
                                              margin: EdgeInsets.only(right: 5),
                                              decoration: BoxDecoration(
                                                  color: Color(0xFF0cab69),
                                                  boxShadow:
                                                      standartCardShadow(),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: selectedMonth -
                                                                  1 ==
                                                              index
                                                          ? Color(0x0ff0079bf)
                                                          : Colors.transparent,
                                                      width: 4)),
                                              child: Center(
                                                  child: Text(months[index]))),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .selectYear),
                                        content: Container(
                                          // Need to use container to add size constraint.
                                          width: 300,
                                          height: 300,
                                          child: YearPicker(
                                            firstDate: DateTime(
                                                DateTime.now().year - 7, 1),
                                            lastDate: DateTime(
                                                DateTime.now().year + 7, 1),
                                            initialDate: DateTime.now(),
                                            selectedDate:
                                                DateTime(selectedYear),
                                            onChanged:
                                                (DateTime dateTime) async {
                                              Navigator.pop(context);

                                              setState(() {
                                                selectedYear = dateTime.year;
                                                _controllerInvoice
                                                        .selectedYear =
                                                    dateTime.year;
                                              });
                                              GetInvoiceHandMadeInvoice();
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                    width: 70,
                                    height: 35,
                                    margin: EdgeInsets.only(right: 5),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      //Get.theme.colorScheme.surface,
                                      boxShadow: standartCardShadow(),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(selectedYear.toString()),
                                    )),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isListView = !isListView;
                                  });
                                },
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    //Get.theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isListView
                                        ? Icons.description_outlined
                                        : Icons.format_list_bulleted,
                                    size: 21,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: isListView
                      ? buildListviewMode()
                      : _invoiceHistoryResult.historyResult != null
                          ? buildPreviewMode()
                          : Container(),
                ),
                widget.CreatePage != null
                    ? Container()
                    : SizedBox(
                        height:
                            WidgetsBinding.instance.window.viewInsets.bottom > 0
                                ? 0
                                : 90,
                      ),
              ],
            ),
    );
  }

  Widget FileViewInListView(HistoryResult item, int index) {
    var dateFormatter =
        new DateFormat("dd/MM/yyyy", AppLocalizations.of(context)!.localeName);

    return GestureDetector(
      onTap: () {
        Get.to(() => PDFviewChat(
              file: File(item.file!
                  .path!), //! File icerisine alindi. InvoiceFile olara degistirildi
              thumNail: item.file!.thumbnailPath!,
              pdf: item.file!.path!,
            ));
      },
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
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
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
                      borderRadius: BorderRadius.circular(10)),
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
                              item.invoiceNumber.isNullOrBlank!
                                  ? ""
                                  : item.invoiceNumber!,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: Get.width - 145,
                              child: Row(
                                children: [
                                  Text(
                                    "${dateFormatter.format(DateTime.parse(item.createDate!))}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${AppLocalizations.of(context)!.symbol} ${item.taxAddAmount == null ? "0,0" : oCcy.format(item.taxAddAmount)}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

  ListView buildListviewMode() {
    return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _invoiceHistoryResult.historyResult!.length == null
            ? 0
            : _invoiceHistoryResult.historyResult!.length,
        itemBuilder: (context, index) {
          HistoryResult inv = _invoiceHistoryResult.historyResult![index];
          return FileViewInListView(inv, index);
        });
  }

  GridView buildPreviewMode() {
    return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shrinkWrap: true,
        cacheExtent: 100,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: 250,
            maxCrossAxisExtent: (Get.width / 2 - 14),
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 15,
            mainAxisSpacing: 8),
        itemCount: _invoiceHistoryResult.historyResult!.length == null
            ? 0
            : _invoiceHistoryResult.historyResult!.length,
        itemBuilder: (BuildContext ctx, index) {
          HistoryResult inv;

          inv = _invoiceHistoryResult.historyResult![index];

          return GestureDetector(
            onTap: () {
              Get.to(() => PDFviewChat(
                    file: File(inv.file!.path!), //! file parametresi eklendi
                    thumNail: inv.file!.thumbnailPath!,
                    pdf: inv.file!.path!,
                  ));
            },
            child: Column(
              children: [
                Container(
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 0.5),
                    color: Colors.transparent,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 250,
                              width: (Get.width / 2 - 14),
                              child: CachedNetworkImage(
                                imageUrl: inv.file!.thumbnailPath!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                placeholder: (context, url) =>
                                    new CustomLoadingCircle(),
                              ),
                            ),
                            Positioned(
                              bottom: 30,
                              right: 5,
                              child: Image.asset(
                                getImagePathByFileExtension(
                                    inv.file!.fileName!.split('.').last),
                                width: 27,
                              ),
                            ),
                            Positioned(
                                left: 5,
                                top: 5,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: inv.invoiceTargetAccountId == 1
                                          ? Colors.red
                                          : inv.invoiceTargetAccountId == 2
                                              ? Get.theme.primaryColor
                                              : Colors.green,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Center(
                                    child: Icon(
                                      inv.invoiceTargetAccountId == 1
                                          ? Icons.account_balance_wallet
                                          : inv.invoiceTargetAccountId == 2
                                              ? Icons.payments
                                              : Icons.credit_card,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                            Positioned(
                              bottom: 0,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 25,
                                    width: Get.width / 2 - 27,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Spacer(),
                                        Text(
                                            "${AppLocalizations.of(context)!.symbol} ${inv.taxAddAmount == null ? "0,00" : oCcy.format(inv.taxAddAmount)}"),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
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
                    _controllerInvoice.products[i].quantityTypeName.toString(),
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
          _controllerInvoice.products.length - 1 == i ? Container() : Divider(),
        ],
      ),
    );
  }
}
