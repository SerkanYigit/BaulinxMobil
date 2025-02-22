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
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerInvoice.dart';
import 'package:undede/Controller/ControllerSocial.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/PDFCreater/AddedProductPage.dart';
import 'package:undede/Pages/PDFCreater/ProductClass.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Custom/CustomLoadingCircle.dart';

bool selected1 = false;
bool selected2 = true;
bool status1 = false;

class AddProduct extends StatefulWidget {
  final Product? product;

  const AddProduct({Key? key, this.product}) : super(key: key);
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  ControllerInvoice _invoice = Get.put(ControllerInvoice());

  TextEditingController _productId = TextEditingController();
  TextEditingController _productName = TextEditingController();
  TextEditingController _productQuantity = TextEditingController();
  TextEditingController _productPrice = TextEditingController();
  TextEditingController _productKdv = TextEditingController();
  FocusNode myFocusNode = new FocusNode();
  bool isLoading = true;
  List<DropdownMenuItem> dmiKdv = [];
  int? selectedKdv;
  List<DropdownMenuItem> dmiQuantity = [];
  List<String> quantitiyName = [];
  int? selectedQuantity;
  @override
  void initState() {
    dmiKdv = [
      DropdownMenuItem(
        child: Text("0 %"),
        value: 0,
        key: Key("0 %"),
      ),
      DropdownMenuItem(
        child: Text("5 %"),
        value: 5,
        key: Key("5 %"),
      ),
      DropdownMenuItem(
        child: Text("7 %"),
        value: 7,
        key: Key("7 %"),
      ),
      DropdownMenuItem(
        child: Text("19 %"),
        value: 19,
        key: Key("19 %"),
      ),
    ];
    selectedKdv = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      quantitiyName = [
        AppLocalizations.of(context)!.pieces,
        AppLocalizations.of(context)!.day,
        "KM",
        AppLocalizations.of(context)!.hours,
        AppLocalizations.of(context)!.flatRate
      ];
      dmiQuantity = [
        DropdownMenuItem(
          child: Text(AppLocalizations.of(context)!.pieces),
          value: 0,
          key: Key(AppLocalizations.of(context)!.pieces),
        ),
        DropdownMenuItem(
          child: Text(AppLocalizations.of(context)!.day),
          value: 1,
          key: Key(AppLocalizations.of(context)!.day),
        ),
        DropdownMenuItem(
          child: Text("KM"),
          value: 2,
          key: Key("KM"),
        ),
        DropdownMenuItem(
          child: Text(AppLocalizations.of(context)!.hours),
          value: 3,
          key: Key(AppLocalizations.of(context)!.hours),
        ),
        DropdownMenuItem(
          child: Text(AppLocalizations.of(context)!.flatRate),
          value: 4,
          key: Key(AppLocalizations.of(context)!.flatRate),
        ),
      ];
      selectedQuantity = 0;
      setState(() {});

      if (!widget.product.isNullOrBlank!) {
        selectedKdv = widget.product!.kdv;
        selectedQuantity = widget.product!.quantityType;
        _productId = TextEditingController(text: widget.product!.productName);
        _productName = TextEditingController(text: widget.product!.productName);
        _productQuantity = TextEditingController(
            text: widget.product!.quantity.toStringAsFixed(2));
        _productPrice = TextEditingController(
            text: widget.product!.price.toStringAsFixed(2));
        setState(() {});
      }
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
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.addPosition),
      floatingActionButton: isLoading
          ? Container()
          : Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: FloatingActionButton(
                backgroundColor: Get.theme.primaryColor,
                key: Key("PositionCreater"),
                heroTag: "PositionCreater",
                onPressed: () async {
                  if (_productName.text.isEmpty ||
                      _productPrice.text.isEmpty ||
                      _productQuantity.text.isEmpty) {
                    showErrorToast(AppLocalizations.of(context)!.cannotbeblank);
                    return;
                  }
                  if (!widget.product!.isNullOrBlank!) {
                    Navigator.pop(
                        context,
                        Product(
                          _productId.text,
                          _productName.text,
                          double.parse(_productPrice.text),
                          int.tryParse(_productQuantity.text) ??
                              double.parse(_productQuantity.text),
                          selectedQuantity!,
                          selectedKdv!,
                          (double.parse(_productQuantity.text) *
                              double.parse(_productPrice.text)),
                          (double.parse(_productQuantity.text) *
                                  double.parse(_productPrice.text)) *
                              (1 + (selectedKdv! / 100)),
                            quantitiyName[selectedQuantity!],
                        ));
                    return;
                  }
                  _invoice.products.add(
                    Product(
                      _productId.text,
                      _productName.text,
                      double.parse(_productPrice.text),
                      int.tryParse(_productQuantity.text) ??
                          double.parse(_productQuantity.text),
                      selectedQuantity!,
                      selectedKdv!,
                      (double.parse(_productQuantity.text) *
                          double.parse(_productPrice.text)),
                      (double.parse(_productQuantity.text) *
                              double.parse(_productPrice.text)) *
                          (1 + (selectedKdv! / 100)),
                      quantitiyName[selectedQuantity!],
                    ),
                  );
                  _invoice.update();
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              AddedProductPage()));
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
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: standartCardShadow(),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.grey[400]!,
                                ),
                              ),
                              child: CustomTextField(
                                controller: _productName,
                                validator: (value) {
                                  value = value.trim();
                                  if (value == null || value.isEmpty) {
                                    return "";
                                  }

                                  return null;
                                },
                                label: AppLocalizations.of(context)!.productName,
                              ),
                            ),
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
                                      controller: _productQuantity,
                                      inputType: TextInputType.number,
                                      validator: (value) {
                                        value = value.trim();
                                        if (value == null || value.isEmpty) {
                                          return "";
                                        }
                                        return null;
                                      },
                                      label:
                                          AppLocalizations.of(context)!.quantity,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    width: Get.width,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: standartCardShadow(),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.grey[400]!,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        menuMaxHeight: 350,
                                        value: selectedQuantity,
                                        hint: Text(AppLocalizations.of(context)!
                                            .quantityType),
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontFamily: 'TTNorms',
                                            fontWeight: FontWeight.w500),
                                        icon: Icon(
                                          Icons.expand_more,
                                          color: Colors.black,
                                        ),
                                        items: dmiQuantity,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedQuantity = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                              child: CustomTextField(
                                controller: _productPrice,
                                inputType: TextInputType.number,
                                validator: (value) {
                                  value = value.trim();
                                  if (value == null || value.isEmpty) {
                                    return "";
                                  }

                                  return null;
                                },
                                label:
                                    AppLocalizations.of(context)!.productPrice,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              width: Get.width,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: standartCardShadow(),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.grey[400]!,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  menuMaxHeight: 350,
                                  value: selectedKdv,
                                  hint: Text(AppLocalizations.of(context)!.vat),
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontFamily: 'TTNorms',
                                      fontWeight: FontWeight.w500),
                                  icon: Icon(
                                    Icons.expand_more,
                                    color: Colors.black,
                                  ),
                                  items: dmiKdv,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedKdv = value;
                                    });
                                  },
                                ),
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
