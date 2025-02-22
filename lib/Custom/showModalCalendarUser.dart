import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Services/Common/CommonDB.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Chat/GetUserListUser.dart';
import 'package:undede/model/Common/GetCommonUserListResult.dart';

//! Future<String> yerine Future<dynamic> yapıldı.
Future<dynamic> showModalCalendarUsers(
    BuildContext context,
    String title,
    String btnText,
    int CommonId,
    List<int> selectedCommonUserIdentities) async {
  CommonDB _commonDb = new CommonDB();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  List<Result> commonUserList = [];

  final List<DropdownMenuItem> cboCommonUserList = [];
  List<int> selectedUsers = [];

  final List<DropdownMenuItem> cboDefinedRoleList = [];
  int? definedRole;

  /*await _commonDb.GetCommonUserList(_controllerDB.headers(),
      UserId: _controllerDB.user.value.result.id,
      CommonId: CommonId).then((value) {

        if (value.hasError) {
          showToast("Error:" + value.resultMessage);
          Navigator.pop(context);
        }

    commonUserList = value.result;

    commonUserList.asMap().forEach((index, commonUser) {
      if (selectedCommonUserIdentities.contains(commonUser.id)) {
        selectedUsers.add(index);
      }

      cboCommonUserList.add(DropdownMenuItem(
        child: Row(
          children: [
            Text(commonUser.name + " " + commonUser.surname),
            SizedBox(
              width: 5,
            ),
            CircleAvatar(
              backgroundImage:
              NetworkImage(commonUser.photo),
              radius: 8,
            )
          ],
        ),
        value: commonUser.id,
      ));
    });
  });*/

  await _controllerChatNew.GetUserList(
          _controllerDB.headers(), _controllerDB.user.value!.result!.id!)
      .then((value) {
    if (value.hasError!) {
      showToast("Error:" + value.resultMessage!);
      Navigator.pop(context);
    }
    print(selectedUsers);
    selectedUsers.addAll(selectedCommonUserIdentities);
    print(selectedCommonUserIdentities);
    print(selectedUsers);

    int incrementIndex = 0;
    List.generate(value.result!.length, (index) {
      if (value.result![index].isGroup == 0) {
        commonUserList.add(value.result![index]);

        cboCommonUserList.add(DropdownMenuItem(
            child: Row(
              children: [
                Text(value.result![index].fullName!),
                SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(value.result![index].photo!),
                  radius: 8,
                )
              ],
            ),
            key: Key(value.result![index].fullName!),
            value: value.result![index].id!));
      }
    });
  });

  await _commonDb.GetDefinedRoleList(_controllerDB.headers())
      .then((definedRoleList) {
    definedRoleList.result!.where((e) => e.moduleType == 33).forEach((e) {
      cboDefinedRoleList.add(DropdownMenuItem(
        child: Row(
          children: [Text(e.name!)],
        ),
        key: Key(e.name!),
        value: e.id,
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
                      height: 50,
                    ),
                    Container(
                        width: 250,
                        height: 45,
                        decoration: BoxDecoration(
                            boxShadow: standartCardShadow(),
                            borderRadius: BorderRadius.circular(15)),
                        child: SearchableDropdown.multiple(
                          items: cboCommonUserList,
                          selectedItems: selectedUsers,
                          hint: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(AppLocalizations.of(context)!.contact),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedUsers = value;
                            });
                          },
                          displayItem: (item, selected) {
                            return (Row(children: [
                              selected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey,
                                    ),
                              SizedBox(width: 7),
                              Expanded(
                                child: item,
                              ),
                            ]));
                          },
                          selectedValueWidgetFn: (item) {
                            return Container(
                              child: (CircleAvatar(
                                backgroundImage: NetworkImage(
                                  commonUserList
                                      .firstWhere((e) => e.id == item)
                                      .photo!,
                                ),
                              )),
                            );
                          },
                          doneButton: (selectedItemsDone, doneContext) {
                            return (ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(doneContext);
                                  setState(() {});
                                },
                                child:
                                    Text(AppLocalizations.of(context)!.save)));
                          },
                          closeButton: null,
                          style: Get.theme.inputDecorationTheme.hintStyle,
                          searchFn: dropdownSearchFn,
                          /*searchFn: todo:arama çalışmıyor bakılacak
                            (String keyword, List<DropdownMenuItem> items) {
                          log('XXXXXXXXXXXXXX');
                          log(items.map((e) => e.value).toString());
                          log(keyword);
                          log('XXXXXXXXXXXXXX');
                        },*/
                          //clearIcon: Icons(null), todo:nullable yap
                          icon: Icon(
                            Icons.expand_more,
                            size: 31,
                          ),
                          underline: Container(
                            height: 0.0,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.teal, width: 0.0))),
                          ),
                          iconDisabledColor: Colors.grey,
                          iconEnabledColor: Get.theme.colorScheme.surface,
                          isExpanded: true,
                        )),
                    SizedBox(
                      height: 30,
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
                        items: cboDefinedRoleList,
                        value: definedRole,
                        icon: Icon(Icons.expand_more),
                        hint:
                            "* ${AppLocalizations.of(context)!.selectDefinedRole}",
                        searchHint:
                            "* ${AppLocalizations.of(context)!.selectDefinedRole}",
                        onChanged: (value) async {
                          setState(() {
                            definedRole = value;
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
                        Navigator.pop(
                            context,
                            jsonEncode({
                              "RoleId": definedRole,
                              "TargetUserIdList": commonUserList
                                  .where((e) => selectedUsers
                                      .contains(commonUserList.indexOf(e)))
                                  .toList()
                                  .map((e) => e.id)
                                  .toList()
                            }));
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
                          AppLocalizations.of(context)!.okey,
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
