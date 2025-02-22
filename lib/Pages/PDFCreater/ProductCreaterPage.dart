import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerCustomersBills.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerInvoice.dart';
import 'package:undede/Controller/ControllerSocial.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/PDFCreater/AddedProductPage.dart';
import 'package:undede/Pages/PDFCreater/ProductClass.dart';
import 'package:undede/Pages/Profile/ProfileCustomer/ProfileCustomerUpdate.dart';
import 'package:undede/Pages/Profile/ProfileCustomersBills/ProfileCustomersBills.dart';
import 'package:undede/Pages/Profile/ProfileInvoiceHistory/InvoiceHistory.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:undede/model/CustomersBills/CustomersBillsResult.dart';
import 'package:undede/model/User/UpdatedCustomerResult.dart';
import 'package:undede/model/User/UpdatedCustomerResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Custom/CustomLoadingCircle.dart';
import '../../model/Common/CommonGroup.dart';
import '../../widgets/CustomSearchDropdownMenu.dart';
import 'PDFCreater.dart';
import 'ProductPage.dart';

class ProductCreaterPage extends StatefulWidget {
  int? invoiceType;
  ProductCreaterPage({this.invoiceType});
  @override
  _ProductCreaterPageState createState() => _ProductCreaterPageState();
}

enum SelectData { first, second }

class _ProductCreaterPageState extends State<ProductCreaterPage> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCustomersBills _customersBills =
      Get.put(ControllerCustomersBills());
  ControllerUser _controllerUser = Get.put(ControllerUser());
  TextEditingController _invoiceNumber = TextEditingController();
  TextEditingController _invoiceAdress = TextEditingController();
  TextEditingController _invoiceMyAdress = TextEditingController();
  TextEditingController _invoiceMyCustomerName = TextEditingController();
  ControllerInvoice _controllerInvoice = Get.put(ControllerInvoice());
  DateTime startDate = DateTime.now();
  DateTime startDate1 = DateTime.now();
  DateTime endDate1 = DateTime.now();

  //common group variables ::
  List<CommonGroup> _commonGroup = <CommonGroup>[];
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  int? selectedCommonGroupId ;
  int? selectedCommonGroupIdForMove ;

  bool isLoading = true;
  final List<DropdownMenuItem> dmiPersons = [];
  int? selectedPerson;
  final List<DropdownMenuItem> dmiHandInvoice = [];
  int? selectedHandInvoice;
  final List<DropdownMenuItem> dmiOffers = [];
  int? selectedOffer;
  List<DropdownMenuItem> productType = [];
  int? selectedProductType;

  bool isSelected = false;
  SelectData _data = SelectData.first;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences? prefs;
  List<String> dmiQuantity = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controllerCommon.GetListCommonGroup(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id,
      ).then((value) async {
        print("res GetGroupByIdddd = " + jsonEncode(value.listOfCommonGroup));
        // common gruplar çekildikten sonra önyüze yansıtır
        _commonGroup = value.listOfCommonGroup!;
        selectedCommonGroupId = _commonGroup.first.id;
        selectedCommonGroupIdForMove = _commonGroup.first.id;
      }).catchError((e) {
        print("res GetGroupById error " + e.toString());
      });

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
      selectedProductType = 0;
      await _customersBills.GetAllCustomersBills(_controllerDB.headers(),
              userId: _controllerDB.user.value!.result!.id, customerId: 0)
          .then((value) {
        value.result!.forEach((element) {
          dmiPersons.add(DropdownMenuItem(
            child: Text(element.billUserName!),
            value: element.id,
            key: Key("false" + element.billUserName!),
          ));
        });
        if (prefs!.getInt("CreateInvoice") == null) {
          if (value.result!.isNotEmpty) {
            _invoiceAdress =
                TextEditingController(text: value.result!.first.billAddress);
            selectedPerson = value.result!.first.id;
          } else {
            _invoiceAdress = TextEditingController(
                text: _controllerDB.user.value!.result!.userCustomers!
                    .userCustomerList!.first.address);
            selectedPerson = _controllerDB
                .user.value!.result!.userCustomers!.userCustomerList!.first.id;
          }
          prefs!.setInt("CreateInvoice", selectedPerson!);
        } else {
          setState(() {});
          selectedPerson = prefs!.getInt("CreateInvoice");
          _invoiceAdress = TextEditingController(
              text: _controllerDB
                  .user.value!.result!.userCustomers!.userCustomerList!
                  .firstWhere((element) => element.id == selectedPerson,
                   //   orElse: () {  return;  }
          ).address ?? '');
        
          _invoiceAdress = TextEditingController(
              text: value.result!.firstWhere(
                  (element) => element.id == selectedPerson, 
              //!    orElse: () { return;  }
          ).billAddress ?? '');
                }

        setState(() {});
      });



      
   /*    await _controllerDB.user.value!.result!.userCustomers!.userCustomerList!
          .forEach((element) 
          
          
          {
        dmiPersons.add(DropdownMenuItem(
          child: Text(
              element.customerAdminName! + " " + element.customerAdminSurname!),
          value: element.id,
          key: Key("true" +
              element.customerAdminName! +
              " " +
              element.customerAdminSurname!),
        ));
      });
 */




