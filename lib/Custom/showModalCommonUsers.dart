import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Services/Common/CommonDB.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Chat/GetUserListUser.dart' as a;
import 'package:undede/model/Chat/GetUserListUser.dart';
import 'package:undede/model/Common/GetCommonUserListResult.dart';
import 'package:undede/model/Common/GetDefinedRoleListResult.dart';
import 'package:undede/model/Common/UserListWithRole.dart';

class Controller extends GetxController {
  int? selectedUserId;
  int? definedRole;
  void increment() {}
}

//! Future<String> yerinne Future<dynamic> yapildi
Future<dynamic> showModalCommonUsers(
    BuildContext context,
    String title,
    String btnText,
    int CommonId,
    List<CommonUser> selectedCommonUserIdentities) async {
  final controller = Get.put(Controller());
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());

  CommonDB _commonDb = new CommonDB();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  List<a.Result> commonUserList = [];
  List<CommonUser> _newCommonUsers = [];
  final List<DropdownMenuItem> cboCommonUserList = [];
  GetUserListResult selectedUsers =
      GetUserListResult(result: [], hasError: false);
  final List<DropdownMenuItem> cboDefinedRoleList = [];
  final ScrollController controller3 = ScrollController();
  final ScrollController controller2 = ScrollController();
  selectedCommonUserIdentities.forEach((element) {
    _newCommonUsers.add(element);
  });
  GetDefinedRoleListResult _roleList =
      GetDefinedRoleListResult(hasError: false);
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

    int incrementIndex = 0;
    List.generate(value.result!.length, (index) {
      if (value.result![index].isGroup == 0) {
        commonUserList.add(value.result![index]);
        if (selectedCommonUserIdentities
            .map((e) => e.id)
            .toList()
            .contains(value.result![index].id)) {
          print(
              index.toString() + " id: " + value.result![index].id.toString());
          selectedUsers.result!.add(value.result![index]);
        }
        incrementIndex += 1;
        if (cboCommonUserList
            .any((element) => element.value == value.result![index].id)) {
          return;
        }
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
    _roleList = definedRoleList;
    definedRoleList.result!.where((e) => e.moduleType == 14).forEach((e) {
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
      context: Get.context!,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      builder: (context) {
        return GetBuilder<Controller>(builder: (_) {
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: Get.height * 0.85,
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
                        width: Get.width,
                        height: 50,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      items: cboCommonUserList,
                                      value: _.selectedUserId,
                                      hint: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .contact),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _.selectedUserId = value;
                                          _.update();
                                        });
                                      },
                                      style: Get
                                          .theme.inputDecorationTheme.hintStyle,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 31,
                                      ),
                                      underline: Container(
                                        height: 0.0,
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.teal,
                                                    width: 0.0))),
                                      ),
                                      iconDisabledColor: Colors.grey,
                                      iconEnabledColor:
                                          Get.theme.colorScheme.surface,
                                      isExpanded: true,
                                    ),
                                  )),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Container(
                                height: 45,
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(8)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    items: cboDefinedRoleList,
                                    value: _.definedRole,
                                    icon: Icon(Icons.expand_more),
                                    hint: Text(AppLocalizations.of(context)!
                                        .selectDefinedRole),
                                    onChanged: (value) async {
                                      setState(() {
                                        _.definedRole = value;
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              onTap: () {
                                if (_newCommonUsers.any((element) =>
                                    element.id == _.selectedUserId)) {
                                  return;
                                }
                                setState(() {
                                  _newCommonUsers.add(CommonUser(
                                      name: _controllerChatNew
                                          .UserListRx?.value!.result!
                                          .firstWhere((element) =>
                                              element.id == _.selectedUserId)
                                          .name,
                                      surname: _controllerChatNew
                                          .UserListRx?.value!.result!
                                          .firstWhere((element) =>
                                              element.id == _.selectedUserId)
                                          .surname!,
                                      photo: _controllerChatNew
                                          .UserListRx?.value!.result!
                                          .firstWhere((element) =>
                                              element.id == _.selectedUserId)
                                          .photo!,
                                      id: _controllerChatNew
                                          .UserListRx?.value!.result!
                                          .firstWhere((element) =>
                                              element.id == _.selectedUserId)
                                          .id!,
                                      userRules: [
                                        UserRules(
                                            id: _.definedRole,
                                            title: _roleList.result!
                                                .firstWhere((element) =>
                                                    element.id == _.definedRole)
                                                .name)
                                      ]));
                                });
                                cboCommonUserList.removeWhere((element) =>
                                    element.value == _.selectedUserId);
                                setState(() {
                                  _.definedRole = null;
                                  _.selectedUserId = null;
                                });

                                _.update();
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Get.theme.primaryColor,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!.add)),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),
                      Scrollbar(
                        controller: controller2,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: controller2,
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            controller: controller3,
                            child: Container(
                              width: Get.width < 890
                                  ? null
                                  : Get.width < 1850
                                      ? Get.width
                                      : Get.width,
                              height: Get.height * 0.45,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Get.width * 0.01),
                              child: DataTable(
                                columns: <DataColumn>[
                                  DataColumn(
                                    label: Text(AppLocalizations.of(context)!
                                            .signUpName +
                                        " " +
                                        AppLocalizations.of(context)!
                                            .signUpSurname),
                                  ),
                                  DataColumn(
                                    label: Text("Role"),
                                  ),
                                  DataColumn(
                                    label: Text(" "),
                                  ),
                                ],
                                rows: List<DataRow>.generate(
                                  _newCommonUsers.length,
                                  (int index) => DataRow(
                                    color:
                                        WidgetStateProperty.resolveWith<Color>(
                                            (Set<WidgetState> states) {
                                      // All rows will have the same selected color.
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.08);
                                      }
                                      // Even rows will have a grey color.
                                      if (index.isEven) {
                                        return Colors.grey.withOpacity(0.3);
                                      }
                                      //! null yerine Colors.transparent yapildi
                                      return Colors
                                          .transparent; // Use default value for other states and odd rows
                                    }),
                                    cells: <DataCell>[
                                      DataCell(
                                        Text(
                                          _newCommonUsers[index].name! +
                                              " " +
                                              _newCommonUsers[index].surname!,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      DataCell(Text(
                                        _newCommonUsers[index]
                                            .userRules!
                                            .first
                                            .title!,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      )),
                                      DataCell(InkWell(
                                          onTap: () {
                                            setState(() {
                                              cboCommonUserList.add(
                                                  DropdownMenuItem(
                                                      child: Row(
                                                        children: [
                                                          Text(_newCommonUsers[
                                                                      index]
                                                                  .name! +
                                                              " " +
                                                              _newCommonUsers[
                                                                      index]
                                                                  .surname!),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          CircleAvatar(
                                                            backgroundImage: NetworkImage(
                                                                _newCommonUsers[
                                                                            index]
                                                                        .photo ??
                                                                    ""),
                                                            radius: 8,
                                                          )
                                                        ],
                                                      ),
                                                      value:
                                                          _newCommonUsers[index]
                                                              .id));
                                              _newCommonUsers.remove(
                                                  _newCommonUsers[index]);
                                            });
                                          },
                                          child: Icon(Icons.delete_outline))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          List<UserListWithRole> UserandRole = [];
                          List<int> deletedUserIds = [];
                          selectedCommonUserIdentities.forEach((element) {
                            if (!_newCommonUsers
                                .any((news) => news.id == element.id)) {
                              setState(() {
                                deletedUserIds.add(element.id!);
                              });
                            }
                          });
                          _newCommonUsers.forEach((element) {
                            UserandRole.add(UserListWithRole(
                                Id: element.id!,
                                RoleId: element.userRules!.first.id!));
                          });

                          _controllerCommon.InviteUsersCommonBoardWithRole(
                              _controllerDB.headers(),
                              UserId: _controllerDB.user.value!.result!.id!,
                              CommonId: CommonId,
                              DeletedUserIdList: deletedUserIds,
                              userListWithRoleId: UserandRole);
                          Navigator.pop(context);
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
      });
}
