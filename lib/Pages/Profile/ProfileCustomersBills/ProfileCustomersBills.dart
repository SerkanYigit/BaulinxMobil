import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerCustomersBills.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerUser.dart';

import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/Profile/ProfileCustomersBills/CustomersBillsAddOrEdit.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';

class ProfileCustomersBills extends StatefulWidget {
  @override
  _ProfileCustomersBillsState createState() => _ProfileCustomersBillsState();
}

class _ProfileCustomersBillsState extends State<ProfileCustomersBills>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCustomersBills _customersBills =
      Get.put(ControllerCustomersBills());
  bool loading = true;
  List<bool> listExpand = <bool>[];
  final List<DropdownMenuItem> dmiPersons = [];
  int? selectedPerson;
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _productBillName = TextEditingController();
  TextEditingController _productBillAddress = TextEditingController();
  TextEditingController _productBillUserName = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      dmiPersons.add(DropdownMenuItem(
        child: Text(AppLocalizations.of(context)!.newCustomer),
        value: 0,
        key: Key(AppLocalizations.of(context)!.newCustomer),
      ));

      //! await _controllerDB.user.value!.result!.userCustomers!.userCustomerList
      //!     .forEach((element)
      var xxx = await _controllerDB
          .user.value!.result!.userCustomers!.userCustomerList!;

      for (var element in xxx) {
        dmiPersons.add(DropdownMenuItem(
          child: Text(
              element.customerAdminName! + " " + element.customerAdminSurname!),
          value: element.id,
          key: Key(
              element.customerAdminName! + " " + element.customerAdminSurname!),
        ));
      }

      selectedPerson = 0;
      GetAllCustomersBills(0);
      loading = false;
      setState(() {});
    });
  }

  Future<void> GetAllCustomersBills(int selectedCustomerId) async {
    await _customersBills.GetAllCustomersBills(_controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id!,
        customerId: selectedCustomerId);
    if (selectedPerson != 0) {
      _productBillUserName = TextEditingController(
          text: _controllerDB
              .user.value!.result!.userCustomers!.userCustomerList!
              .firstWhere((element) => element.id == selectedCustomerId)
              .title);
      _productBillAddress = TextEditingController(
          text:
              _controllerDB.user.value!.result!.userCustomers!.userCustomerList!
                  .firstWhere(
                    (element) => element == selectedCustomerId,
                    //!    orElse: () { return; }
                  )
                  .address);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerCustomersBills>(
      builder: (ControllerCustomersBills controller) {
        return Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          appBar:
              CustomAppBar(title: AppLocalizations.of(context)!.customerBills),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: FloatingActionButton(
              heroTag: "ProfileCustomersBills",
              key: Key("ProfileCustomersBills"),
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            CustomersBillsAddOrUpdate()));
              },
              backgroundColor: Get.theme.colorScheme.primary,
              child: Icon(Icons.add),
            ),
          ),
          body: Stack(
            children: [
              Container(
                width: Get.width,
                height: Get.height,
                child: Column(children: [
                  Expanded(
                    child: Container(
                      width: Get.width,
                      color: Get.theme.colorScheme.primary,
                      child: Container(
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: Get.theme.scaffoldBackgroundColor,
                        ),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 10),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                    height: 45,
                                    child: Row(
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: Container(
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 11),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: Get.width,
                                                  height: 20,
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
                                                          selectedPerson =
                                                              value;
                                                        });
                                                        GetAllCustomersBills(
                                                            value);
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
                                Divider(
                                  color: Colors.black,
                                  thickness: 0.3,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                selectedPerson == 0
                                    ? ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: _customersBills
                                                    .customerBills.length ==
                                                null
                                            ? 0
                                            : _customersBills
                                                .customerBills.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: EdgeInsets.only(bottom: 15),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _customersBills
                                                            .customerBills[
                                                                index]
                                                            .billUserName!,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              new MaterialPageRoute(
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      CustomersBillsAddOrUpdate(
                                                                        customerBill:
                                                                            _customersBills.customerBills[index],
                                                                      )));
                                                        },
                                                        child: Icon(Icons.edit))
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        })
                                    : Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                boxShadow: standartCardShadow(),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: CustomTextField(
                                              controller: _productBillUserName,
                                              validator: (value) {
                                                value = value.trim();
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "";
                                                }

                                                return null;
                                              },
                                              label:
                                                  AppLocalizations.of(context)!
                                                      .userName,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                boxShadow: standartCardShadow(),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: CustomTextField(
                                              controller: _productBillAddress,
                                              inputType: TextInputType.number,
                                              validator: (value) {
                                                value = value.trim();
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "";
                                                }

                                                return null;
                                              },
                                              label:
                                                  AppLocalizations.of(context)!
                                                      .adress,
                                            ),
                                          ),
                                        ],
                                      ),
                                SizedBox(
                                  height: 100,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
