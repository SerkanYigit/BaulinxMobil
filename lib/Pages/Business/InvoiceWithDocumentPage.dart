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
import 'package:undede/Controller/ControllerInvoice.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Custom/InvoiceWithDocumentType.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Pages/Business/DirectoryDetailIWD.dart';
import 'package:undede/Pages/Business/DirectoryDetailWithOuFileWD.dart';
import 'package:undede/Pages/Business/InvoiceStatistic.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:undede/Pages/Private/PrivatePage.dart';
import 'package:undede/Services/Invoice/InvoiceDB.dart';
import 'package:undede/Services/User/UserDB.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Invoice/GetAccountTypeListResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Custom/CustomLoadingCircle.dart';
import '../../WidgetsV2/CustomAppBarWithSearch.dart';
import '../Notification/NotificationPage.dart';

class InvoiceWithDocumentPage extends StatefulWidget {
  InvoiceWithDocumentType invoiceWithDocumentType;
  bool WithOutDocument;
  int invoiceType;

  InvoiceWithDocumentPage(
      {required this.invoiceWithDocumentType,
      this.WithOutDocument = false,
      this.invoiceType = 0});

  @override
  _InvoiceWithDocumentPageState createState() =>
      _InvoiceWithDocumentPageState();
}

enum TargetAccount { Private, Cashbox, Bank, All }

