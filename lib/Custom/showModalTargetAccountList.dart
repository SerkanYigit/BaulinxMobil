import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Services/Invoice/InvoiceDB.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Invoice/GetInvoiceTargetAccountList.dart';

Future<int?> showModalTargetAccountList(
    BuildContext context, String title, String btnText) async {
  InvoiceDB _invoiceDb = new InvoiceDB();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  List<InvoiceTargetAccount> targetAccountList =[];
  final List<DropdownMenuItem> cboTargetAccountList = [];
  int selectedTargetAccountId = 1;

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
  });

  return showModalBottomSheet<int>(
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
                      height: 50,
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
                        items: cboTargetAccountList,
                        value: selectedTargetAccountId,
                        icon: Icon(Icons.expand_more),
                        hint: AppLocalizations.of(context)!.selectTargetAccount,
                        searchHint:
                            AppLocalizations.of(context)!.selectTargetAccount,
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
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, selectedTargetAccountId);
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
