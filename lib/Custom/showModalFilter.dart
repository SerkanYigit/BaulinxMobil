import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';

import 'dropdownSearchFn.dart';

Future<dynamic> showModalFilter(
    BuildContext context, String title, String btnText) async {
  TextEditingController textEditingController = new TextEditingController();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCommon _controllerCommon = ControllerCommon();
  final List<DropdownMenuItem> cboCommonGroups = [];
  int? selectedCategoryId;

  final List<DropdownMenuItem> cboOnline = [
    DropdownMenuItem(
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.all),
        ],
      ),
      value: null,
      key: Key(AppLocalizations.of(context)!.all),
    ),
    DropdownMenuItem(
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.online),
        ],
      ),
      value: true,
      key: Key(AppLocalizations.of(context)!.online),
    ),
    DropdownMenuItem(
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.offline),
        ],
      ),
      value: false,
      key: Key(AppLocalizations.of(context)!.offline),
    )
  ];
  bool selectedOnline = false;
  final List<DropdownMenuItem> cboLike = [
    DropdownMenuItem(
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.all),
        ],
      ),
      value: null,
      key: Key(AppLocalizations.of(context)!.all),
    ),
    DropdownMenuItem(
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.favorite),
        ],
      ),
      value: true,
      key: Key(AppLocalizations.of(context)!.favorite),
    ),
    DropdownMenuItem(
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.unFavorite),
        ],
      ),
      value: false,
      key: Key(AppLocalizations.of(context)!.unFavorite),
    )
  ];
  bool selectedLike = false;

  await _controllerCommon.GetPublicCategory(_controllerDB.headers(),
          Language: AppLocalizations.of(context)!.date)
      .then((value) {
    value.result!.asMap().forEach((index, category) {
      cboCommonGroups.add(DropdownMenuItem(
        child: Row(
          children: [
            Text(AppLocalizations.of(context)!.date == "tr"
                ? category.tR!
                : AppLocalizations.of(context)!.date == "en"
                    ? category.eN!
                    : category.dE!),
          ],
        ),
        value: category.id,
        key: Key(AppLocalizations.of(context)!.date == "tr"
            ? category.tR!
            : AppLocalizations.of(context)!.date == "en"
                ? category.eN!
                : category.dE!),
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
                height: Get.height * 0.6 + 85,
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
                          AppLocalizations.of(context)!.filter,
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
                      child: CustomTextField(
                        controller: textEditingController,
                        hint: AppLocalizations.of(context)!.search,
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    SizedBox(
                      height: 15,
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
                        items: cboCommonGroups,
                        value: selectedCategoryId,
                        icon: Icon(Icons.expand_more),
                        hint: AppLocalizations.of(context)!.selectCategory,
                        searchHint: AppLocalizations.of(context)!.selectCategory,
                        onChanged: (value) async {
                          setState(() {
                            selectedCategoryId = value;
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
                      height: 15,
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
                        items: cboLike,
                        value: selectedLike,
                        icon: Icon(Icons.expand_more),
                        hint: AppLocalizations.of(context)!.select,
                        searchHint: AppLocalizations.of(context)!.select,
                        onChanged: (value) async {
                          setState(() {
                            selectedLike = value;
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
                      height: 15,
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
                        items: cboOnline,
                        value: selectedOnline,
                        icon: Icon(Icons.expand_more),
                        hint: AppLocalizations.of(context)!.select,
                        searchHint: AppLocalizations.of(context)!.select,
                        onChanged: (value) async {
                          setState(() {
                            selectedOnline = value;
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
                        Navigator.pop(context, {
                          'Search': textEditingController.text,
                          'CategoryId': selectedCategoryId,
                          'IsOnline': selectedOnline,
                          'IsLike': selectedLike
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
                    SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      });
}