//! yukaridaki foreach hatasi asagidaki sekilde duzeltilmistir
var xxx = await _controllerDB.user.value!.result!.userCustomers!.userCustomerList!;
for(var element in xxx) {
 dmiPersons.add(DropdownMenuItem(
          child: Text(
              element.customerAdminName! + " " + element.customerAdminSurname!),
          value: element.id,
          key: Key("true" +
              element.customerAdminName! +
              " " +
              element.customerAdminSurname!),
        ));
}


      






      _controllerUser.GetCustomer(_controllerDB.headers(),
              Id: _controllerDB.user.value!.result!.customerId!)
          .then((value) {
        setState(() {
          _invoiceMyAdress =
              TextEditingController(text: value.companyResult!.address!);
          _invoiceMyCustomerName =
              TextEditingController(text: value.companyResult!.title!);
        });
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

  Future<void> GetInvoiceHandMadeInvoice() async {
    dmiHandInvoice.clear();
    selectedHandInvoice = 0;
    dmiHandInvoice.add(DropdownMenuItem(
      child: Text(AppLocalizations.of(context)!.newInvoice),
      value: 0,
      key: Key(AppLocalizations.of(context)!.newInvoice),
    ));
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
            InvoiceType: selectedProductType)
        .then((value) {
      value.historyResult!.forEach((element) {
        dmiHandInvoice.add(DropdownMenuItem(
          child: Text(oCcy.format(element.taxAddAmount) +
              " - " +
              DateFormat('yMd', AppLocalizations.of(context)!.date)
                  .format(DateTime.parse(element.date!)) +
              " - " +
              element.invoiceNumber!),
          value: element.id,
          key: Key(element.taxAddAmount.toString() +
              " " +
              DateFormat('EEE, MMM dd yyyy', AppLocalizations.of(context)!.date)
                  .format(DateTime.parse(element.date!)) +
              " " +
              element.invoiceNumber!),
        ));
        setState(() {});
      });

      setState(() {});
    });
  }

  Future<void> GetPositions() async {
    _controllerInvoice.GetInvoicePositions(_controllerDB.headers(),
            invoiceId: selectedHandInvoice)
        .then((value) {
      _controllerInvoice.products.clear();
      if (!value.result!.isNullOrBlank!) {
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
            (element.quantity! * element.unitPrice!) * (1 + (element.vat! / 100)),
            dmiQuantity[element.quantityType!],
          ));
        });
      }
      setState(() {});
    });
    setState(() {});
  }

  final formKey = GlobalKey<FormState>();
  var oCcy = new NumberFormat("#,##0.00", "de-DE");

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        title: Text(AppLocalizations.of(context)!.create +
            ' ' +
            (widget.invoiceType == 2
                ? AppLocalizations.of(context)!.offer
                : widget.invoiceType == 3
                    ? AppLocalizations.of(context)!.inquiry
                    : AppLocalizations.of(context)!.invoice)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          isLoading
              ? Container()
              : GetBuilder<ControllerInvoice>(builder: (controllerInvoice) {
                  return InkWell(
                    onTap: () async {
                      if (_invoiceNumber.text.isNotEmpty) {
                        formKey.currentState?.save();
                        var oCcy = new NumberFormat("#,##0.00", "de-DE");
                        CreatePdf _createPdf = CreatePdf(
                            oCcy: oCcy,
                            myAddress: _invoiceMyAdress.text,
                            myCustomer: _controllerUser
                                .updatedCustomerResult.companyResult,
                            context: context,
                            moneySign: AppLocalizations.of(context)!.symbol,
                            customerBill: dmiPersons
                                    .firstWhere((element) =>
                                        element.value == selectedPerson)
                                    .key
                                    .toString()
                                    .contains("false")
                                ? _customersBills.customerBills.firstWhere(
                                    (element) => element.id == selectedPerson)
                                : CustomerBill(hasError: false,
                                    billAddress: _invoiceAdress.text,
                                    billUserName: _controllerDB
                                            .user
                                            .value!
                                                .result!
                                            .userCustomers!
                                            .userCustomerList!
                                            .firstWhere(
                                                (element) =>
                                                    element.id ==
                                                    selectedPerson,
                                                  //!   orElse: () { return; }
                                        ).customerAdminName! +
                                        " " +
                                        _controllerDB.user.value!.result!
                                            .userCustomers!.userCustomerList!
                                            .firstWhere(
                                                (element) =>
                                                    element.id ==
                                                    selectedPerson, 
                                                  //!  orElse: () {return;  }
                                        ).customerAdminSurname!,
                                  ),
                            InvoiceNumber: _invoiceNumber.text,
                            Products: _controllerInvoice.products,
                            startDate: startDate1,
                            endDate:
                                _data == SelectData.second ? null : endDate1,
                            invoiceDateTime: startDate,
                            productType: selectedProductType);

                        _controllerInvoice.MyCustomer = dmiPersons
                            .firstWhere(
                                (element) => element.value == selectedPerson)
                            .key
                            .toString()
                            .contains("true");
                        _controllerInvoice.CreatedForUserId = selectedPerson;
                        _controllerInvoice.InvoiceNumber = _invoiceNumber.text;
                        _controllerInvoice.productType = selectedProductType;
                        _controllerInvoice.CommonGroupId =
                            selectedCommonGroupId;
                        _controllerInvoice.update();
                        var value = await _createPdf.generateInvoice();
                        print('valuee' + value);
                        Navigator.pop(context, value);
                      } else {
                        showErrorToast(
                            AppLocalizations.of(context)!.invoiceNumber +
                                " - " +
                                AppLocalizations.of(context)!.invoicePosition +
                                " , " +
                                AppLocalizations.of(context)!.cannotbeblank);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10, right: 10, bottom: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Get.theme.primaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          SizedBox(width: 5),
                          Icon(
                            Icons.print_outlined,
                            color: Colors.black,
                            size: 26,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            AppLocalizations.of(context)!.print,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                    ),
                  );
                })
        ],
      ),

      //resizeToAvoidBottomInset: false,
      floatingActionButton: isLoading
          ? Container()
          : GetBuilder<ControllerInvoice>(builder: (controllerInvoice) {
              double sum = 0;
              _controllerInvoice.products.forEach((element) {
                sum += (element.quantity * element.price) *
                    (1 + (element.kdv / 100));
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

      body: isLoading
          ? CustomLoadingCircle()
          : Container(
              child: Column(
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
                              CustomSearchDropDownMenu(
                                fillColor: Colors.white,
                                labelHeader: _commonGroup
                                    .firstWhere((commonGroup) =>
                                        commonGroup.id == selectedCommonGroupId)
                                    .groupName,
                                list: _commonGroup
                                    .map((commonGroup) => commonGroup.groupName!)
                                    .toList(),
                                onChanged: (newValue) {
                                  CommonGroup commonGroup =
                                      _commonGroup.firstWhere((commonGroup) =>
                                          commonGroup.groupName == newValue);
                                  setState(() {
                                    selectedCommonGroupId = commonGroup.id;
                                    // Add your custom logic here
                                  });
                                },
                                error: 'Error',
                                labelIcon: Icons.info,
                                labelIconExist: true,
                              ),
                              _editWidget(
                                context,
                                CustomTextField(
                                  controller: _invoiceMyCustomerName,
                                  enabled: false,
                                  validator: (value) {
                                    value = value.trim();
                                    if (value == null || value.isEmpty) {
                                      return "";
                                    }
                                    return null;
                                  },
                                  label: "",
                                ),
                                () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileCustomerUpdate()));
                                },
                                isEdit: true,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              _editWidget(
                                context,
                                SearchableDropdown.single(
                                  height: 40,
                                  color: Colors.white,
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
                                () {},
                                isEdit: false,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              _editWidget(
                                context,
                                SearchableDropdown.single(
                                  color: Colors.white,
                                  height: 42,
                                  displayClearIcon: false,
                                  menuBackgroundColor:
                                      Get.theme.scaffoldBackgroundColor,
                                  value: selectedPerson,
                                  items: dmiPersons,
                                  icon: Icon(Icons.expand_more),
                                  hint: AppLocalizations.of(context)!.selectType,
                                  searchHint:
                                      AppLocalizations.of(context)!.selectType,
                                  onChanged: (value) async {
                                    setState(() {
                                      print(value);
                                      selectedPerson = value;
                                      GetInvoiceHandMadeInvoice();
                                      prefs?.setInt(
                                          "CreateInvoice", selectedPerson!);
                                      if (dmiPersons
                                          .firstWhere((element) =>
                                              element.value == selectedPerson)
                                          .key
                                          .toString()
                                          .contains("false")) {
                                        _invoiceAdress = TextEditingController(
                                            text: _customersBills.customerBills
                                                .firstWhere((element) =>
                                                    element.id ==
                                                    selectedPerson)
                                                .billAddress);
                                      } else {
                                        _invoiceAdress = TextEditingController(
                                            text: _controllerDB
                                                    .user
                                                    .value!
                                                    .result!
                                                    .userCustomers!
                                                    .userCustomerList!
                                                    .firstWhere((element) =>
                                                        element.id ==
                                                        selectedPerson)
                                                    .address ??
                                                "");
                                      }
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
                                () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileCustomersBills()));
                                },
                                isEdit: true,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              dmiHandInvoice.isNullOrBlank!
                                  ? Container()
                                  : _editWidget(
                                      context,
                                      SearchableDropdown.single(
                                        color: Colors.white,
                                        height: 42,
                                        displayClearIcon: false,
                                        menuBackgroundColor:
                                            Get.theme.scaffoldBackgroundColor,
                                        value: selectedHandInvoice,
                                        items: dmiHandInvoice,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedHandInvoice = value;
                                            GetPositions();
                                          });
                                        },
                                        icon: Icon(Icons.expand_more),
                                        hint: AppLocalizations.of(context)!
                                            .selectType,
                                        searchHint: AppLocalizations.of(context)!
                                            .selectType,
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
                                      ), () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  InvoiceHistory(
                                                    CreatePage: 1,
                                                  )));
                                    }, isEdit: true),
                              dmiHandInvoice.isNullOrBlank!
                                  ? Container()
                                  : SizedBox(
                                      height: 15,
                                    ),
                              _editWidget(
                                  context,
                                  CustomTextField(
                                    controller: _invoiceAdress,
                                    enabled: false,
                                    validator: (value) {
                                      value = value.trim();
                                      if (value == null || value.isEmpty) {
                                        return "";
                                      }
                                      return null;
                                    },
                                    label: AppLocalizations.of(context)!.adress,
                                  ),
                                  () {}),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
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
                                        controller: _invoiceNumber,
                                        validator: (value) {
                                          value = value.trim();
                                          if (value == null || value.isEmpty) {
                                            return "";
                                          }

                                          return null;
                                        },
                                        label: AppLocalizations.of(context)!
                                            .invoiceNumber,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: standartCardShadow(),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.grey[400]!,
                                        ),
                                      ),
                                      child: GestureDetector(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                DateFormat(
                                                        'dd.MM.yyyy',
                                                        AppLocalizations.of(
                                                                context)
                                                            !.date)
                                                    .format(startDate == null
                                                        ? DateTime.now()
                                                        : startDate),
                                                textAlign: TextAlign.left),
                                          ),
                                          onTap: () async {
                                            DateTime? picked =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: startDate == null
                                                  ? DateTime.now()
                                                  : startDate,
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2100),
                                            );
                                            if (picked != startDate) {
                                              setState(() {
                                                startDate = picked!;
                                              });
                                            }
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 50,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        minVerticalPadding: 0,
                                        visualDensity: VisualDensity.compact,
                                        title: Text(
                                          AppLocalizations.of(context)!.period,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        leading: Radio<SelectData>(
                                          activeColor: Get.theme.primaryColor,
                                          value: SelectData.first,
                                          groupValue: _data,
                                          onChanged: (SelectData? value) {
                                            setState(() {
                                              _data = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        minVerticalPadding: 0,
                                        visualDensity: VisualDensity.compact,
                                        title: Text(
                                          AppLocalizations.of(context)!.dateName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        leading: Radio<SelectData>(
                                          activeColor: Get.theme.primaryColor,
                                          value: SelectData.second,
                                          groupValue: _data,
                                          onChanged: (SelectData? value) {
                                            setState(() {
                                              _data = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: standartCardShadow(),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.grey[400]!,
                                        ),
                                      ),
                                      child: GestureDetector(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                DateFormat(
                                                        'dd.MM.yyyy',
                                                        AppLocalizations.of(
                                                                context)
                                                            !.date)
                                                    .format(startDate1 == null
                                                        ? DateTime.now()
                                                        : startDate1),
                                                textAlign: TextAlign.left),
                                          ),
                                          onTap: () async {
                                            DateTime? picked =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: startDate1 == null
                                                  ? DateTime.now()
                                                  : startDate1,
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2100),
                                            );
                                            if (picked != startDate1) {
                                              setState(() {
                                                startDate1 = picked!;
                                              });
                                            }
                                          }),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _data == SelectData.second
                                      ? Container()
                                      : Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            height: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: standartCardShadow(),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                color: Colors.grey[400]!,
                                              ),
                                            ),
                                            child: GestureDetector(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      DateFormat(
                                                              'dd.MM.yyyy',
                                                              AppLocalizations.of(
                                                                      context)
                                                                  !.date)
                                                          .format(endDate1 ==
                                                                  null
                                                              ? DateTime.now()
                                                              : endDate1),
                                                      textAlign:
                                                          TextAlign.left),
                                                ),
                                                onTap: () async {
                                                  DateTime? picked =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        endDate1 == null
                                                            ? DateTime.now()
                                                            : endDate1,
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  if (picked != endDate1) {
                                                    setState(() {
                                                      endDate1 = picked!;
                                                    });
                                                  }
                                                }),
                                          ),
                                        ),
                                ],
                              ),
                              Divider(),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .invoicePosition,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(() => AddProduct());
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            color: Get.theme.primaryColor,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              topLeft: Radius.circular(20),
                                              bottomLeft: Radius.circular(20),
                                            )),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Text(
                                                AppLocalizations.of(context)! 
                                                    .addPosition,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              // GetBuilder<ControllerInvoice>(
                              //     builder: (controllerInvoice) {
                              //   return ListView.builder(
                              //       itemCount: _controllerInvoice.products.length,
                              //       physics: NeverScrollableScrollPhysics(),
                              //       shrinkWrap: true,
                              //       itemBuilder: (context, i) {
                              //         return createProduct(
                              //           i,
                              //         );
                              //       });
                              // }),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              AddedProductPage()));
                                },
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Icon(
                                      //   Icons.list,
                                      //   color: Colors.black,
                                      // ),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .getPositions,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Row _editWidget(BuildContext context, Widget widget, Function onPressed,
      {bool isEdit = false}) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: standartCardShadow(),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.grey[400]!,
              ),
            ),
            child: widget,
          ),
        ),
        isEdit
            ? IconButton(
                onPressed: onPressed(),
                icon: Image.asset('assets/images/icon/pencil.png', width: 20),
              )
            : SizedBox()
      ],
    );
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
