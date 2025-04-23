import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Custom/showModalYesOrNo.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Services/Invoice/InvoiceDB.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Invoice/GetInvoiceTargetAccountList.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<dynamic> showModalMoveInvoiceFiles(
    BuildContext context,
    int invoiceBlock,
    String title,
    String btnText,
    int invoiceTargetAccountId) async {
  TextEditingController textEditingController = new TextEditingController();
  InvoiceDB _invoiceDb = new InvoiceDB();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  List<InvoiceTargetAccount> targetAccountList =[];
  final List<DropdownMenuItem> cboTargetAccountList = [];
  int? selectedTargetAccountId =
      invoiceTargetAccountId == 0 ? null : invoiceTargetAccountId;
  final List<DropdownMenuItem> cboinvBlockList = [];
  int? selectedInvBlockId;
  DateTime endDate = DateTime.now();
  var invoiceBlocks = [
    {
      'id': 1,
      'name': AppLocalizations.of(context)!.outgoingPaid,
    },
    {
      'id': 2,
      'name': AppLocalizations.of(context)!.incomePaid,
    },
    {
      'id': 3,
      'name': AppLocalizations.of(context)!.outgoingUnpaid,
    },
    {
      'id': 4,
      'name': AppLocalizations.of(context)!.incomeUnpaid,
    },
  ];

  await _invoiceDb.GetInvoiceTargetAccountList(_controllerDB.headers(),
          UserId: _controllerDB.user.value!.result!.id!)
      .then((value) {
    targetAccountList = value.result!;

    targetAccountList.asMap().forEach((index, targetAccount) {
      cboTargetAccountList.add(DropdownMenuItem(
        child: Row(
          children: [
            Text(targetAccount.name!),
          ],
        ),
        value: targetAccount.id,
        key: Key(targetAccount.name!),
      ));
    });

    invoiceBlocks.asMap().forEach((index, invBlock) {
      if (invBlock['id'] != invoiceBlock)
        cboinvBlockList.add(DropdownMenuItem(
          child: Row(
            children: [
              Text(invBlock['name'].toString()),
            ],
          ),
          value: invBlock['id'],
          key: Key(invBlock['name'].toString()),
        ));
    });
  });

  return showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      isScrollControlled: true,
      context: context,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 430,
                width: Get.width,
                child: Column(
                  children: [
                    Container(
                        height: 50,
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: Color(0xFFe3d5a4),
                        ),
                        child: Center(
                            child: Text(
                          title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Get.theme.secondaryHeaderColor),
                        ))),
                    SizedBox(
                      height: 35,
                    ),
                    Container(
                      width: 250,
                      height: 45,
                      decoration: BoxDecoration(
                          boxShadow: standartCardShadow(),
                          borderRadius: BorderRadius.circular(15)),
                      child: SearchableDropdown.single(
                        color: Colors.white,
                        height: 45,
                        displayClearIcon: false,
                        menuBackgroundColor: Get.theme.scaffoldBackgroundColor,
                        items: cboinvBlockList,
                        value: selectedInvBlockId,
                        icon: Icon(Icons.expand_more),
                        hint:
                            "* ${AppLocalizations.of(context)!.selectInvoiceBlock}",
                        searchHint:
                            "* ${AppLocalizations.of(context)!.selectInvoiceBlock}   ${invoiceBlocks[invoiceBlock - 1]["name"].toString()}",
                        onChanged: (value) async {
                          bool inToOut = ([1, 2].contains(invoiceBlock) &&
                              ![1, 2].contains(value));
                          if (([1, 2].contains(invoiceBlock) &&
                                  ![1, 2].contains(value)) ||
                              ([3, 4].contains(invoiceBlock) &&
                                  ![3, 4].contains(value))) {
                            bool? confirm = await showModalYesOrNo(
                                context,
                                AppLocalizations.of(context)!.confirmation,
                                "${AppLocalizations.of(context)!.invoicewillmove}"
                                '${inToOut ? '${AppLocalizations.of(context)!.incometooutgoing}' : '${AppLocalizations.of(context)!.outgoingtoincome}'}.${AppLocalizations.of(context)!.doyouconfirm}');
                            print('confirm: ' + confirm.toString());
                            if (confirm!) {
                              setState(() {
                                selectedInvBlockId = value;
                              });
                            }
                          } else {
                            setState(() {
                              selectedInvBlockId = value;
                            });
                          }
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
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Visibility(
                      visible: invoiceTargetAccountId == 0 ? true : false,
                      child: Container(
                        width: 250,
                        height: 45,
                        decoration: BoxDecoration(
                            boxShadow: standartCardShadow(),
                            borderRadius: BorderRadius.circular(15)),
                        child: SearchableDropdown.single(
                          color: Colors.white,
                          height: 45,
                          displayClearIcon: false,
                          menuBackgroundColor:
                              Get.theme.scaffoldBackgroundColor,
                          items: cboTargetAccountList,
                          value: selectedTargetAccountId,
                          icon: Icon(Icons.expand_more),
                          hint:
                              "* ${AppLocalizations.of(context)!.selectTargetAccount}",
                          searchHint:
                              "* ${AppLocalizations.of(context)!.selectTargetAccount}",
                          onChanged: (value) {
                            setState(() {
                              selectedTargetAccountId = value;
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
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 45,
                      width: 250,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(45),
                          boxShadow: standartCardShadow()),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 7,
                              child: GestureDetector(
                                  child: Text(
                                      DateFormat('EEE, MMM dd yyyy')
                                          .format(endDate),
                                      textAlign: TextAlign.left),
                                  onTap: () async {
                                    DateTime? t = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2100),
                                    );
                                    setState(() {
                                      endDate = t!;
                                    });
                                  }),
                            ),
                          ]),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, {
                          'Accept': true,
                          'InvoiceBlock': selectedInvBlockId,
                          'TargetAccountId': selectedTargetAccountId,
                          'FullDate': endDate,
                          'Year': endDate.year,
                          'Month': endDate.month,
                        });
                                            },
                      child: Container(
                        width: 250,
                        height: 45,
                        decoration: BoxDecoration(
                            boxShadow: standartCardShadow(),
                            color: Get.theme.secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(45)),
                        child: Center(
                            child: Text(
                          btnText,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              color: Colors.white),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      });
}