class _InvoiceWithDocumentPageState extends State<InvoiceWithDocumentPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool isLoading = true;
  int sliderPage = 0;
  InvoiceWithDocumentType? selectedInvoiceWithDocumentType;
  CarouselController _carouselController = new CarouselController();
  CarouselSliderController? _carouselSliderController;
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  UserDB userDB = new UserDB();
  AdminCustomerResult customers = new AdminCustomerResult(hasError: false);
  ControllerInvoice _controllerInvoice = Get.put(ControllerInvoice());
  TargetAccount _targetAccount = TargetAccount.All;
  InvoiceDB _invoiceDb = new InvoiceDB();
  List<AccountType> accountTypeList = <AccountType>[];
  BuildContext? partialContext;

  int selectedCustomerId = 0;
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

  List<DropdownMenuItem> cboInvoiceBlock = [];
  int selectedInvoiceBlock = 0;
  // *.*.*.*.
  final List<DropdownMenuItem> cboAccountTypeList = [];
  int? _selectedAccountType;
  // *.*.*.*.
  final List<DropdownMenuItem> cboTaxAccountList = [];
  int? _selectedTaxAccount;
  // *.*.*.*.
  TextEditingController _controllerWithKdv = TextEditingController();
  TextEditingController _controllerWithOutKdv = TextEditingController();
  TextEditingController _controllerDescription = TextEditingController();
  // *.*.*.*.

  int _fileTypeId = 0;
  List<DropdownMenuItem> cboFileSelection = [];

  int? selectedYear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      selectedYear = _controllerInvoice.selectedYear;
      cboInvoiceBlock = [
        DropdownMenuItem(
          child: Row(
            children: [
              Text(getTitleByInvoiceBlock(1, context)),
            ],
          ),
          value: 1,
          key: Key(getTitleByInvoiceBlock(1, context)),
        ),
        DropdownMenuItem(
          child: Row(
            children: [
              Text(getTitleByInvoiceBlock(2, context)),
            ],
          ),
          value: 2,
          key: Key(getTitleByInvoiceBlock(2, context)),
        ),
        DropdownMenuItem(
          child: Row(
            children: [
              Text(getTitleByInvoiceBlock(3, context)),
            ],
          ),
          value: 3,
          key: Key(getTitleByInvoiceBlock(3, context)),
        ),
        DropdownMenuItem(
          child: Row(
            children: [
              Text(getTitleByInvoiceBlock(4, context)),
            ],
          ),
          value: 4,
          key: Key(getTitleByInvoiceBlock(4, context)),
        )
      ];
      cboFileSelection = [
        DropdownMenuItem(
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.allInvoice),
            ],
          ),
          value: 0,
          key: Key(AppLocalizations.of(context)!.allInvoice),
        ),
        DropdownMenuItem(
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.onlyFile),
            ],
          ),
          value: 1,
          key: Key(AppLocalizations.of(context)!.onlyFile),
        ),
        DropdownMenuItem(
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.onlyWithOutFile),
            ],
          ),
          value: 2,
          key: Key(AppLocalizations.of(context)!.onlyWithOutFile),
        ),
      ];
      getAccountType(1);
      getTaxAccountList();
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
        //prefs.remove('savedInvoiceSettings');

        customers.result!.asMap().forEach((index, customer) {
          if (prefs?.getString('savedInvoiceSettings') != null) {
            _controllerInvoice.invoiceSettings.clear();
            print("---------------------------");
            //print(prefs.getString('savedInvoiceSettings'));

            //Map<String, dynamic> ss = jsonDecode(prefs.getString('savedInvoiceSettings')) as Map<String, dynamic>;
            List<InvoiceSetting> savedInvoiceSettings =
                _controllerInvoice.mapInvoiceSettingsData(
                    jsonDecode(prefs!.getString('savedInvoiceSettings')!));
            _controllerInvoice.invoiceSettings = savedInvoiceSettings;
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
            key: Key(customer.title ?? ''),
            value: customer.id,
          ));
        });

        if (dmiCutsomers.isNotEmpty) {
          selectedCustomerId = dmiCutsomers.first.value;
          if (prefs?.getInt("selectedUser") == null) {
            print("selectedUser null");
            prefs?.setInt("selectedUser", dmiCutsomers.first.value);
            selectedCustomerId = dmiCutsomers.first.value;
          } else {
            selectedCustomerId = prefs!.getInt("selectedUser")!;
            print("selectedUser : " + selectedCustomerId.toString());
          }
        }
      });

      startTime();
      if (widget.WithOutDocument) {
        setState(() {
          sliderPage = 2;
        });
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  ClosePeriod() async {
    await _controllerInvoice.ClosePeriod(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            CustomerId: selectedCustomerId,
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
            CustomerId: selectedCustomerId,
            Year: _controllerInvoice.selectedYear,
            Language: AppLocalizations.of(context)!.date)
        .then((value) {});
  }

  Future<void> getAccountType(int type) async {
    cboAccountTypeList.clear();
    await _invoiceDb.GetAccountTypeList(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, Type: type)
        .then((value) {
      accountTypeList = value.result ?? [];
      setState(() {
        accountTypeList.asMap().forEach((index, accountType) {
          cboAccountTypeList.add(DropdownMenuItem(
            child: Row(
              children: [
                Text(accountType.accountNumber.toString() +
                    " " +
                    accountType.description!),
              ],
            ),
            value: accountType.id,
            key: Key(accountType.description ?? ''),
          ));
        });
      });
    });
  }

  Future<void> getTaxAccountList() async {
    await _invoiceDb.GetTaxAccountList(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, Type: 1)
        .then((value) {
      value.result!.asMap().forEach((index, taxAccount) {
        cboTaxAccountList.add(DropdownMenuItem(
          child: Row(
            children: [
              Text(taxAccount.accountName ?? ''),
            ],
          ),
          value: taxAccount.id,
          key: Key(taxAccount.accountName ?? ''),
        ));
      });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }

  List<DropdownMenuItem<InvoiceWithDocumentType>> getDropdownItems() {
    return [
      DropdownMenuItem(
        value: InvoiceWithDocumentType.IncomePaid,
        child: Text(AppLocalizations.of(context)!.incomePaid),
      ),
      DropdownMenuItem(
        value: InvoiceWithDocumentType.OutgoingPaid,
        child: Text(AppLocalizations.of(context)!.outgoingPaid),
      ),
      DropdownMenuItem(
        value: InvoiceWithDocumentType.IncomeUnpaid,
        child: Text(AppLocalizations.of(context)!.incomeUnpaid),
      ),
      DropdownMenuItem(
        value: InvoiceWithDocumentType.OutgoingUnpaid,
        child: Text(AppLocalizations.of(context)!.outgoingUnpaid),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useTabletLayout = shortestSide > 600;
    return GetBuilder<ControllerInvoice>(
        builder: (c) => isLoading
            ? Text("Invoice")
            //CustomLoadingCircle()
            : Scaffold(
                key: _scaffoldKey,
                backgroundColor: Get.theme.scaffoldBackgroundColor,
                endDrawer: Container(
                  width: Get.width / 1.5,
                  child: Scaffold(
                    appBar: CustomAppBar(
                      title: AppLocalizations.of(context)!.filter,
                      showNotification: false,
                    ),
                    body: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          (sliderPage == 2 &&
                                      !_controllerInvoice.invoiceSettings
                                          .firstWhere(
                                              (e) =>
                                                  e.CustomerId ==
                                                  selectedCustomerId,
                                              orElse: () {
                                        return InvoiceSetting(0,
                                            false); //! return sonrasi eklendi
                                      }).ShowUnpaid!) ||
                                  (_controllerInvoice.invoiceSettings
                                          .firstWhere(
                                              (e) =>
                                                  e.CustomerId ==
                                                  selectedCustomerId,
                                              orElse: () {
                                        return InvoiceSetting(0,
                                            false); //! return sonrasi eklendi
                                      }).ShowUnpaid! &&
                                      sliderPage == 4)
                              ? SearchableDropdown.single(
                                  color: Colors.white,
                                  height: 45,
                                  displayClearIcon: false,
                                  menuBackgroundColor:
                                      Get.theme.scaffoldBackgroundColor,
                                  items: cboInvoiceBlock,
                                  value: selectedInvoiceBlock,
                                  icon: Icon(Icons.expand_more),
                                  hint:
                                      AppLocalizations.of(context)!.accountType,
                                  searchHint:
                                      AppLocalizations.of(context)!.accountType,
                                  onChanged: (value) async {
                                    setState(() {
                                      selectedInvoiceBlock = value;
                                    });
                                    print(value);
                                    if (value == 1 || value == 3) {
                                      await getAccountType(2);
                                    } else {
                                      await getAccountType(1);
                                    }
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
                                )
                              : Container(),
                          SizedBox(
                            height: 15,
                          ),
                          SearchableDropdown.single(
                            color: Colors.white,
                            height: 45,
                            displayClearIcon: false,
                            menuBackgroundColor:
                                Get.theme.scaffoldBackgroundColor,
                            items: cboTaxAccountList,
                            value: _selectedTaxAccount,
                            icon: Icon(Icons.expand_more),
                            hint: AppLocalizations.of(context)!.tax,
                            searchHint: AppLocalizations.of(context)!.tax,
                            onChanged: (value) async {
                              setState(() {
                                _selectedTaxAccount = value;
                              });
                            },
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
                          SizedBox(
                            height: 15,
                          ),
                          SearchableDropdown.single(
                            color: Colors.white,
                            height: 45,
                            displayClearIcon: false,
                            menuBackgroundColor:
                                Get.theme.scaffoldBackgroundColor,
                            items: cboAccountTypeList,
                            value: _selectedAccountType,
                            icon: Icon(Icons.expand_more),
                            hint: AppLocalizations.of(context)!.accountType,
                            searchHint:
                                AppLocalizations.of(context)!.accountType,
                            onChanged: (value) async {
                              setState(() {
                                _selectedAccountType = value;
                              });
                            },
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
                          SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            controller: _controllerWithKdv,
                            label: AppLocalizations.of(context)!.withKdv,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            controller: _controllerWithOutKdv,
                            label: AppLocalizations.of(context)!.withOutKdv,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            controller: _controllerDescription,
                            label: AppLocalizations.of(context)!.search,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          (sliderPage == 2 &&
                                      !_controllerInvoice.invoiceSettings
                                          .firstWhere(
                                              (e) =>
                                                  e.CustomerId ==
                                                  selectedCustomerId,
                                              orElse: () {
                                        return InvoiceSetting(0,
                                            false); //! return sonrasi eklendi
                                      }).ShowUnpaid!) ||
                                  (_controllerInvoice.invoiceSettings
                                          .firstWhere(
                                              (e) =>
                                                  e.CustomerId ==
                                                  selectedCustomerId,
                                              orElse: () {
                                        return InvoiceSetting(0,
                                            false); //! return sonrasi eklendi
                                      }).ShowUnpaid! &&
                                      sliderPage == 4)
                              ? SearchableDropdown.single(
                                  color: Colors.white,
                                  height: 45,
                                  displayClearIcon: false,
                                  menuBackgroundColor:
                                      Get.theme.scaffoldBackgroundColor,
                                  items: cboFileSelection,
                                  value: _fileTypeId,
                                  icon: Icon(Icons.expand_more),
                                  hint:
                                      AppLocalizations.of(context)!.accountType,
                                  searchHint:
                                      AppLocalizations.of(context)!.accountType,
                                  onChanged: (value) async {
                                    setState(() {
                                      _fileTypeId = value;
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
                                )
                              : Container(),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(),
                                    onPressed: () {
                                      setState(() {
                                        reloadDirectoryDetail();
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                        child: Center(
                                      child: Text(
                                          AppLocalizations.of(context)!.filter),
                                    ))),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  _controllerDescription.clear();
                                  _controllerWithKdv.clear();
                                  _controllerWithOutKdv.clear();
                                  _selectedAccountType = null;
                                  _selectedTaxAccount = null;
                                  selectedInvoiceBlock = 0;
                                  _fileTypeId = 0;
                                  setState(() {
                                    reloadDirectoryDetail();
                                  });
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Get.theme.primaryColor),
                                    child: Icon(
                                      Icons.delete_outline_outlined,
                                      color: Colors.white,
                                    )),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                appBar: CustomAppBarWithSearch(
                  isInvoicePage: true,
                  isHomePage: false,
                  selectedCustomerId: selectedCustomerId,
                  title: widget.invoiceType == 2
                      ? AppLocalizations.of(context)!.offer
                      : widget.invoiceType == 3
                          ? AppLocalizations.of(context)!.inquiry
                          : AppLocalizations.of(context)!.invoiceWithDocument,
                  isNotificationsOpen: true,
                  isSearchOpen: false,
                  onChanged: (as) async {},
                  controllerInvoice: _controllerInvoice,
                  onChangedForInvoiceRadio2: (index, TargetAccount value) {
                    setState(() {
                      _targetAccount = value;
                      selectedTargetAccount = index == 1 ? null : index - 1;
                      reloadDirectoryDetail();
                    });
                  },
                  openFilterFunction: () {
                    _openEndDrawer();
                  },
                  openBoardFunction: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                NotificationPage()));
                  },
                  onChangedForInvoiceRadio: (a) async {
                    if (a == 1) {
                      await ClosePeriod();
                      GetInvoicePeriodList();
                    }
                    if (a == 2) {
                      await _controllerInvoice.OpenPeriod(
                          _controllerDB.headers(),
                          UserId: _controllerDB.user.value!.result!.id,
                          CustomerId: selectedCustomerId,
                          Year: _controllerInvoice.selectedYear,
                          Month: _controllerInvoice.selectedMonth,
                          IsFileTransfer: true);

                      GetInvoicePeriodList();
                    }
                    if (a == 3) {
                      await _controllerInvoice.ConfirmPeriod(
                          _controllerDB.headers(),
                          UserId: _controllerDB.user.value!.result!.id,
                          CustomerId: selectedCustomerId,
                          Year: _controllerInvoice.selectedYear,
                          Month: _controllerInvoice.selectedMonth,
                          IsFileTransfer: true);

                      GetInvoicePeriodList();
                    }
                    if (a == 5) {
                      //_controllerInvoice.showUnpaid = !_controllerInvoice.showUnpaid;
                      _controllerInvoice.invoiceSettings
                              .firstWhere((e) => e.CustomerId == selectedCustomerId)
                              .ShowUnpaid =
                          !_controllerInvoice.invoiceSettings
                              .firstWhere(
                                  (e) => e.CustomerId == selectedCustomerId)
                              .ShowUnpaid!;

                      print(jsonEncode(_controllerInvoice.invoiceSettings));
                      print(jsonEncode(prefs?.getString(
                        'savedInvoiceSettings',
                      )));
                      prefs?.setString('savedInvoiceSettings',
                          jsonEncode(_controllerInvoice.invoiceSettings));

                      _controllerInvoice.refreshIWD = true;
                      _controllerInvoice.update();
                      //if (!_controllerInvoice.showUnpaid)
                      //if (!_controllerInvoice.invoiceSettings.firstWhere((e) => e.CustomerId == selectedCustomerId).ShowUnpaid)
                      _carouselSliderController?.jumpToPage(0);
                      //    _carouselController.jumpTo(0);//! jumptopage yerine jumpTo kullanildi
                      setState(() {});
                    }
                  },
                ),
                body: Container(
                  width: Get.width,
                  height: Get.height,
                  child: Column(
                    children: [
                      Container(
                        width: Get.width,
                        height: useTabletLayout ? 80 : 180,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.transparent),
                                          ),
                                          child:
                                              _customerSelectWidget(context)),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    useTabletLayout
                                        ? Expanded(
                                            child: Container(
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.transparent),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: DropdownButton<
                                                    InvoiceWithDocumentType>(
                                                  underline: SizedBox(),
                                                  value:
                                                      selectedInvoiceWithDocumentType,
                                                  items: getDropdownItems(),
                                                  isExpanded: true,
                                                  icon: Icon(Icons
                                                      .keyboard_arrow_down_rounded),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedInvoiceWithDocumentType =
                                                          value;
                                                      sliderPage =
                                                          getPageFromInvoiceWithDocumentType(
                                                              value!);
                                                      reloadDirectoryDetail();
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),

                              // sliderPage == 1 ||
                              //         sliderPage == 0 ||
                              //         (sliderPage == 2 &&
                              //             !_controllerInvoice.invoiceSettings
                              //                 .firstWhere(
                              //                     (e) =>
                              //                         e.CustomerId ==
                              //                         selectedCustomerId,
                              //                     orElse: () {
                              //               return;
                              //             })?.ShowUnpaid) ||
                              //         (_controllerInvoice.invoiceSettings
                              //                 .firstWhere(
                              //                     (e) =>
                              //                         e.CustomerId ==
                              //                         selectedCustomerId,
                              //                     orElse: () {
                              //               return;
                              //             })?.ShowUnpaid &&
                              //             sliderPage == 4)
                              //     ? buildRadioButtons(context)
                              //     : Container(),
                              SizedBox(
                                height: 10,
                              ),
                              useTabletLayout
                                  ? Container()
                                  : _controllerInvoice.invoiceSettings
                                              .firstWhere(
                                                  (e) =>
                                                      e.CustomerId ==
                                                      selectedCustomerId,
                                                  orElse: () {
                                            return InvoiceSetting(0,
                                                false); //! return sonrasi eklendi
                                          }).ShowUnpaid ??
                                          true
                                      ? _carouselSliderone(context)
                                      : _carouselSliderTwo(context),
                            ]),
                      ),
                      Expanded(
                        child: WillPopScope(
                            onWillPop: () async {
                              return true;
                            },
                            child: Navigator(
                              key: _navigatorKey,
                              onGenerateRoute: (RouteSettings settings) {
                                return MaterialPageRoute(
                                  builder: (context) => DirectoryDetailIWD(
                                    invoiceType: widget.invoiceType,
                                    customerId: selectedCustomerId,
                                    folderName: "",
                                    hideHeader: true,
                                    fileManagerType:
                                        FileManagerType.InvoiceDocument,
                                    todoId: null,
                                    invoiceBlock: 2,
                                    baseContext: this.context,
                                    controllerInvoice: _controllerInvoice,
                                    // customerAdminId: 2715,
                                  ),
                                );
                              },
                            )),
                      ),
                    ],
                  ),
                ),
              ));
  }

  CarouselSlider _carouselSliderTwo(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useTabletLayout = shortestSide > 600;
    return CarouselSlider(
      carouselController: _carouselSliderController,
      items: [
        CarousalCard(
            AppLocalizations.of(context)!.about,
            InvoiceWithDocumentType.IncomePaid,
            0,
            "https://plattform.baulinx.com/material-ui-static/images/cards/bg1.png"),
        CarousalCard(
            AppLocalizations.of(context)!.outgoingPaid,
            InvoiceWithDocumentType.OutgoingPaid,
            2,
            "https://plattform.baulinx.com/material-ui-static/images/cards/bg2.png"),
        CarousalCard(
            AppLocalizations.of(context)!.incomeUnpaid,
            InvoiceWithDocumentType.IncomeUnpaid,
            1,
            "https://plattform.baulinx.com/material-ui-static/images/cards/bg3.png"),
        CarousalCard(
            AppLocalizations.of(context)!.outgoingUnpaid,
            InvoiceWithDocumentType.OutgoingUnpaid,
            2,
            "https://plattform.baulinx.com/material-ui-static/images/cards/bg4.png"),
      ],
      options: CarouselOptions(
        initialPage: sliderPage,
        onPageChanged: (i, reason) {
          print('Current Page  : ' + i.toString());
          sliderPage = i;
          selectedInvoiceWithDocumentType = getInvoiceWithDocumentByPage(i);
          print('Invoice DocumentType  : ' +
              selectedInvoiceWithDocumentType.toString());

          setState(() {
            reloadDirectoryDetail();
          });
        },
        height: 80,
        aspectRatio: 4 / 3,
        viewportFraction:
            useTabletLayout ? (Get.height > 1000 ? 0.33 : 0.22) : 0.83,
        enableInfiniteScroll: useTabletLayout ? true : false,
        autoPlay: false,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
    );
  }

  CarouselSlider _carouselSliderone(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useTabletLayout = shortestSide > 600;
    return CarouselSlider(
      carouselController: _carouselSliderController,
      items: [
        CarousalCard(
            AppLocalizations.of(context)!.incomePaid,
            InvoiceWithDocumentType.IncomePaid,
            0,
            "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"),
        CarousalCard(
            AppLocalizations.of(context)!.outgoingPaid,
            InvoiceWithDocumentType.OutgoingPaid,
            2,
            "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"),
        CarousalCard(
            AppLocalizations.of(context)!.incomeUnpaid,
            InvoiceWithDocumentType.IncomeUnpaid,
            1,
            "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"),
        CarousalCard(
            AppLocalizations.of(context)!.outgoingUnpaid,
            InvoiceWithDocumentType.OutgoingUnpaid,
            3,
            "https://plattform.baulinx.com/material-ui-static/images/cards/bg.png"),
        // CarousalCard(
        //     AppLocalizations.of(context)
        //         .invoiceWithOutFile,
        //     InvoiceWithDocumentType
        //         .WithOutFilePaid,
        //     4,
        //     "http://react.vir2ell-office.com/material-ui-static/images/cards/outgoing1.gif"),
        // CarousalCard(
        //     AppLocalizations.of(context)
        //         .statistics,
        //     InvoiceWithDocumentType
        //         .WithOutFilePaid,
        //     5,
        //     "http://react.vir2ell-office.com/material-ui-static/images/cards/outgoing1.gif"),
      ],
      options: CarouselOptions(
        initialPage: sliderPage,
        onPageChanged: (i, reason) {
          print('Current Page  : ' + i.toString());
          sliderPage = i;
          selectedInvoiceWithDocumentType = getInvoiceWithDocumentByPage(i);
          print('Invoice DocumentType  : ' +
              selectedInvoiceWithDocumentType.toString());

          setState(() {
            reloadDirectoryDetail();
          });
        },
        reverse: false,
        pageSnapping: true,
        height: 80,
        aspectRatio: 4 / 3,
        viewportFraction:
            useTabletLayout ? (Get.height > 1000 ? 0.33 : 0.22) : 0.83,
        enableInfiniteScroll: useTabletLayout ? true : false,
        autoPlay: false,
        enlargeCenterPage: useTabletLayout ? false : true,
        scrollDirection: Axis.horizontal,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
    );
  }

  Widget _customerSelectWidget(BuildContext context) {
    return SearchableDropdown.single(
        height: 40,
        displayClearIcon: false,
        menuBackgroundColor: Get.theme.scaffoldBackgroundColor,
        items: this.dmiCutsomers,
        value: this.selectedCustomerId,
        icon: Icon(Icons.expand_more),
        hint: AppLocalizations.of(context)!.selectOne,
        searchHint: AppLocalizations.of(context)!.selectOne,
        onChanged: (value) {
          setState(() {
            prefs?.setInt("selectedUser", value!);

            this.selectedCustomerId = value;
          });

          selectedInvoiceWithDocumentType =
              getInvoiceWithDocumentByPage(sliderPage);

          if (sliderPage != 0)
            _carouselSliderController?.jumpToPage(0);
          else
            reloadDirectoryDetail();
        },
        doneButton: AppLocalizations.of(context)!.done,
        closeButton: AppLocalizations.of(context)!.close,
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
        searchFn: dropdownSearchFn,
        isExpanded: true);
  }

  int getPageFromInvoiceWithDocumentType(InvoiceWithDocumentType type) {
    switch (type) {
      case InvoiceWithDocumentType.IncomePaid:
        return 0;
      case InvoiceWithDocumentType.OutgoingPaid:
        return 2;
      case InvoiceWithDocumentType.IncomeUnpaid:
        return 1;
      case InvoiceWithDocumentType.OutgoingUnpaid:
        return 3;
      default:
        return 0;
    }
  }

  void reloadDirectoryDetail() {
    setState(() {
      if (sliderPage == 2 &&
          !_controllerInvoice.invoiceSettings.firstWhere(
              (e) => e.CustomerId == selectedCustomerId, orElse: () {
            return InvoiceSetting(0, false); //! return sonrasi eklendi
          }).ShowUnpaid!) {
        print('asdadsasasdad');
        _navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
          builder: (context) => DirectoryDetailIWD(
            invoiceType: widget.invoiceType,
            customerId: selectedCustomerId,
            customerAdminId: customers.result?.length == 0
                ? 0
                : customers.result?.firstWhere(
                        (x) => x.id == selectedCustomerId, orElse: () {
                      return Customer(); //! return sonrasi eklendi
                    }).customerAdminId ??
                    0,
            folderName: "",
            hideHeader: true,
            invoiceBlock: getInvoiceBlockWithDocumentType(
                selectedInvoiceWithDocumentType!),
            fileManagerType: FileManagerType.InvoiceDocument,
            todoId: null,
            SelectedInvoiceTargetAccount: selectedTargetAccount,
            SearchDescription: _controllerDescription.text,
            TaxAccountId: _selectedTaxAccount,
            WithOutTaxValue: _controllerWithOutKdv
                    .text.isBlank! //!isNullOrBlank yerine isBlank kullanildi
                ? null
                : double.parse(_controllerWithOutKdv.text),
            WithTaxValue: _controllerWithKdv
                    .text.isBlank! //!isNullOrBlank yerine isBlank kullanildi
                ? null
                : double.parse(_controllerWithKdv.text),
            SelectedAccountType: _selectedAccountType,
            controllerInvoice: _controllerInvoice,
            //customerId: fType != null ? selectedCustomer.id : null
          ),
        ));
      } else if (_controllerInvoice.invoiceSettings.firstWhere(
              (e) => e.CustomerId == selectedCustomerId, orElse: () {
            return InvoiceSetting(0, false); //! return sonrasi eklendi
          }).ShowUnpaid! &&
          sliderPage == 4) {
        _navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
          builder: (context) => DirectoryDetailWithOutFileIWD(
            customerId: selectedCustomerId,
            customerAdminId: customers.result?.length == 0
                ? 0
                : customers.result?.firstWhere(
                        (x) => x.id == selectedCustomerId, orElse: () {
                      return Customer(); //! return sonrasi eklendi
                    }).customerAdminId ??
                    0,
            folderName: "",
            hideHeader: true,
            invoiceBlock: getInvoiceBlockWithDocumentType(
                selectedInvoiceWithDocumentType!),
            fileManagerType: FileManagerType.InvoiceDocument,
            todoId: null,
            SelectedInvoiceTargetAccount: selectedTargetAccount,
            SearchDescription: _controllerDescription.text,
            TaxAccountId: _selectedTaxAccount,
            WithOutTaxValue: _controllerWithOutKdv
                    .text.isBlank! //!isNullOrBlank yerine isBlank kullanildi
                ? null
                : double.parse(_controllerWithOutKdv.text),
            WithTaxValue: _controllerWithKdv
                    .text.isBlank! //!isNullOrBlank yerine isBlank kullanildi
                ? null
                : double.parse(_controllerWithKdv.text),
            SelectedAccountType: _selectedAccountType,
            FileType: _fileTypeId,
            controllerInvoice: _controllerInvoice,
            //customerId: fType != null ? selectedCustomer.id : null
          ),
        ));
      } else if (_controllerInvoice.invoiceSettings.firstWhere(
              (e) => e.CustomerId == selectedCustomerId, orElse: () {
            return InvoiceSetting(0, false); //! return sonrasi eklendi
          }).ShowUnpaid! &&
          sliderPage == 3) {
        _navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
          builder: (context) => DirectoryDetailIWD(
            invoiceType: widget.invoiceType,
            customerId: selectedCustomerId,
            customerAdminId: customers.result?.length == 0
                ? 0
                : customers.result?.firstWhere(
                        (x) => x.id == selectedCustomerId, orElse: () {
                      return Customer(); //! return sonrasi eklendi
                    }).customerAdminId ??
                    0,
            folderName: "",
            hideHeader: true,
            invoiceBlock: getInvoiceBlockWithDocumentType(
                selectedInvoiceWithDocumentType!),
            fileManagerType: FileManagerType.InvoiceDocument,
            todoId: null,
            SelectedInvoiceTargetAccount: selectedTargetAccount,
            SearchDescription: _controllerDescription.text,
            TaxAccountId: _selectedTaxAccount,
            WithOutTaxValue: _controllerWithOutKdv
                    .text.isBlank! //!isNullOrBlank yerine isBlank kullanildi
                ? null
                : double.parse(_controllerWithOutKdv.text.replaceAll(",", ".")),
            WithTaxValue: _controllerWithKdv
                    .text.isBlank! //!isNullOrBlank yerine isBlank kullanildi
                ? null
                : double.parse(_controllerWithKdv.text.replaceAll(",", ".")),
            SelectedAccountType: _selectedAccountType,
            //customerId: fType != null ? selectedCustomer.id : null
          ),
        ));
        // _navigatorKey.currentState.pushReplacement(MaterialPageRoute(
        //   builder: (context) => InvoiceStatistic(
        //     customerId: customers.result
        //             .firstWhere((x) => x.id == selectedCustomerId, orElse: () {
        //           return;
        //         })?.customerAdminId ??
        //         0,
        //   ),
        // ));
      } else if (_controllerInvoice.invoiceSettings.firstWhere(
              (e) => e.CustomerId == selectedCustomerId, orElse: () {
            return InvoiceSetting(0, false); //! return sonrasi eklendi
          }).ShowUnpaid! &&
          sliderPage == 5) {
        _navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
          builder: (context) => InvoiceStatistic(
            customerId: customers.result
                    ?.firstWhere((x) => x.id == selectedCustomerId, orElse: () {
                  return Customer(); //! return sonrasi eklendi
                }).customerAdminId ??
                0,
          ),
        ));
      } else {
        _navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
          builder: (context) => DirectoryDetailIWD(
            invoiceType: widget.invoiceType,
            customerId: selectedCustomerId,
            customerAdminId: customers.result?.length == 0
                ? 0
                : customers.result?.firstWhere(
                        (x) => x.id == selectedCustomerId, orElse: () {
                      return Customer(); //! return sonrasi eklendi
                    }).customerAdminId ??
                    0,
            folderName: "",
            hideHeader: true,
            invoiceBlock: getInvoiceBlockWithDocumentType(
                selectedInvoiceWithDocumentType!),
            fileManagerType: FileManagerType.InvoiceDocument,
            todoId: null,
            SelectedInvoiceTargetAccount: selectedTargetAccount,
            SearchDescription: _controllerDescription.text,
            TaxAccountId: _selectedTaxAccount,
            WithOutTaxValue: _controllerWithOutKdv
                    .text.isBlank! //!isNullOrBlank yerine isBlank kullanildi
                ? null
                : double.parse(_controllerWithOutKdv.text.replaceAll(",", ".")),
            WithTaxValue: _controllerWithKdv
                    .text.isBlank! //!isNullOrBlank yerine isBlank kullanildi
                ? null
                : double.parse(_controllerWithKdv.text.replaceAll(",", ".")),
            SelectedAccountType: _selectedAccountType,
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
                },
              ),
            ),
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
        return 0; //! null yerine 0  eklendi
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
        return 0; //! null yerine 0 sonrasi eklendi
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
          .IncomeUnpaid; //! null yerine bu satir eklendi
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
        return 'getTitleByinvoiceWithDocumentType fonksiyonun da Hata'; //! null yerine bu satir eklendi
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
