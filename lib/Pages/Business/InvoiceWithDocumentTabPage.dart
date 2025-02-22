import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Controller/ControllerInvoice.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/InvoiceWithDocumentType.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Pages/Business/DirectoryDetailIWD.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:undede/Pages/Private/PrivatePage.dart';
import 'package:undede/Services/User/UserDB.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Custom/CustomLoadingCircle.dart';

class InvoiceWithDocumentPageTabPage extends StatefulWidget {
  InvoiceWithDocumentType invoiceWithDocumentType;
  int customerId;
  int customerAdminId;
  InvoiceWithDocumentPageTabPage(
      {required this.invoiceWithDocumentType,
      required this.customerId,
      required this.customerAdminId});

  @override
  _InvoiceWithDocumentPageTabPageState createState() =>
      _InvoiceWithDocumentPageTabPageState();
}

enum TargetAccount { Private, Cashbox, Bank, All }

class _InvoiceWithDocumentPageTabPageState
    extends State<InvoiceWithDocumentPageTabPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  bool isLoading = true;
  int sliderPage = 0;
  InvoiceWithDocumentType? selectedInvoiceWithDocumentType;
  CarouselController _carouselController = new CarouselController();
  CarouselSliderController _carouselSliderController =
      new CarouselSliderController();
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  UserDB userDB = new UserDB();
  AdminCustomerResult customers = AdminCustomerResult(hasError: false);
  ControllerInvoice _controllerInvoice = Get.put(ControllerInvoice());
  TargetAccount _targetAccount = TargetAccount.All;

  BuildContext? partialContext;

  final List<DropdownMenuItem> dmiCutsomers = [];

  List<bool> openMenuAnimateValue = [];
  // storage
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences? prefs;
  Timer? _timer;
  void startTime() async {
    _timer = Timer(new Duration(seconds: 1), reloadDirectoryDetail);
  }

  int? selectedTargetAccount;
  var oCcy = new NumberFormat("#,##0.00", "de_DE");
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prefs = await _prefs;
      selectedInvoiceWithDocumentType = widget.invoiceWithDocumentType;
      print("null içi değil");
      print(widget.invoiceWithDocumentType);
      // contact sayfasında da var contactleri çekiyor. --- for salary
      await userDB.GetAdminCustomer(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id,
        administrationId: _controllerDB.user.value!.result!.administrationId,
      ).then((value) {
        customers = value;

        if (prefs?.getString('savedInvoiceSettings') != null)
          _controllerInvoice.invoiceSettings.clear();

        customers.result?.asMap().forEach((index, customer) {
          if (prefs?.getString('savedInvoiceSettings') != null) {
            _controllerInvoice.invoiceSettings.clear();
            //print(prefs.getString('savedInvoiceSettings'));

            //Map<String, dynamic> ss = jsonDecode(prefs.getString('savedInvoiceSettings')) as Map<String, dynamic>;
            List<InvoiceSetting> savedInvoiceSettings =
                _controllerInvoice.mapInvoiceSettingsData(
                    jsonDecode(prefs?.getString('savedInvoiceSettings') ?? ''));

            savedInvoiceSettings.forEach((savedSetting) {
              if (savedSetting.CustomerId == customer.id) {
                // Müşteri Mevcut
                _controllerInvoice.invoiceSettings.add(InvoiceSetting(
                    savedSetting.CustomerId, savedSetting.ShowUnpaid));
              } else {
                _controllerInvoice.invoiceSettings
                    .add(InvoiceSetting(savedSetting.CustomerId, false));
              }
            });
          } else {
            print("customer.id : " + customer.id.toString());
            _controllerInvoice.invoiceSettings
                .add(InvoiceSetting(customer.id, false));
          }

          dmiCutsomers.add(DropdownMenuItem(
            child: Row(
              children: [
                /*ClipRRect(
                  borderRadius: BorderRadius.circular(27),
                  child: Image.network(
                    customer.photo ?? 'http://test.vir2ell-office.com/Content/cardpicture/userDefault.png',
                    width: 21,
                    height: 21,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),*/
                Text(customer.title ?? ''),
              ],
            ),
            value: customer.id,
            key: Key(customer.title ?? ''),
          ));
        });
      });
      startTime();
      setState(() {
        isLoading = false;
      });
    });
  }

  ClosePeriod() async {
    await _controllerInvoice.ClosePeriod(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            CustomerId: widget.customerAdminId,
            Year: _controllerInvoice.selectedYear,
            Month: _controllerInvoice.selectedMonth,
            IsFileTransfer: true)
        .then((value) {
      if (value)
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.close,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
    });
  }

  GetInvoicePeriodList() async {
    await _controllerInvoice.GetInvoicePeriodList(_controllerDB.headers(),
            CustomerId: widget.customerAdminId,
            Year: _controllerInvoice.selectedYear,
            Language: AppLocalizations.of(context)!.date)
        .then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerInvoice>(
        builder: (c) => isLoading
            ? Text("Invoice")
            //CustomLoadingCircle()
            : Scaffold(
                backgroundColor: Get.theme.scaffoldBackgroundColor,
                body: Container(
                  width: Get.width,
                  height: Get.height,
                  color: Get.theme.secondaryHeaderColor,
                  child: Column(
                    children: [
                      Container(
                        width: Get.width,
                        height: 190,
                        decoration: BoxDecoration(
                          color: Get.theme.secondaryHeaderColor,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: Get.width,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 35.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: SearchableDropdown.single(
                                                readOnly: true,
                                                color: Colors.white,
                                                height: 40,
                                                displayClearIcon: false,
                                                menuBackgroundColor: Get.theme
                                                    .scaffoldBackgroundColor,
                                                items: this.dmiCutsomers,
                                                value: widget.customerId,
                                                icon: Icon(Icons.expand_more),
                                                hint: AppLocalizations.of(
                                                        context)!
                                                    .selectOne,
                                                searchHint: AppLocalizations.of(
                                                        context)!
                                                    .selectOne,
                                                onChanged: (value) {},
                                                doneButton: AppLocalizations.of(
                                                        context)!
                                                    .done,
                                                closeButton:
                                                    AppLocalizations.of(
                                                            context)!
                                                        .close,
                                                displayItem: (item, selected) {
                                                  return (Row(children: [
                                                    selected
                                                        ? Icon(
                                                            Icons
                                                                .radio_button_checked,
                                                            color: Colors.grey,
                                                          )
                                                        : Icon(
                                                            Icons
                                                                .radio_button_unchecked,
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
                                          SizedBox(
                                            width: 7,
                                          ),
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: standartCardShadow(),
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                            child: PopupMenuButton(
                                                onSelected: (a) async {
                                                  if (a == 1) {
                                                    await ClosePeriod();

                                                    GetInvoicePeriodList();
                                                  }
                                                  if (a == 2) {
                                                    //_controllerInvoice.showUnpaid = !_controllerInvoice.showUnpaid;
                                                    _controllerInvoice
                                                            .invoiceSettings
                                                            .firstWhere((e) =>
                                                                e.CustomerId ==
                                                                widget.customerId)
                                                            .ShowUnpaid =
                                                        !_controllerInvoice
                                                            .invoiceSettings
                                                            .firstWhere((e) =>
                                                                e.CustomerId ==
                                                                widget
                                                                    .customerId)
                                                            .ShowUnpaid!;

                                                    print(jsonEncode(
                                                        _controllerInvoice
                                                            .invoiceSettings));
                                                    prefs?.setString(
                                                        'savedInvoiceSettings',
                                                        jsonEncode(
                                                            _controllerInvoice
                                                                .invoiceSettings));

                                                    _controllerInvoice
                                                        .refreshIWD = true;
                                                    _controllerInvoice.update();
                                                    //if (!_controllerInvoice.showUnpaid)
                                                    //if (!_controllerInvoice.invoiceSettings.firstWhere((e) => e.CustomerId == selectedCustomerId).ShowUnpaid)

                                                    _carouselSliderController
                                                        .jumpToPage(0);
                                                    // _carouselController .jumpToPage(0);
                                                    ////! yerine carouselSliderController kullanildi
                                                    setState(() {});
                                                  }
                                                },
                                                child: Center(
                                                    child: Icon(
                                                  Icons.filter_alt_outlined,
                                                  color: Color(0xFF5c5c5c),
                                                  size: 27,
                                                )),
                                                itemBuilder:
                                                    (context) => //! ?: operatoru yerine if kullanildi ve PopupMenuEntry kullanildi
                                                        <PopupMenuEntry<int>>[
                                                          if (_controllerInvoice
                                                                  .getInvoicePeriod
                                                                  .value!
                                                                  .result!
                                                                  .firstWhere((element) =>
                                                                      element
                                                                          .month ==
                                                                      _controllerInvoice
                                                                          .selectedMonth)
                                                                  .status ==
                                                              0)
                                                            PopupMenuItem(
                                                              child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .closePeriod),
                                                              value: 1,
                                                            ),
                                                          PopupMenuItem(
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                    _controllerInvoice
                                                                            .invoiceSettings
                                                                            .firstWhere((e) =>
                                                                                e.CustomerId ==
                                                                                widget
                                                                                    .customerId)
                                                                            .ShowUnpaid!
                                                                        ? Icons
                                                                            .radio_button_checked
                                                                        : Icons
                                                                            .radio_button_unchecked,
                                                                    color: Get
                                                                        .theme
                                                                        .secondaryHeaderColor),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(AppLocalizations.of(
                                                                        context)!
                                                                    .showUnpaid)
                                                              ],
                                                            ),
                                                            value: 2,
                                                          ),
                                                        ]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    sliderPage == 1 || sliderPage == 0
                                        ? buildRadioButtons(context)
                                        : Container(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    _controllerInvoice.invoiceSettings
                                            .firstWhere((e) =>
                                                e.CustomerId ==
                                                widget.customerId)
                                            .ShowUnpaid!
                                        ? CarouselSlider(
                                            carouselController:
                                                _carouselSliderController,
                                            items: [
                                              CarousalCard(
                                                  AppLocalizations.of(context)!
                                                      .incomePaid,
                                                  InvoiceWithDocumentType
                                                      .IncomePaid,
                                                  0,
                                                  "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"),
                                              CarousalCard(
                                                  AppLocalizations.of(context)!
                                                      .outgoingPaid,
                                                  InvoiceWithDocumentType
                                                      .OutgoingPaid,
                                                  2,
                                                  "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"),
                                              CarousalCard(
                                                  AppLocalizations.of(context)!
                                                      .incomeUnpaid,
                                                  InvoiceWithDocumentType
                                                      .IncomeUnpaid,
                                                  1,
                                                  "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"),
                                              CarousalCard(
                                                  AppLocalizations.of(context)!
                                                      .outgoingUnpaid,
                                                  InvoiceWithDocumentType
                                                      .OutgoingUnpaid,
                                                  3,
                                                  "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"),
                                            ],
                                            options: CarouselOptions(
                                              initialPage: sliderPage,
                                              onPageChanged: (i, reason) {
                                                print('Current Page  : ' +
                                                    i.toString());
                                                sliderPage = i;
                                                selectedInvoiceWithDocumentType =
                                                    getInvoiceWithDocumentByPage(
                                                        i);
                                                print('Invoice DocumentType  : ' +
                                                    selectedInvoiceWithDocumentType
                                                        .toString());

                                                setState(() {
                                                  reloadDirectoryDetail();
                                                });
                                              },
                                              reverse: false,
                                              pageSnapping: true,
                                              height: 80,
                                              aspectRatio: 4 / 3,
                                              viewportFraction: 0.83,
                                              enableInfiniteScroll: false,
                                              autoPlay: false,
                                              enlargeCenterPage: true,
                                              scrollDirection: Axis.horizontal,
                                              autoPlayAnimationDuration:
                                                  Duration(milliseconds: 800),
                                              autoPlayCurve:
                                                  Curves.fastOutSlowIn,
                                            ),
                                          )
                                        : CarouselSlider(
                                            carouselController:
                                                _carouselSliderController,
                                            items: [
                                              CarousalCard(
                                                  AppLocalizations.of(context)!
                                                      .about,
                                                  InvoiceWithDocumentType
                                                      .IncomePaid,
                                                  0,
                                                  "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"),
                                              CarousalCard(
                                                  AppLocalizations.of(context)!
                                                      .outgoingPaid,
                                                  InvoiceWithDocumentType
                                                      .OutgoingPaid,
                                                  2,
                                                  "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"),
                                            ],
                                            options: CarouselOptions(
                                              initialPage: sliderPage,
                                              onPageChanged: (i, reason) {
                                                print('Current Page  : ' +
                                                    i.toString());
                                                sliderPage = i;
                                                selectedInvoiceWithDocumentType =
                                                    getInvoiceWithDocumentByPage(
                                                        i);
                                                print('Invoice DocumentType  : ' +
                                                    selectedInvoiceWithDocumentType
                                                        .toString());

                                                setState(() {
                                                  reloadDirectoryDetail();
                                                });
                                              },
                                              reverse: false,
                                              pageSnapping: true,
                                              height: 80,
                                              aspectRatio: 4 / 3,
                                              viewportFraction: 0.83,
                                              enableInfiniteScroll: false,
                                              autoPlay: false,
                                              enlargeCenterPage: true,
                                              scrollDirection: Axis.horizontal,
                                              autoPlayAnimationDuration:
                                                  Duration(milliseconds: 800),
                                              autoPlayCurve:
                                                  Curves.fastOutSlowIn,
                                            ),
                                          ),
                                  ]),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                            child: WillPopScope(
                                onWillPop: () async {
                                  return true;
                                },
                                child: Navigator(
                                  key: _navigatorKey,
                                  onGenerateRoute: (RouteSettings settings) {
                                    WidgetBuilder builder;
                                    print(settings.name);

                                    return MaterialPageRoute(
                                      builder: (context) => DirectoryDetailIWD(
                                        customerId: widget.customerId,
                                        folderName: "",
                                        hideHeader: true,
                                        fileManagerType:
                                            FileManagerType.InvoiceDocument,
                                        todoId: null,
                                        invoiceBlock: 2,
                                        baseContext: this.context,
                                      ),
                                    );
                                  },
                                ))),
                      ),
                    ],
                  ),
                ),
              ));
  }

  void reloadDirectoryDetail() {
    print('reloadDirectoryDetail çağırıldı.');
    print(selectedInvoiceWithDocumentType.toString());
    print("SAYFA : " + sliderPage.toString());

    setState(() {
      if (sliderPage == 4) {
        _navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
          builder: (context) => DirectoryDetail(
            userId: widget.customerAdminId,
            customerId: widget.customerId,
            folderName: "",
            hideHeader: true,
            fileManagerType: FileManagerType.Report,
            todoId: 0, //! null yerine 0 yazildi
            //customerId: fType != null ? selectedCustomer.id : null
          ),
        ));
      } else {
        _navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
          builder: (context) => DirectoryDetailIWD(
            customerId: widget.customerId,
            customerAdminId: widget.customerAdminId,
            folderName: "",
            hideHeader: true,
            invoiceBlock: getInvoiceBlockWithDocumentType(
                selectedInvoiceWithDocumentType!),
            fileManagerType: FileManagerType.InvoiceDocument,
            todoId: null, SelectedInvoiceTargetAccount: selectedTargetAccount,
            //customerId: fType != null ? selectedCustomer.id : null
          ),
        ));
      }
    });
  }

  final _navigatorKey = GlobalKey<NavigatorState>();

  Widget CarousalCard(
      String title,
      InvoiceWithDocumentType invoiceWithDocumentType,
      int selectedCustomerId,
      String image) {
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: Stack(
        children: [
          Container(
            width: Get.width,
            height: 100,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 22),
            decoration: BoxDecoration(
                color: Color(0xffdedede),
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                    onError: (e, stck) {
                      return;
                    })),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title, //+ getInvoiceBlockWithDocumentType(selectedInvoiceWithDocumentType).toString(),
                    style: TextStyle(
                      fontSize: 17,
                      color: image !=
                              "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              top: 10,
              right: 10,
              child: Container(
                  height: 25,
                  width: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: image !=
                              "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"
                          ? Color(0xff243c4d)
                          : Get.theme.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Center(
                    child: Text(
                      _controllerInvoice.totalCount.toString(),
                      style: TextStyle(
                          color: image !=
                                  "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"
                              ? Colors.white
                              : Colors.black),
                    ),
                  ))),
          Positioned(
              bottom: 10,
              right: 10,
              child: Center(
                child: Text(
                  "${AppLocalizations.of(context)!.symbol} ${oCcy.format(_controllerInvoice.totalAmount)}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: image !=
                              "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"
                          ? Colors.black
                          : Colors.white),
                ),
              ))
        ],
      ),
    );
  }

  // IncomeUnpaid   0
  // IncomePaid  1
  // OutgoingUnpaid   2
  // OutgoingPaid   3

  int getPageByInvoiceWithDocumentType(
      InvoiceWithDocumentType invoiceWithDocumentType) {
    switch (invoiceWithDocumentType) {
      case InvoiceWithDocumentType.IncomeUnpaid:
        return 0;
      case InvoiceWithDocumentType.IncomePaid:
        return 1;
      case InvoiceWithDocumentType.OutgoingUnpaid:
        return 2;
      case InvoiceWithDocumentType.OutgoingPaid:
        return 3;
      default:
        return 0; //! null yerine 0 yazildi
    }
  }

  int getInvoiceBlockWithDocumentType(
      InvoiceWithDocumentType invoiceWithDocumentType) {
    switch (invoiceWithDocumentType) {
      case InvoiceWithDocumentType.IncomeUnpaid:
        return 1;
      case InvoiceWithDocumentType.IncomePaid:
        return 2;
      case InvoiceWithDocumentType.OutgoingUnpaid:
        return 3;
      case InvoiceWithDocumentType.OutgoingPaid:
        return 4;
      default:
        return 0; //! null yerine 0 yazildi
    }
  }

  InvoiceWithDocumentType getInvoiceWithDocumentByPage(int page) {
    /* sliderdaki sıralama ile eşleşir
    CarousalCard('Income Unpaid', InvoiceWithDocumentType.IncomeUnpaid),
    CarousalCard('Income Paid', InvoiceWithDocumentType.IncomePaid),
    CarousalCard('Outgoing Unpaid', InvoiceWithDocumentType.OutgoingUnpaid),
    CarousalCard('Outgoing Paid', InvoiceWithDocumentType.OutgoingPaid),*/

    if (page == 0)
      return InvoiceWithDocumentType.IncomePaid;
    else if (page == 1)
      return InvoiceWithDocumentType.OutgoingPaid;
    else if (page == 2)
      return InvoiceWithDocumentType.IncomeUnpaid;
    else if (page == 3)
      return InvoiceWithDocumentType.OutgoingUnpaid;
    else if (page == 4)
      return InvoiceWithDocumentType.OutgoingUnpaid;
    else
      return InvoiceWithDocumentType
          .IncomeUnpaid; //! null yerine bu ssatir eklendi
  }

  getBgImageByInvoiceWithDocumentType(
      InvoiceWithDocumentType invoiceWithDocumentType) {
    switch (invoiceWithDocumentType) {
      case InvoiceWithDocumentType.IncomeUnpaid:
        return NetworkImage(
            'http://test.vir2ell-office.com/Content/cardpicture/invoicewithdocument/IncomeUnpaid.png');
      case InvoiceWithDocumentType.IncomePaid:
        return NetworkImage(
            'http://test.vir2ell-office.com/Content/cardpicture/invoicewithdocument/IncomePaid.png');
      case InvoiceWithDocumentType.OutgoingUnpaid:
        return NetworkImage(
            'http://test.vir2ell-office.com/Content/cardpicture/invoicewithdocument/OutgoingUnpaid.png');
      case InvoiceWithDocumentType.OutgoingPaid:
        return NetworkImage(
            'http://test.vir2ell-office.com/Content/cardpicture/invoicewithdocument/OutgoingPaid.png');
      default:
        return null;
    }
  }

  String getTitleByinvoiceWithDocumentType(
      InvoiceWithDocumentType invoiceWithDocumentType) {
    switch (widget.invoiceWithDocumentType) {
      case InvoiceWithDocumentType.IncomeUnpaid:
        return 'Income Unpaid';
      case InvoiceWithDocumentType.IncomePaid:
        return 'Income Paid';
      case InvoiceWithDocumentType.OutgoingUnpaid:
        return 'Outgoing Unpaid';
      case InvoiceWithDocumentType.OutgoingPaid:
        return 'Outgoing Paid';
      default:
        return 'Income Unpaid'; //! null yerine bu ssatir eklendi
    }
  }

  Container buildRadioButtons(BuildContext context) {
    return Container(
      height: 30,
      width: Get.width,
      decoration: BoxDecoration(
        boxShadow: standartCardShadow(),
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      margin: EdgeInsets.symmetric(horizontal: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Row(
              children: [
                Radio<TargetAccount>(
                  focusColor: Colors.black,
                  hoverColor: Colors.black,
                  activeColor: Colors.black,
                  fillColor:
                      WidgetStateColor.resolveWith((states) => Colors.black),
                  value: TargetAccount.All,
                  groupValue: _targetAccount,
                  onChanged: (TargetAccount? value) {
                    setState(() {
                      _targetAccount = value!;
                      selectedTargetAccount = null;
                      reloadDirectoryDetail();
                    });
                  },
                ),
                Text(
                  AppLocalizations.of(context)!.all,
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.clip,
                )
              ],
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Flexible(
            child: Container(
              child: Row(
                children: [
                  Flexible(
                    child: Radio<TargetAccount>(
                      focusColor: Colors.red,
                      hoverColor: Colors.red,
                      activeColor: Colors.red,
                      fillColor:
                          WidgetStateColor.resolveWith((states) => Colors.red),
                      value: TargetAccount.Private,
                      groupValue: _targetAccount,
                      onChanged: (TargetAccount? value) {
                        setState(() {
                          _targetAccount = value!;
                          selectedTargetAccount = 1;
                          reloadDirectoryDetail();
                        });
                      },
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.private,
                      style: TextStyle(color: Colors.red),
                      overflow: TextOverflow.clip,
                    ),
                  )
                ],
              ),
            ),
          ),
          Flexible(
            child: Container(
              child: Row(
                children: [
                  Flexible(
                    child: Radio<TargetAccount>(
                      focusColor: Get.theme.primaryColor,
                      hoverColor: Get.theme.primaryColor,
                      activeColor: Get.theme.primaryColor,
                      fillColor: WidgetStateColor.resolveWith(
                          (states) => Get.theme.primaryColor),
                      value: TargetAccount.Cashbox,
                      groupValue: _targetAccount,
                      onChanged: (TargetAccount? value) {
                        setState(() {
                          _targetAccount = value!;
                          selectedTargetAccount = 2;
                          reloadDirectoryDetail();
                        });
                      },
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.cashBox,
                      style: TextStyle(color: Get.theme.primaryColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ),
          Flexible(
            child: Container(
              child: Row(
                children: [
                  Flexible(
                    child: Radio<TargetAccount>(
                      focusColor: Colors.green,
                      hoverColor: Colors.green,
                      activeColor: Colors.green,
                      fillColor: WidgetStateColor.resolveWith(
                          (states) => Colors.green),
                      value: TargetAccount.Bank,
                      groupValue: _targetAccount,
                      onChanged: (TargetAccount? value) {
                        setState(() {
                          _targetAccount = value!;
                          selectedTargetAccount = 3;
                          reloadDirectoryDetail();
                        });
                      },
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.bank,
                      style: TextStyle(color: Colors.green),
                      overflow: TextOverflow.clip,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
