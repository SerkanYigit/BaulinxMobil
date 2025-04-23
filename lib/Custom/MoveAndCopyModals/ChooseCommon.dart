import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Services/Common/CommonDB.dart';
import 'package:undede/Services/TodoService/TodoDB.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Common/CommonGroup.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:undede/model/Todo/CommonTodo.dart';

Future<dynamic> chooseCommon(
    BuildContext context, String title, String btnText, bool forTask) async {
  CommonDB _commonDB = new CommonDB();
  TodoDB _todoDB = new TodoDB();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  List<CommonGroup> commonGroupList = [];
  final List<DropdownMenuItem> cboCommonGroups = [];
  int? selectedCommonGroup;
  List<CommonBoardListItem> commonBoardList = [];
  final List<DropdownMenuItem> cboCommons = [];
  int? selectedcommonBoard;
  List<CommonTodo> boardTaskList = [];
  final List<DropdownMenuItem> cboTasks = [];
  int? selectedBoardTask;

  await _commonDB.GetListCommonGroup(_controllerDB.headers(),
          userId: _controllerDB.user.value!.result!.id)
      .then((value) {
    commonGroupList = value.listOfCommonGroup!;
    commonGroupList.asMap().forEach((index, commonGroup) {
      cboCommonGroups.add(DropdownMenuItem(
        child: Row(
          children: [
            Text(commonGroup.groupName!),
          ],
        ),
        value: commonGroup.id,
        key: Key(commonGroup.groupName!),
      ));
    });
  });

  Future<void> loadBoards(groupId) async {
    await _commonDB.GetAllCommons(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id, groupId: groupId)
        .then((value) {
      commonBoardList = value.result!.commonBoardList!;

      commonBoardList.asMap().forEach((index, commonBoard) {
        cboCommons.add(
          DropdownMenuItem(
              child: Row(
                children: [
                  Text(commonBoard.title!),
                ],
              ),
              value: commonBoard.id,
              key: Key(commonBoard.title!)),
        );
      });
    });
  }

  Future<void> loadTasks(commonId) async {
    await _todoDB.GetCommonTodos(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id,
            commonId: commonId,
            search: "")
        .then((value) {
      boardTaskList = value.listOfCommonTodo!;

      boardTaskList.asMap().forEach((index, boardTask) {
        cboTasks.add(DropdownMenuItem(
          child: Row(
            children: [
              Text(boardTask.content!),
            ],
          ),
          value: boardTask.id,
          key: Key(boardTask.content!),
        ));
      });
    });
  }

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
                          color: Get.theme.primaryColor,
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
                      height: forTask ? 35 : 50,
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
                        value: selectedCommonGroup,
                        icon: Icon(Icons.expand_more),
                        hint: AppLocalizations.of(context)!.chooseProject,
                        searchHint: AppLocalizations.of(context)!.chooseProject,
                        onChanged: (value) async {
                          setState(() {
                            cboCommons.clear();
                          });
                          await loadBoards(value);
                          setState(() {
                            selectedCommonGroup = value;
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
                        items: cboCommons,
                        value: selectedcommonBoard,
                        icon: Icon(Icons.expand_more),
                        hint: AppLocalizations.of(context)!.selectModule,
                        searchHint: AppLocalizations.of(context)!.selectModule,
                        onChanged: (value) async {
                          if (forTask) {
                            setState(() {
                              cboTasks.clear();
                            });
                            await loadTasks(value);
                          }
                          setState(() {
                            selectedcommonBoard = value;
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
                    forTask
                        ? Column(children: [
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
                                menuBackgroundColor:
                                    Get.theme.scaffoldBackgroundColor,
                                items: cboTasks,
                                value: selectedBoardTask,
                                icon: Icon(Icons.expand_more),
                                hint: AppLocalizations.of(context)!
                                    .selectSubModule,
                                searchHint: AppLocalizations.of(context)!
                                    .selectSubModule,
                                onChanged: (value) {
                                  setState(() {
                                    selectedBoardTask = value;
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
                          ])
                        : Container(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, {
                          'CommonId': selectedcommonBoard,
                          'CommonTodoId': selectedBoardTask
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
