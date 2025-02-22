import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerCustomersBills.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerInvoice.dart';
import 'package:undede/Controller/ControllerSocial.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Pages/PDFCreater/ProductClass.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:undede/model/CustomersBills/CustomersBillsResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../../Custom/CustomLoadingCircle.dart';

class CustomersBillsAddOrUpdate extends StatefulWidget {
  final CustomerBill? customerBill;

  const CustomersBillsAddOrUpdate({Key? key, this.customerBill})
      : super(key: key);
  @override
  _CustomersBillsAddOrUpdateState createState() =>
      _CustomersBillsAddOrUpdateState();
}

class _CustomersBillsAddOrUpdateState extends State<CustomersBillsAddOrUpdate> {
  ControllerCustomersBills _customersBills =
      Get.put(ControllerCustomersBills());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  TextEditingController _productBillName = TextEditingController();
  TextEditingController _productBillAddress = TextEditingController();
  TextEditingController _productBillUserName = TextEditingController();
  FocusNode myFocusNode = new FocusNode();
  bool isLoading = true;
  final List<DropdownMenuItem> dmiPersons = [];
  int? selectedPerson;
  @override
  void initState() {
    _productBillName =
        TextEditingController(text: widget.customerBill!.billName);
    _productBillAddress =
        TextEditingController(text: widget.customerBill!.billAddress);
    _productBillUserName =
        TextEditingController(text: widget.customerBill!.billUserName);
    selectedPerson = widget.customerBill!.customerId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      dmiPersons.add(DropdownMenuItem(
        child: Text(
          AppLocalizations.of(context)!.newCustomer,
        ),
        value: 0,
        key: Key(AppLocalizations.of(context)!.newCustomer),
      ));
      selectedPerson = 0;
      setState(() {});
    });
    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.add),
      floatingActionButton: isLoading
          ? Container()
          : Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: FloatingActionButton(
                heroTag: "addCustomerBill2",
                onPressed: () async {
                  await _customersBills.InsertOrUpdateCustomersBill(
                      _controllerDB.headers(),
                      UserId: _controllerDB.user.value!.result!.id!,
                      CustomerId: selectedPerson,
                      Id: widget.customerBill!.id!,
                      BillUserName: _productBillUserName.text,
                      BillName: _productBillName.text,
                      BillAddress: _productBillAddress.text);
                  _customersBills.GetAllCustomersBills(_controllerDB.headers(),
                      userId: _controllerDB.user.value!.result!.id!,
                      customerId: selectedPerson);
                  Navigator.pop(context);
                },
                child: Icon(Icons.done),
              ),
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
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/create.png"),
                                ),
                              ),
                            ),
                            Divider(),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                                height: 45,
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(45),
                                          color: Colors.white,
                                          boxShadow: standartCardShadow(),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 11),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: Get.width,
                                              height: 23,
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                  menuMaxHeight: 350,
                                                  value: selectedPerson,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                      fontFamily: 'TTNorms',
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  icon: Icon(
                                                    Icons.expand_more,
                                                    color: Colors.black,
                                                  ),
                                                  items: dmiPersons,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedPerson = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  boxShadow: standartCardShadow(),
                                  borderRadius: BorderRadius.circular(15)),
                              child: CustomTextField(
                                controller: _productBillName,
                                validator: (value) {
                                  value = value.trim();
                                  if (value == null || value.isEmpty) {
                                    return "";
                                  }

                                  return null;
                                },
                                label: AppLocalizations.of(context)!.invoice +
                                    " " +
                                    AppLocalizations.of(context)!.userName,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  boxShadow: standartCardShadow(),
                                  borderRadius: BorderRadius.circular(15)),
                              child: CustomTextField(
                                controller: _productBillUserName,
                                validator: (value) {
                                  value = value.trim();
                                  if (value == null || value.isEmpty) {
                                    return "";
                                  }

                                  return null;
                                },
                                label: AppLocalizations.of(context)!.userName,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  boxShadow: standartCardShadow(),
                                  borderRadius: BorderRadius.circular(15)),
                              child: CustomTextField(
                                controller: _productBillAddress,
                                inputType: TextInputType.text,
                                validator: (value) {
                                  value = value.trim();
                                  if (value == null || value.isEmpty) {
                                    return "";
                                  }

                                  return null;
                                },
                                label: AppLocalizations.of(context)!.adress,
                              ),
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
}
